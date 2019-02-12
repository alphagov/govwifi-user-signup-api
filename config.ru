#\ --quiet
# The above is needed to prevent rack from request logging

RACK_ENV = ENV['RACK_ENV'] ||= 'development'

require './app'
run App
