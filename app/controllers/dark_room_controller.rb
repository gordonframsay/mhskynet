class DarkRoomController < ApplicationController

 before_filter :set_page_title


 def test_exception
  raise "THIS IS A TEST EXCEPTION"
 end

 def mirror
  if params[:id]
   c = Curl::Easy.perform(params[:id])
   the_data = c.body
   # TODO: The suffix to mime-type mapping isn't very DRY see local_cache below.
   suffix = MIME::Types[c.content_type].first.preferred_extension
   hash = store_file(the_data, params[:id], false, c.content_type)
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
   suffix = name.gsub('/','').gsub(/^.*\.([a-zA-Z0-9]+)$/,'\1').downcase
   the_data = nil
   # Let's rotate orientation as needed and strip EXIF info.
   if ["jpg","jpeg"].include?(suffix)
    the_data = MiniMagick::Image.read(the_file.read).auto_orient.strip.to_blob
   else
    the_data = the_file.read
   end
   hash = store_file(the_data, the_file.original_filename, true, Mime::Type.lookup_by_extension(suffix).to_s)
   return false unless hash
   if ["gif","jpg","jpeg","png"].include?(suffix)
    redirect_to '/dark_room/local_cache/'+hash+'.'+suffix
   else
    url = "http://"+request.host+"/dark_room/local_cache/"+hash+"."+suffix
    render :inline => "Use this URL to access the file: <a href=\""+url+"\">"+url+"</a>"
   end
  end
  if params[:id]
   suffix = (params[:format])
   the_file = CachedFile.find_by_md5_hash(params[:id])
   unless the_file
    logger.warn "File "+params[:id]+" not found. (cache might have expired.)"
    render :inline => "Not found", :status => 404, :content_type => 'text/plain'
    return false
   end
   the_file.accessed_count += 1
   the_file.save!
   the_data = the_file.data
   mime_type = the_file.mime_type
   logger.warn "Image "+params[:id]+" referrer: "+request.referer if request.referer
   mime_type = "application/x-mpegURL" if (suffix == "m3u8")
   send_data the_data, :type => mime_type, :disposition => 'inline'
  end
 end

 private

 def store_file(the_data, original_url, is_upload, mime_type)
  if (the_data.length > 10000000) # NOTE: This is a bit arbitrary
   flash[:notice] = "Larger than 10MB is not supported."
   return false
  end
  hash = Digest::MD5.hexdigest(the_data)
  CachedFile.new(:md5_hash => hash, :original_url => original_url, :is_upload => (is_upload)?1:0, :ip_address => request.remote_ip, :title => original_url, :original_url => original_url, :mime_type => mime_type, :data => the_data).save!
  return hash
 end

 def set_page_title
  @page_title =  @page_title + " - Dark Room"
  @page_title += " - "+(params[:action].titleize) if (params[:action] != "index")
 end

end
