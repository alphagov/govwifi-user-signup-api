class PerformancePlatform::Repository::SignUp < Sequel::Model(:userdetails)
  dataset_module do
    def all
      where(Sequel.lit("date(created_at) <= '#{Date.today - 1}'"))
    end

    def yesterday
      where(Sequel.lit("date(created_at) = '#{Date.today - 1}'"))
    end

    def self_sign
      where(contact: Sequel[:sponsor])
    end

    def sponsored
      exclude(contact: Sequel[:sponsor])
    end

    def with_sms
      where(Sequel.like(:contact, '+%'))
    end

    def with_email
      where(Sequel.like(:contact, '%@%'))
    end

    def last_week
      where(created_at: (Date.today - 14)..(Date.today - 7))
    end

    def with_successful_login
      exclude(last_login: nil)
    end
  end
end
