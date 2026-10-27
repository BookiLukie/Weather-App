require 'ruby2d'
require "uri"
require "net/http"
require "json"
require 'os'

#Image.new('clear.png')
set title: 'Cool ass weather app'
set width: 800, height: 600
set background: 'Black'
set fps_cap: 60
set icon: 'icon.png'
set close_on_esc: true

## Weather 
## __________________________________________________________

#$WeatherImage = Image.new("Clear.png", x:100 , y: 100) 
$weathertick = 0
api_key = ENV["VISUAL_CROSSING_API_KEY"]

if api_key.nil? || api_key.empty?
  raise "VISUAL_CROSSING_API_KEY is not set"
end

location = "Wellington, New Zealand"

base_url =
  "https://weather.visualcrossing.com/" \
  "VisualCrossingWebServices/rest/services/timeline/" \
  "#{URI.encode_www_form_component(location)}"

params = {
  key: api_key,
  unitGroup: "metric",
  include: "current",
  elements: "tempmax,tempmin,precip,conditions,temp,humidity",
  contentType: "json"
}

uri = URI(base_url)
uri.query = URI.encode_www_form(params)

http = Net::HTTP.new(uri.host, uri.port)

http.use_ssl = true
http.open_timeout = 10
http.read_timeout = 20

request = Net::HTTP::Get.new(uri)

response = http.request(request)

unless response.is_a?(Net::HTTPSuccess)
  raise "Weather API request failed " \
        "(#{response.code}): #{response.body}"
end

weather = JSON.parse(response.body)

puts weather

puts "Weather for #{weather["resolvedAddress"]}"

$current = weather["currentConditions"]

puts "Current temperature: #{$current["temp"]}"
puts "Humidity: #{$current["humidity"]}"
puts "Conditions: #{$current["conditions"]}"

$weatherdegree = Text.new("30°", x: :right , y: :top, padding_right: 15, padding_top:55 , size: 30) 


def weatherupdate
fahrenheitstr = String("#{$current["temp"]}")
num_int = fahrenheitstr.to_i
fahrenheit = Integer("#{num_int}") * 9/5 + 32
$weatherdegree.content = "#{$current["temp"]}°C | #{fahrenheit}°F"
#$WeatherImage.path ="#{$current["conditions"]}.png"
puts "#{$current["conditions"]}.png"

end


## Power and System Resources 
#___________________________________________________________________________________________________
def powerupdate 
powertext = Text.new('Unknown', x: :right , y: :bottom, padding_right: 15, padding_bottom:15 , size: 30)
if OS.mac? == true 
    output = `pmset -g batt`
  #i dont know how this command prints out since i dont have a mac, so i cant figure out how to format this correctly. Same with linux but i don't know the command
end
if OS.windows? == true
  output = `powershell -Command "Get-CimInstance Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining"` 
  percentage = output.strip.to_i
  powertext.content = "#{percentage}%"
end
end

def systemresources 
  text = Text.new('Unknown', x: :right , y: :bottom, padding_right: 250, padding_bottom: 60 , size: 30)
  text.content = "CPU: \nGPU: \nMem: \nDisk: \nSwp \n"

end
## Time 
##___________________________________________________________________________________________________
$timetext = Text.new('Burhar', x: :right , y: :top, padding_right: 15, padding_top:15 , size: 30)
tick = 0

def updatetime
    time = Time.now.asctime
    $timetext.content = time
end

$powertick = 0
update do
  if tick % 60 == 0
    updatetime
    systemresources
  end
  if $weathertick % 216000 == 0
      puts "#{$weathertick}"
      weatherupdate
  end
  if $powertick % 18000 == 0
      powerupdate
  end
  tick += 1
  $weathertick += 1
  $powertick += 1
end

Rectangle.new(x: :right, y: :bottom, width: 350, height: 590, fill: false, stroke_width: 3, stroke_color: 'white')

show