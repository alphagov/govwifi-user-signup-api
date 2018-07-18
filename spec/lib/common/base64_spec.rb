describe Common::Base64 do
  context '#encode_array' do
    it 'joins array contents and encodes it' do
      arr = %w(foo bar baz)

      expect(described_class.encode_array(arr)).to eq("Zm9vYmFyYmF6")
    end
  end
end
