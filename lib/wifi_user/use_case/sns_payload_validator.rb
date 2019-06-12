require 'aws-sdk-sns'
require 'json'

class WifiUser::UseCase::SnsPayloadValidator

  def initialize(expected_account_id:, logger: Logger.new(STDOUT))
    @expected_account_id = expected_account_id
    @logger = logger
  end

  def execute(payload)
    correct_account?(payload) && authentic?(payload)
  end

  private

  attr_reader :logger, :expected_account_id

  def authentic?(payload)
    verifier = Aws::SNS::MessageVerifier.new
    verifier.authentic?(payload.to_json)
  end

  def correct_account?(payload)
    account_id(arn(payload)) == expected_account_id
  end

  def arn(payload)
    payload['TopicArn']
  end

  def account_id(arn)
    arn.split(':')[4]
  end
end
