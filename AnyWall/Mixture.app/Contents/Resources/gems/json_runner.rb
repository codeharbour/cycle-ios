require 'json'
require 'json/pure'

jsonFile = ARGV[0]
file = File.open(jsonFile, "rb")
json = file.read

begin
    modelObject = JSON.parse json
    puts modelObject

rescue StandardError
    $stderr.print $!
    
end