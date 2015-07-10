class MovieLiveEvents < ActiveRecord::Migration 

def self.up

 execute %{

 alter table queued_movies add column live_event int2 default 0;
 update queued_movies set live_event = 0;

}

end

def self.down
  raise "No you can't!"
end

end

