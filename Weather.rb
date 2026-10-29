require 'ruby2d'
require "uri"
require "net/http"
require "json"
require 'os'

set title: 'Weather App'
set width: 800, height: 600
set background: 'Black'
set fps_cap: 60
set icon: 'icon.png'
set close_on_esc: true

$Box = Text.new("Unkown", x: :right, y: :bottom, padding_right: 350) 
$Box.content = <<EOF
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
EOF

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

#puts "Weather for #{weather["resolvedAddress"]}"

$current = weather["currentConditions"]

#puts "Current temperature: #{$current["temp"]}"
#puts "Humidity: #{$current["humidity"]}"
#puts "Conditions: #{$current["conditions"]}"

$weatherdegree = Text.new("30°", x: :right , y: :top, padding_right: 15, padding_top:55 , size: 30) 


def weatherupdate
fahrenheitstr = String("#{$current["temp"]}")
num_int = fahrenheitstr.to_i
fahrenheit = Integer("#{num_int}") * 9/5 + 32
$weatherdegree.content = "#{$current["temp"]}°C | #{fahrenheit}°F"
$weathericon = Text.new("Unkown", y: 150, size: 50)
Dir.chdir("Fonts")
# You NEED a Monospace font
$weathericon.font = "SpaceMono-Regular.ttf"
case $current["conditions"]
when "Cloudy", "Partially cloudy"
  $weathericon.content = <<-'EOF'
     .--.     
  .-(    ).   
 (___.__)__)            
EOF
when "Sunny"
$weathericon.content = <<-'EOF'
  \   /     
   .-.      
― (   ) ―   
   `-’      
  /   \                          
EOF
when "Rainy"
$weathericon.content = <<-'EOF'
   .-.     
  (   ).  
(___(__)  
  ‘ ‘ ‘ ‘  
 ‘ ‘ ‘ ‘                   
EOF
end

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

$systext = Text.new('Unknown', x: :right , y: :bottom, padding_left: 250, padding_bottom: 60 , size: 30)

def systemresources 
  $systext.x = ($Box.x + 30)
  $systext.content = "CPU: \nGPU: \nMem: \nDisk: \nSwp \n"
end

## Time 
##___________________________________________________________________________________________________
$timetext = Text.new('Burhar', x: :right , y: :top, padding_right: 15, padding_top:15 , size: 30)
tick = 0

def updatetime
    time = Time.new
    $timetext.content = time.strftime("%Y-%m-%d %H:%M")
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

show