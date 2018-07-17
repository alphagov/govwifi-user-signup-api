describe StatGateway do
  before do
    DB[:userdetails].truncate
  end

  context 'given no signups' do
    it 'returns zero signups for today' do
      expect(subject.signups[:today]).to eq(0)
    end

    it 'returns zero signups for today' do
      expect(subject.signups[:total]).to eq(0)
    end
  end

  context 'given 3 signups today' do
    before do
      3.times do |i|
        User.create(username: "Today #{i}")
      end
    end

    it 'returns signups for today' do
      expect(subject.signups[:today]).to eq(3)
    end

    it 'returns same total number of signups' do
      expect(subject.signups[:total]).to eq(3)
    end
  end

  context 'given 5 signups today and 1 yesterday' do
    before do
      User.create(username: 'Yesterday', created_at: Date.today - 1)

      5.times do |i|
        User.create(username: "Today #{i}")
      end
    end

    it 'returns zero signups 5 signups for today' do
      expect(subject.signups[:today]).to eq(5)
    end

    it 'returns zero signups 6 signups total' do
      expect(subject.signups[:total]).to eq(6)
    end
  end

  context 'given 2 signups tomorrow' do
    before do
      2.times do |i|
        User.create(username: "Tomorrow #{i}", created_at: Date.today + 1)
      end
    end

    it 'returns zero signups for today' do
      expect(subject.signups[:today]).to eq(0)
    end

    it 'returns zero signups total' do
      expect(subject.signups[:today]).to eq(0)
    end
  end

  context 'given 1 SMS signup today and 2 email signups' do
    before do
      User.create(
        username: 'Email 1',
        contact: 'foo@bar.com',
        sponsor: 'foo@bar.com'
        )

      User.create(
        username: 'Email 2', 
        contact: 'foo@baz.com',
        sponsor: 'foo@baz.com'
        )

      User.create(
        username: "SMS",
        contact: '+0123456789',
        sponsor: '+0123456789'
        )
    end

    it 'counts all of them against total singups' do
      expect(subject.signups[:total]).to eq(3)
    end

    it 'counts all of them against todays signups' do
      expect(subject.signups[:today]).to eq(3)
    end

    it 'calculates SMS total signups' do
      expect(subject.signups[:sms_total]).to eq(1)
    end

    it 'calculates SMS todays signups' do
      expect(subject.signups[:sms_today]).to eq(1)
    end

    it 'calculates SMS total signups' do
      expect(subject.signups[:email_total]).to eq(2)
    end

    it 'calculates SMS todays signups' do
      expect(subject.signups[:email_today]).to eq(2)
    end
  end

  context 'given SMS signups made on different dates' do
    before do
      User.create(
        username: "SMS old",
        created_at: Date.today - 1,
        contact: '+1123456789',
        sponsor: '+1123456789'
        )

      User.create(
        username: "SMS today",
        contact: '+0123456789',
        sponsor: '+0123456789'
        )
    end

    it 'counts them against total singups' do
      expect(subject.signups[:total]).to eq(2)
    end

    it 'counts them against todays signups' do
      expect(subject.signups[:today]).to eq(1)
    end

    it 'counts them against SMS total signups' do
      expect(subject.signups[:sms_total]).to eq(2)
    end

    it 'counts them against SMS todays signups' do
      expect(subject.signups[:sms_today]).to eq(1)
    end
  end
end
