describe StatGateway do
  before do
    DB[:userdetails].truncate
  end

  context 'given no signups' do
    it 'returns zero signups for today' do
      expect(subject.signups).to eq(today: 0, total: 0)
    end
  end

  context 'given 3 signups today' do
    before do
      3.times do |i|
        User.create(username: "Today #{i}")
      end
    end

    it 'returns zero signups for today' do
      expect(subject.signups).to eq(today: 3, total: 3)
    end
  end

  context 'given 5 signups today and 1 yesterday' do
    before do
      User.create(username: 'Yesterday', created_at: Date.today - 1)

      5.times do |i|
        User.create(username: "Today #{i}")
      end
    end

    it 'returns zero signups 5 signups for today and 6 total' do
      expect(subject.signups).to eq(today: 5, total: 6)
    end
  end

  context 'given 2 signups tomorrow' do
    before do
      2.times do |i|
        User.create(username: "Tomorrow #{i}", created_at: Date.today + 1)
      end
    end

    it 'returns zero signups for today' do
      expect(subject.signups).to eq(today: 0, total: 0)
    end
  end
end
