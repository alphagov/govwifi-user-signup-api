require "logger"

class Survey::Gateway::Surveys
def send_signup_surveys
    query = WifiUser::Repository::User
                              #.where(Sequel.lit("last_login > DATE_SUB(NOW(), INTERVAL 1 DAY)"))
                              .where{ last_login > DateTime.now - 1 }
                              .where(signup_survey_sent_at: nil)
                              .where(contact: /@/)
                              # .where{ contact.like('%@%') }
                              # .where(Sequel.lit("contact != sponsor"))

    query.all do |user|
      user.update(signup_survey_sent_at: DateTime.now)
    end
  end
end
