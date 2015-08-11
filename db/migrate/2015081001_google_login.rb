class GoogleLogin < ActiveRecord::Migration 

def self.up

 execute %{

 alter table queued_movies add column marshalled_google_user_token text;

}

end

def self.down
  raise "No you can't!"
end

end

