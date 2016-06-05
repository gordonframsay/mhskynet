class DarkRoomController < ApplicationController

 before_filter :set_page_title

 def mirror
  if params[:id]
   c = Curl::Easy.perform(params[:id])
   the_data = c.body
   # TODO: The suffix to mime-type mapping isn't very DRY see local_cache below.
   suffix = MIME::Types[c.content_type].first.preferred_extension
   hash = store_file(the_data)
   return false unless hash
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
   hash = store_file(the_data)
   return false unless hash
   redirect_to '/dark_room/local_cache/'+hash+'.'+suffix
  end
  if params[:id]
   suffix = (params[:format])
   the_data = Rails.cache.read("local_cache_"+params[:id])
   content_type = Mime::Type.lookup_by_extension(suffix).to_s
   send_data the_data, :type => content_type, :disposition => 'inline'
  end
 end

 private

 def store_file(the_data)
  if (the_data.length > 200000) # NOTE: This is a bit arbitrary
   flash[:notice] = "Larger than 1MB is not supported."
   return false
  end
  hash = Digest::MD5.hexdigest(the_data)
  Rails.cache.write("local_cache_"+hash, the_data) unless Rails.cache.exist?("local_cache_"+hash)
  return hash
 end

 def set_page_title
  @page_title =  @page_title + " - Dark Room"
  @page_title += " - "+(params[:action].titleize) if (params[:action] != "index")
 end

end
