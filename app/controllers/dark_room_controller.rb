class DarkRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - Dark Room"
 end

 def mirror
  if params[:id]
   c = Curl::Easy.perform(params[:id])
   the_data = c.body
   # TODO: The suffix to mime-type mapping isn't very DRY see local_cache below.
   suffix = "jpg" if (c.content_type == "image/jpeg")
   suffix = "gif" if (c.content_type == "image/gif")
   suffix = "png" if (c.content_type == "image/png")
   if (the_data.length > 1000000) # NOTE: Larger than 1MB isn't supported by Disqus
    flash[:notice] = "Larger than 1MB is not supported."
    return false
   end
   hash = Digest::MD5.hexdigest(the_data)
   Rails.cache.write("local_cache_"+hash, the_data) unless Rails.cache.exist?("local_cache_"+hash)
   redirect_to '/dark_room/local_cache/'+hash+'.'+suffix
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
   if (the_data.length > 1000000) # NOTE: Larger than 1MB isn't supported by Disqus
    flash[:notice] = "Larger than 1MB is not supported."
    return false
   end
   hash = Digest::MD5.hexdigest(the_data)
   Rails.cache.write("local_cache_"+hash, the_data) unless Rails.cache.exist?("local_cache_"+hash)
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
