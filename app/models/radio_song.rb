class RadioSong < ActiveRecord::Base

 validate :youtube_identifier_length

 validates_presence_of  :service
 validates_presence_of  :identifier
 validates_presence_of  :session_id
 validates_presence_of  :source_ip
 validates_uniqueness_of :identifier
 validates_inclusion_of :service, :in => ["html5","youtube","vimeo","dailymotion"]

 def self.service_options
  return ["html5","youtube","vimeo","dailymotion"]
 end

 def url
  return "//www.youtube.com/watch?v="+identifier if (service == "youtube")
  return "//player.vimeo.com/video/"+identifier if (service == "vimeo")
  return "//blrrm.tv/"+identifier if (service == "dailymotion")
  return identifier
 end

private

 def vimeo_id_numbers_only
  errors.add(:identifier, "needs to be numbers only for Vimeo videos.") if ((service == "vimeo") && (identifier.match(/[^0-9]/)))
 end

 def duration_non_live_events
  errors.add(:duration, "needs to be greater than zero for non-live events.") unless (live_event? || (duration && (duration > 0)))
 end

 def youtube_identifier_length
  errors.add(:identifier, "needs to be 11 characters long if a Youtube video.") if ((service == "youtube") && identifier && (identifier.length != 11))
 end

end
