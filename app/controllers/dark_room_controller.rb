class DarkRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - Dark Room"
 end

 def mirror
  if params[:id]
   c = Curl::Easy.perform(params[:id])
   send_data c.body, :type => c.content_type, :disposition => 'inline'
  end
 end

end
