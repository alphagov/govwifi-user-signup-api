describe Notifications::NotifyTemplates do
  let(:template_one) { Notifications::NotifyTemplates::TEMPLATES.first }
  let(:template_two) { Notifications::NotifyTemplates::TEMPLATES.last }
  let(:templates) do
    [
      instance_double(Notifications::Client::Template, name: template_one, id: "template_one_id"),
      instance_double(Notifications::Client::Template, name: "unused", id: "unused"),
      instance_double(Notifications::Client::Template, name: template_two, id: "template_two_id"),
    ]
  end
  before do
    template_collection = instance_double(Notifications::Client::TemplateCollection, collection: templates)
    client = instance_double(Notifications::Client, get_all_templates: template_collection)
    allow(Services).to receive(:notify_client).and_return(client)
  end
  describe "#template" do
    it "filters out unused templates" do
      expect { Notifications::NotifyTemplates.template("unused") }.to raise_error(KeyError)
    end
    it "fetches a template" do
      expect(Notifications::NotifyTemplates.template(template_one)).to eq("template_one_id")
      expect(Notifications::NotifyTemplates.template(template_two)).to eq("template_two_id")
    end
    it "accepts symbols" do
      expect(Notifications::NotifyTemplates.template(template_one.to_sym)).to eq("template_one_id")
    end
  end
end
