describe Gdpr::UseCase::ObfusticateSponsors do
  subject { described_class.new(user_details_gateway: user_details_gateway) }

  let(:user_details_gateway) { double(obfusticate_sponsors: nil) }

  context 'Given a user gateway' do
    it 'calls obfusticate sponsors method on the gateway' do
      subject.execute
      expect(user_details_gateway).to have_received(:obfusticate_sponsors)
    end
  end
end
