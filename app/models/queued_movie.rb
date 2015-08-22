class QueuedMovie < ActiveRecord::Base

 validate :start_time_cannot_be_in_the_past, :movies_can_not_overlap, :youtube_identifier_length, :duration_non_live_events, :vimeo_id_numbers_only, :html5_should_begin_with_http

 validates_presence_of :service
 validates_presence_of :title
 validates_presence_of :start_time
 validates_presence_of :duration
 validates_presence_of :identifier
 validates_presence_of :live_event
 validates_presence_of :notes
 validates_presence_of :screening_room
 validates_inclusion_of :service, :in => ["html5","youtube","vimeo","dailymotion"]
 validates_numericality_of :duration, :only_integer => true, :greater_than_or_equal_to => 0
 validates_numericality_of :screening_room, :only_integer => true, :greater_than_or_equal_to => 1
 validates_numericality_of :live_event, :only_integer => true
 validates_numericality_of :terms, :equal_to => 1, :message => "must be accepted."

 def formatted_duration
  hours = duration / (60 * 60)
  minutes = (duration / 60) % 60
  seconds = duration % 60
  return (hours.to_s)+":"+(minutes.to_s.rjust(2,"0"))+":"+(seconds.to_s.rjust(2,"0"))
 end

 def self.service_options
  return ["html5","youtube","vimeo","dailymotion"]
 end

 def url(with_timestamp = false)
  if (with_timestamp && (start_time < Time.now))
   return "//www.youtube.com/watch?v="+identifier+"?t="+((Time.now - start_time).round.to_s)+"s" if (service == "youtube")
  else
   return "//www.youtube.com/watch?v="+identifier if (service == "youtube")
  end
  return "//player.vimeo.com/video/"+identifier if (service == "vimeo")
  return "//blrrm.tv/"+identifier if (service == "dailymotion")
  return identifier
 end

 def unmarshalled_google_user_token
  return nil unless marshalled_google_user_token
  return Marshal.load(marshalled_google_user_token)
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

 def movies_can_not_overlap
  if new_record?
   if (start_time.present? && duration.present?)
    finish_time = start_time.gmtime + duration
    errors.add(:start_time, "can't overlap with another event (1)") and return unless QueuedMovie.where(["screening_room = ? AND start_time >= ? AND start_time <= ?", screening_room, start_time.gmtime, finish_time.gmtime]).empty?
    errors.add(:start_time, "can't overlap with another event (2)") and return unless QueuedMovie.where(["screening_room = ? AND start_time + (duration * interval '1 second') >= ? AND start_time + (duration * interval '1 second') <= ?", screening_room, start_time.gmtime, finish_time]).empty?
    errors.add(:start_time, "can't overlap with another event (3)") and return unless QueuedMovie.where(["screening_room = ? AND start_time <= ? AND start_time + (duration * interval '1 second') >= ?", screening_room, start_time.gmtime, finish_time]).empty?
   end
  else
   if (start_time.present? && duration.present?)
    finish_time = start_time + duration
    errors.add(:start_time, "can't overlap with another event (4)") and return unless QueuedMovie.where(["screening_room = ? AND start_time >= ? AND start_time <= ? AND id != ?", screening_room, start_time.gmtime, finish_time.gmtime, id]).empty?
    errors.add(:start_time, "can't overlap with another event (5)") and return unless QueuedMovie.where(["screening_room = ? AND start_time + (duration * interval '1 second') >= ? AND start_time + (duration * interval '1 second') <= ? AND id != ?", screening_room, start_time.gmtime, finish_time, id]).empty?
    errors.add(:start_time, "can't overlap with another event (6)") and return unless QueuedMovie.where(["screening_room = ? AND start_time <= ? AND start_time + (duration * interval '1 second') >= ? AND id != ?", screening_room, start_time.gmtime, finish_time, id]).empty?
   end
  end
 end

 def start_time_cannot_be_in_the_past
  if (new_record? && start_time.present? && (start_time < Time.now))
   errors.add(:start_time, "can't be in the past") 
  end
 end

 def html5_should_begin_with_http
  errors.add(:identifier, "HTML5 media needs to begin with http... to be an absolute link.") if ((service == "html5") && (! identifier.match(/^[hH][tT][tT][pP]/)))
 end

end
