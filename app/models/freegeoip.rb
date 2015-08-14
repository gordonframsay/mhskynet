class Freegeoip

 # Simple class to do IP to physical location lookups using Freegeoip ( https://github.com/fiorix/freegeoip )
 # You need access to a running instance of Freegoip server and have the freegeoip_server config with the server:port, e.g. "localhost:8080"

 include ApplicationHelper

 attr_accessor :ip_address
 attr_accessor :country_abbr
 attr_accessor :country
 attr_accessor :state_abbr
 attr_accessor :state
 attr_accessor :city
 attr_accessor :zipcode
 attr_accessor :time_zone
 attr_accessor :lat
 attr_accessor :long
 attr_accessor :metro_code


 def clear
  @ip_address = @country_abbr = @country = @state_abbr = @state = @city = @zipcode = @time_zone = @lat = @long = @metro_code = ""
 end

 def find(address) # address is just the string of the IP address, e.g "1.2.3.4"
  if (tmp = Rails.cache.read("free_geoip_"+address))
   @ip_address, @country_abbr, @country, @state_abbr, @state, @city, @zipcode, @time_zone, @lat, @long, @metro_code = tmp
   return tmp
  else
   the_server = get_config("freegeoip_server")
   query = "http://"+the_server+"/csv/"+address
   c = Curl::Easy.perform(query)
   tmp = c.body.chomp.split(",")
   @ip_address, @country_abbr, @country, @state_abbr, @state, @city, @zipcode, @time_zone, @lat, @long, @metro_code = tmp
   Rails.cache.write("free_geoip_"+address, tmp)
  end
 end

end
