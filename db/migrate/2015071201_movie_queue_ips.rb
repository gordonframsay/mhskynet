class MovieQueueIps < ActiveRecord::Migration 

def self.up

 execute %{

ALTER TABLE queued_movies add column source_ip cidr;

}

end

def self.down
  raise "No you can't!"
end

end

