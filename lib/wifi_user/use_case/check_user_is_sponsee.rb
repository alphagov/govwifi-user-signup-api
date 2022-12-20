class WifiUser::UseCase::CheckUserIsSponsee
  def execute(contact)
    sponsee = WifiUser::Repository::User.find(contact:)

    sponsee.present? && sponsee[:sponsor] != contact
  end
end
