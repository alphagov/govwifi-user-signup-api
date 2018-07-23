describe PerformancePlatform::Gateway::CompletionRate do
  let(:user_repo) { WifiUser::Repository::User }

  before do
    DB[:userdetails].truncate

    # Outside of date scope
    user_repo.create(
      username: '1',
      created_at: Date.today - 1,
      contact: '+1234567890',
      sponsor: '+1234567890'
    )

    # Outside of date scope
    # and logged in
    user_repo.create(
      username: '2',
      created_at: Date.today - 1,
      contact: '+1234567890',
      sponsor: '+1234567890',
      last_login: Date.today
    )

    # SMS self-registered within date scope
    user_repo.create(
      username: '3',
      created_at: Date.today - 8,
      contact: '+2345678901',
      sponsor: '+2345678901'
    )

    # SMS self-registered within date scope
    # and logged in
    user_repo.create(
      username: '4',
      created_at: Date.today - 8,
      contact: '+2345678901',
      sponsor: '+2345678901',
      last_login: Date.today
    )

    # SMS sponsor-registered within date scope
    user_repo.create(
      username: '5',
      created_at: Date.today - 8,
      contact: '+2345678901',
      sponsor: 'sponsor@example.com'
    )

    # SMS sponsor-registered within date scope
    # and logged in
    user_repo.create(
      username: '6',
      created_at: Date.today - 8,
      contact: '+2345678901',
      sponsor: 'sponsor@example.com',
      last_login: Date.today
    )

    # email self-registered within scope
    user_repo.create(
      username: '7',
      created_at: Date.today - 10,
      contact: 'me@example.com',
      sponsor: 'me@example.com'
    )

    # Email self-registered within scope
    # and logged in
    user_repo.create(
      username: '8',
      created_at: Date.today - 10,
      contact: 'me@example.com',
      sponsor: 'me@example.com',
      last_login: Date.today
    )
  end

  context 'given completed signups and logins' do
    it 'returns stats for completion rate' do
      expect(subject.fetch_stats).to eq(
        metric_name: 'completion-rate',
        period: 'week',
        sms_registered: 4,
        sms_logged_in: 2,
        email_registered: 2,
        email_logged_in: 1,
        sponsor_registered: 2,
        sponsor_logged_in: 1,
      )
    end
  end
end
