require 'rubygems'
require 'sinatra'

require 'data_mapper'
require 'dm-sqlite-adapter'
require 'dm-validations'

require 'typhoeus'
require 'pry-debugger'

require './environment'


DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/stations.db")
# DataMapper::Model.raise_on_save_failure = true

module Citibike
	class App < Sinatra::Application

    before do
      @stations = Station.all
      @num_st = Station.count
    end

    get '/' do
      erb :home
    end


    # Directions
    
    get '/direction' do
      erb :direction
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
      @end_name   =   params[:end][1..-2].split(", ")[2][1..-2]

      @start_id = params[:start][1..-2].split(", ")[3]
      @end_id   =   params[:end][1..-2].split(", ")[3]

      erb :'map'
    end


    # Index Stations

    get '/stations' do
      @stations = Station.all
      erb :'stations/index'
    end


    # Create Station

    get '/stations/new' do
      @station = Station.new
      erb :'stations/new'
    end

    post '/stations' do
      puts "this should output"
      @station = Station.new(params[:station])
      if @station.save
        status 201
        puts @station.id
        redirect '/stations/' + @station.id.to_s
      else
        status 404
        erb :'stations/new'
      end
    end


    # Update Station

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


    # Destroy Station

    get '/stations/delete/:id' do 
      @station = Station.get(params[:id])
      erb :'stations/delete'
    end

    delete '/stations/:id' do
      Station.get(params[:id]).destroy
      redirect '/stations'
    end


    # Read Station

    get '/stations/:id' do
      @station = Station.get(params[:id])
      erb :'stations/show'
    end


    helpers do
      def partial(view)
        erb view, :layout => false
      end

      def adv_partial(template,locals=nil)
        if template.is_a?(String) || template.is_a?(Symbol)
          template=('_' + template.to_s).to_sym
        else
          locals=template
          template=template.is_a?(Array) ? ('_' + template.first.class.to_s.downcase).to_sym : ('_' + template.class.to_s.downcase).to_sym
        end
        if locals.is_a?(Hash)
          erb(template,{:layout => false},locals)      
        elsif locals
          locals=[locals] unless locals.respond_to?(:inject)
          locals.inject([]) do |output,element|
            output <<     erb(template,{:layout=>false},{template.to_s.delete("_").to_sym => element})
          end.join("\n")
        else 
          erb(template,{:layout => false})
        end
      end
    end

    DataMapper.auto_upgrade!

  end
end