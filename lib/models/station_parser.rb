require 'pp'
require 'json'
require 'multi_json'
require 'open-uri'

require 'data_mapper'
require 'dm-sqlite-adapter'
require "dm-validations"

require_relative './station'

class StationParser
  def initialize(url)
    @url = url
  end

  def call
    DataMapper.auto_migrate!
    response = Typhoeus.get(@url)

    parsed = JSON.parse(response.body)
    parsed["stationBeanList"].each do |station|
      station_sym = {}
      station.each do |k, v|
        station_sym[k.to_sym] = v
      end
      pp station_sym
      # binding.pry
      Station.create(station_sym)
    end
  end
end
