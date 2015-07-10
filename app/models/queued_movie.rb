class QueuedMovie < ActiveRecord::Base

 validate :start_time_cannot_be_in_the_past, :movies_can_not_overlap

 validates_presence_of :service
 validates_presence_of :title
 validates_presence_of :start_time
 validates_presence_of :duration
 validates_presence_of :identifier
 validates_presence_of :live_event
 validates_inclusion_of :service, :in => ["html5","youtube","vimeo","dailymotion"]
 validates_numericality_of :duration, :only_integer => true, :greater_than_or_equal_to => 0
 validates_numericality_of :live_event, :only_integer => true

 def service_options
  return ["html5","youtube","vimeo","dailymotion"]
 end

 def url
  return "//www.youtube.com/watch?v="+identifier if (service == "youtube")
  return "//player.vimeo.com/video/"+identifier if (service == "vimeo")
  return "//blrrm.tv/"+identifier if (service == "dailymotion")
  return identifier
 end

private

 def movies_can_not_overlap
  if (start_time.present? && duration.present?)
   finish_time = start_time + duration
   errors.add(:start_time, "can't overlap with another event (1)") and return unless QueuedMovie.where(["start_time >= ? AND start_time + (duration * interval '1 second') <= ?", start_time, start_time]).empty?
   errors.add(:start_time, "can't overlap with another event (2)") and return unless QueuedMovie.where(["start_time >= ? AND start_time + (duration * interval '1 second') <= ?", finish_time, finish_time]).empty?
   errors.add(:start_time, "can't overlap with another event (3)") and return unless QueuedMovie.where(["start_time <= ? AND start_time + (duration * interval '1 second') >= ?", start_time, finish_time]).empty?
  end
 end

 def start_time_cannot_be_in_the_past
  if (new_record? && start_time.present? && (start_time < Time.now))
   errors.add(:start_time, "can't be in the past") 
  end
 end

end
