class PerformancePlatform::Repository::SignUp < Sequel::Model(:userdetails)
  # rubocop:disable Metrics/BlockLength
  dataset_module do
    def all(date)
      where(Sequel.lit("date(created_at) <= '#{date - 1}'"))
    end

    def day_before(date)
      where(Sequel.lit("date(created_at) = '#{date - 1}'"))
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

    def week_before(date)
      where(Sequel.lit("date(created_at) BETWEEN '#{date - 14}' AND '#{date - 7}'"))
    end

    def month_before(date)
      yesterday = date.prev_day
      where(Sequel.lit("date(created_at) BETWEEN '#{yesterday.prev_month}' AND '#{yesterday}'"))
    end

    def with_successful_login
      exclude(last_login: nil)
    end
  end
  # rubocop:enable Metrics/BlockLength
end
