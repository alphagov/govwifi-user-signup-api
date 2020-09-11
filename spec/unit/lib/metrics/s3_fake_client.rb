# frozen_string_literal: true

module Metrics
  def self.fake_s3_client
    fake_s3 = {}
    Aws::S3::Client.new(stub_responses: true).tap do |client|
      client.stub_responses(
        :put_object, lambda { |context|
                       bucket = context.params[:bucket]
                       key = context.params[:key]
                       body = context.params[:body]
                       fake_s3[bucket] ||= {}
                       fake_s3[bucket][key] = body
                       {}
                     }
      )
      client.stub_responses(
        :get_object, lambda { |context|
                       bucket = context.params[:bucket]
                       key = context.params[:key]
                       { body: fake_s3.dig(bucket, key) }
                     }
      )
    end
  end
end
