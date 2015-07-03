class ScreeningRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - "  + @movie_title
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @meta_refresh_times = []
#  @meta_refresh_times << (@movie_time - Time.now).round if (@movie_time > Time.now)
#  @meta_refresh_times << (@movie_time - Time.now + @movie_length).round if ((@movie_time + @movie_length) < Time.now)
 end

end
