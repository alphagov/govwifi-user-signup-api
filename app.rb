require 'sinatra/base'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
  end

  get '/healthcheck' do
    'Healthy'
  end
end
