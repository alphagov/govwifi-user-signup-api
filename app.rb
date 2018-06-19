require 'sinatra/base'

class App < Sinatra::Base
  get '/healthcheck' do
    'Healthy'
  end
end
