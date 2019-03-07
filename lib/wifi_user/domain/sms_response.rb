class WifiUser::Domain::SMSResponse
  def initialize(success:)
    @success = success
  end

  attr_accessor :success
end
