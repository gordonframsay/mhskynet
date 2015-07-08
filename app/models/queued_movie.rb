class QueuedMovie < ActiveRecord::Base

 validates_presence_of :service
 validates_presence_of :title
 validates_presence_of :start_time
 validates_presence_of :duration
 validates_presence_of :identifier
 validates_inclusion_of :service, :in => ["html5","youtube","vimeo","dailymotion"]

 def url
  return "https://www.youtube.com/watch?v="+identifier if (service == "youtube")
  return "//player.vimeo.com/video/"+identifier if (service == "vimeo")
  return identifier
 end

end
