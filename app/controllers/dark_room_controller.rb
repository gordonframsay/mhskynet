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

 def local_cache
  if request.post?
   the_file = params[:picture]
   return false if ((the_file.nil?) || (the_file.size == 0))
   # A couple sanity checks on the name:
   name = the_file.original_filename.gsub('/','')
   name.gsub!(/^\.+(.*)$/,'\1')
   suffix = name.gsub('/','').gsub(/^.*\.(...)$/,'\1').downcase
   the_data = the_file.read
   hash = Digest::MD5.hexdigest(the_data)
   Rails.cache.write("local_cache_"+hash, the_data)
   redirect_to '/dark_room/local_cache/'+hash+'.'+suffix
  end
  if params[:id]
   suffix = (params[:format])
   the_data = Rails.cache.read("local_cache_"+params[:id])
   content_type = "application/octet-stream"
   content_type = "image/jpeg" if (suffix == "jpg")
   content_type = "image/gif"  if (suffix == "gif")
   content_type = "image/png"  if (suffix == "png")
   send_data the_data, :type => content_type, :disposition => 'inline'
  end
 end

end
