class WifiUser::UseCase::CheckUserIsSponsee
  def initialize(allowlist_checker:)
    @allowlist_checker = allowlist_checker
  end

  def execute(contact)
    sponsee = DB[:userdetails].where(contact:)&.first

    return false unless sponsee
    return false unless sponsee[:sponsor]

    sponsor_email = sponsee[:sponsor]

    allowlist_checker.execute(sponsor_email)[:success]
  end

private

  attr_reader :allowlist_checker
end
