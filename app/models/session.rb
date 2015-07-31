class Session < ActiveRecord::Base

  def self.clean_up
   destroy_all(["updated_at < ?", Time.now.gmtime - 60 * 60 * 24 * 14])
  end

end

