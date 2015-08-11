class GoogleLoginIi < ActiveRecord::Migration 

def self.up

 execute %{

 alter table queued_movies drop column marshalled_google_user_token;
 alter table queued_movies add column marshalled_google_user_token bytea;

}

end

def self.down
  raise "No you can't!"
end

end

