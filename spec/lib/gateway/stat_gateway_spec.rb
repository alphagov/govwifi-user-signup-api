describe PerformancePlatform::Gateway::Statistics do
  before do
    DB[:userdetails].truncate
  end

  context 'given no signups' do
    it 'returns stats with zero signups' do
      expect(subject.signups).to eq(
        today: 0,
        cumulative: 0,
        sms_today: 0,
        sms_cumulative: 0,
        email_today: 0,
        email_cumulative: 0,
        sponsored_cumulative: 0,
        sponsored_today: 0
      )
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

    it 'returns same cumulative number of signups' do
      expect(subject.signups[:cumulative]).to eq(3)
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

    it 'returns zero signups 6 signups cumulative' do
      expect(subject.signups[:cumulative]).to eq(6)
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

    it 'returns zero signups cumulative' do
      expect(subject.signups[:cumulative]).to eq(0)
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

    it 'counts all of them against cumulative singups' do
      expect(subject.signups[:cumulative]).to eq(3)
    end

    it 'counts all of them against todays signups' do
      expect(subject.signups[:today]).to eq(3)
    end

    it 'calculates SMS cumulative signups' do
      expect(subject.signups[:sms_cumulative]).to eq(1)
    end

    it 'calculates SMS todays signups' do
      expect(subject.signups[:sms_today]).to eq(1)
    end

    it 'calculates email cumulative signups' do
      expect(subject.signups[:email_cumulative]).to eq(2)
    end

    it 'calculates email todays signups' do
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

    it 'counts them against cumulative singups' do
      expect(subject.signups[:cumulative]).to eq(2)
    end

    it 'counts them against todays signups' do
      expect(subject.signups[:today]).to eq(1)
    end

    it 'counts them against SMS cumulative signups' do
      expect(subject.signups[:sms_cumulative]).to eq(2)
    end

    it 'counts them against SMS todays signups' do
      expect(subject.signups[:sms_today]).to eq(1)
    end
  end

  context 'given email signups made on different dates' do
    before do
      User.create(
        username: "Email old",
        created_at: Date.today - 1,
        contact: 'foo@bar.com',
        sponsor: 'foo@bar.com'
        )

      User.create(
        username: "Email new",
        contact: 'foo@baz.com',
        sponsor: 'foo@baz.com'
        )
    end

    it 'counts them against cumulative singups' do
      expect(subject.signups[:cumulative]).to eq(2)
    end

    it 'counts them against todays signups' do
      expect(subject.signups[:today]).to eq(1)
    end

    it 'counts them against email cumulative signups' do
      expect(subject.signups[:email_cumulative]).to eq(2)
    end

    it 'counts them against email signups today' do
      expect(subject.signups[:email_today]).to eq(1)
    end
  end

  context 'given sponsored sign ups' do
    before do
      User.create(
        username: 'Email',
        contact: 'foo@bar.com',
        sponsor: 'sponsor@bar.com'
        )

      User.create(
        username: 'SMS',
        contact: 'foo@baz.com',
        sponsor: 'sponsor@baz.com',
        created_at: Date.today - 1
        )
    end

    it 'counts both of them to cumulative number of sponsored sign ups' do
      expect(subject.signups[:sponsored_cumulative]).to eq(2)
    end

    it 'counts one of them as sponsored sign up today' do
      expect(subject.signups[:sponsored_today]).to eq(1)
    end
  end
end
