class QueuedMovieNotes < ActiveRecord::Migration 

def self.up

 execute %{

ALTER TABLE queued_movies add column notes text;

}

end

def self.down
  raise "No you can't!"
end

end

