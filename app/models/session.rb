class Session < ActiveRecord::Base

  def self.clean_up
   destroy_all(["updated_at < ?", Time.now - 60 * 60 * 24 * 4])
  end

end

