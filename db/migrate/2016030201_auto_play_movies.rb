class AutoPlayMovies < ActiveRecord::Migration 

# NOTE: Play movies immediately regardless of scheduling time.  Mostly for placeholder items.
#       Similar to live event, but doesn't wait for the start time.

def self.up

 execute %{

 alter table queued_movies add column auto_play_now int2 default 0;
 update queued_movies set auto_play_now = 0;

}

end

def self.down
  raise "No you can't!"
end

end

