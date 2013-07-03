require 'rubygems'
require 'sinatra'

require 'data_mapper'
require 'dm-sqlite-adapter'
require 'dm-validations'

require 'typhoeus'
require 'pry-debugger'

require './environment'


DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/stations.db")
DataMapper::Model.raise_on_save_failure = true

module Citibike
	class App < Sinatra::Application

    before do
      @stations = Station.all
    end

    get '/' do
      erb :home
    end

    get '/form' do
      erb :form
    end

    get '/map' do
      erb :map
    end

    post '/map' do
      puts params[:start]
      @start = params[:start][1..-2].split(", ")[0..1].collect{|x| x.to_f}
      @end     = params[:end][1..-2].split(", ")[0..1].collect{|x| x.to_f}
      @mid  = [ (@start[0]+@end[0])/2, (@start[1]+@end[1])/2 ]

      @start_name = params[:start][1..-2].split(", ")[2][1..-2]
      @end_name   = params[:end][1..-2].split(", ")[2][1..-2]
      erb :'map'
    end



    get '/stations' do
      @stations = Station.all
      erb :'stations/index'
    end

    get '/stations/new' do
      @station = Station.new
      erb :'stations/new'
    end

    post '/stations' do
    @station = Station.new(params[:station])
    if @station.save
      status 201
      redirect '/stations/' + @station.id.to_s
    else
      status 404
      erb :'stations/new'
      end
    end


    get '/stations/edit/:id' do
      @station = Station.get(params[:id])
      erb :'stations/edit'
    end


    put '/stations/:id' do
      @station = Station.get(params[:id])
      if @station.update(params[:station])
        redirect '/stations/' + params[:id]
      else
        status 400
        erb :'stations/edit'
      end
    end


    get '/stations/delete/:id' do 
      @station = Station.get(params[:id])
      erb :'stations/delete'
    end


    delete '/stations/:id' do
      Station.get(params[:id]).destroy
      redirect '/stations'
    end


    get '/stations/:id' do
      @station = Station.get(params[:id])
      erb :'stations/show'
    end


    helpers do
      def partial(view)
        erb view, :layout => false
      end
    end

    DataMapper.auto_upgrade!

  end
end