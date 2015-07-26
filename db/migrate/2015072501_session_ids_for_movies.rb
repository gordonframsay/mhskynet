class SessionIdsForMovies < ActiveRecord::Migration 

def self.up

 execute %{

alter table queued_movies add column session_id varchar(255);

}

end

def self.down
  raise "No you can't!"
end

end

