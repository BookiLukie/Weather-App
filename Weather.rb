require 'ruby2d'
require "uri"
require "net/http"
require "json"
#Image.new('clear.png')
set title: 'Cool ass weather app'
set width: 800, height: 600
set background: 'Black'
set fps_cap: 60
set icon: 'icon.png'
set close_on_esc: true

## Weather 
## __________________________________________________________
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

## fix later
def weatherupdate
##$img = Image.new('#{$current["conditions"]}.png')
$weatherdegree.content = "#{$current["temp"]}"
end

## Time 
##___________________________________________________________________________________________________
$timetext = Text.new('Burhar', x: :right , y: :top, padding_right: 15, padding_top:15 , size: 30)
tick = 0

def updatetime
    time = Time.now.asctime
    $timetext.content = time
end

update do
  if tick % 60 == 0
    updatetime
  end
  if $weathertick % 3600 == 0
      weatherupdate
  end
  tick += 1
  $weathertick += 1
end

Rectangle.new(x: :right, y: :bottom, width: 350, height: 590, fill: false, stroke_width: 3, stroke_color: 'white')

show