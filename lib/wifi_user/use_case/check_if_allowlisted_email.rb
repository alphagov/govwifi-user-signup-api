module WifiUser
  module UseCases
    class CheckIfAllowlistedEmail
      def initialize(gateway:)
        @email_regex_gateway = gateway
      end

      def execute(email)
        result = email_regex_gateway.fetch

        pattern = Regexp.new(result, Regexp::IGNORECASE)

        { success: email.to_s.match?(pattern) }
      end

    private

      attr_reader :email_regex_gateway
    end
  end
end
