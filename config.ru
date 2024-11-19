RACK_ENV = ENV['RACK_ENV'] ||= 'development'

require './app'
run App
