describe Gdpr::UseCase::ObfuscateSponsors do
  subject { described_class.new(user_details_gateway: user_details_gateway) }

  let(:user_details_gateway) { double(obfuscate_sponsors: nil) }

  context 'Given a user gateway' do
    it 'calls obfuscate sponsors method on the gateway' do
      subject.execute
      expect(user_details_gateway).to have_received(:obfuscate_sponsors)
    end
  end
end
