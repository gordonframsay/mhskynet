class Session < ActiveRecord::Base

  def self.clean_up
   Session.where(["updated_at < ? AND persistent = 0", Time.now.gmtime - 60 * 60 * 24 * 7]).destroy_all
  end

  # A convenience for manually fetched sessions
  def decoded_session_data
   return Marshal.load(Base64.decode64(data))
  end

end

