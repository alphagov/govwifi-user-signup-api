class WifiUser::Domain::EmailResponse
  def initialize(success:)
    @success = success
  end

  attr_reader :success
end
