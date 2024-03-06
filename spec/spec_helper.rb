require "factory_bot"
require "rack/test"
require "rspec"
require "simplecov"
require "sequel"
require "webmock/rspec"
require "shared"

ENV["RACK_ENV"] = "test"

require File.expand_path "../app.rb", __dir__

module RSpecMixin
  include Rack::Test::Methods
  def app
    described_class
  end
end

SimpleCov.start
FactoryBot.find_definitions

RSpec.configure do |c|
  c.filter_run_when_matching focus: true

  c.include RSpecMixin
end

module S3Fake
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
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1000

RSpec.shared_context "simple allow list" do
  before :each do
    Services.s3_client.put_object(bucket: ENV.fetch("S3_SIGNUP_ALLOWLIST_BUCKET"),
                                  key: ENV.fetch("S3_SIGNUP_ALLOWLIST_OBJECT_KEY"),
                                  body: '^.*@(gov\.uk)$')
  end
end

RSpec.shared_context "fake notify" do
  before :each do
    allow(Services).to receive(:notify_client).and_return(double)
    allow(Services.notify_client).to receive(:send_email)
    allow(Services.notify_client).to receive(:send_sms)
  end
end

RSpec.configure do |c|
  c.before(:each) do
    allow(Services).to receive(:s3_client).and_return(S3Fake.fake_s3_client)
    DB[:smslog].truncate
    DB[:userdetails].truncate
    DB[:notifications].truncate
    c.full_backtrace = true
  end
end
