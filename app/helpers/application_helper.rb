module ApplicationHelper
 require 'base64'
 require 'cgi'
 require 'openssl'
 require "json"
 
 def get_disqus_sso(user)
    # create a JSON packet of our data attributes
    data = 	{
      'id' => user[:id],
      'username' => user[:username],
      'email' => user[:email]
	  #'avatar' => user[:avatar],
	  #'url' => user[:url]
    }.to_json
 
    # encode the data to base64
    message  = Base64.encode64(data).gsub("\n", "")
    # generate a timestamp for signing the message
    timestamp = Time.now.to_i
    # generate our hmac signature
    sig = OpenSSL::HMAC.hexdigest('sha1', DISQUS_SECRET_KEY, '%s %s' % [message, timestamp])
 
    # return a script tag to insert the sso message
    return ("<script type=\"text/javascript\">
        var disqus_config = function() {
            this.page.remote_auth_s3 = \"#{message} #{sig} #{timestamp}\";
            this.page.api_key = \"#{DISQUS_PUBLIC_KEY}\";
        }
	</script>").html_safe
 end

 def available_time_zones
  return"Pacific Time (US & Canada)","Mountain Time (US & Canada)","Central Time (US & Canada)","Eastern Time (US & Canada)","Atlantic Time (Canada)","Newfoundland"
 end

 def formatted_duration(duration)
  hours = duration / (60 * 60)
  minutes = (duration / 60) % 60
  seconds = duration % 60
  return (hours.to_s)+":"+(minutes.to_s.rjust(2,"0"))+":"+(seconds.to_s.rjust(2,"0"))
 end

end
