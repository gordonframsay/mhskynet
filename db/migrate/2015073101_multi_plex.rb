class MultiPlex < ActiveRecord::Migration 

def self.up

 execute %{

 alter table queued_movies add column screening_room int4 default 1;
 update queued_movies set screening_room = 1;

}

end

def self.down
  raise "No you can't!"
end

end

