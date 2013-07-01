require 'rubygems'
require 'bundler'

Bundler.require

Dir.glob('./lib/*.rb') do |model|
  require model
end

module Citibike
	class App < Sinatra::Application

    before do
      json = File.open("data/citibikenyc.json").read
      @data = MultiJson.load(json)
    end

    # use Rack::Webconsole

    get '/' do
      erb :home
    end

    get '/form' do
      erb :form
    end

    post '/route' do
      erb :route
    end

    get '/map' do
      erb :map
    end

    post '/map' do
      puts params[:start]
      @start = params[:start][1..-2].split(", ")[0..1].collect{|x| x.to_f / 1e6}
      @end     = params[:end][1..-2].split(", ")[0..1].collect{|x| x.to_f / 1e6}
      @mid  = [ (@start[0]+@end[0])/2, (@start[1]+@end[1])/2 ]

      @start_name = params[:start][1..-2].split(", ")[2][1..-2]
      @end_name   = params[:end][1..-2].split(", ")[2][1..-2]
      erb :map
    end

  end
end