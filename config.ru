require File.join(File.dirname(__FILE__), 'app.rb')

station_parser = StationParser.new('http://citibikenyc.com/stations/json')
station_parser.call

run Citibike::App.new