class MoreLegal < ActiveRecord::Migration 

def self.up

 execute %{

 alter table queued_movies add column terms int2;
 update queued_movies set terms = 0;

}

end

def self.down
  raise "No you can't!"
end

end

