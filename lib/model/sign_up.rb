class SignUp < Sequel::Model(:userdetails)
  dataset_module do
    def all
      where(Sequel[:created_at] < Date.today + 1)
    end

    def today
      where(Sequel[:created_at] > Date.today)
    end

    def self_sign
      where(contact: Sequel[:sponsor])
    end

    def with_sms
      where(Sequel.like(:contact, '+%'))
    end

    def with_email
      where(Sequel.like(:contact, '%@%'))
    end
  end
end
