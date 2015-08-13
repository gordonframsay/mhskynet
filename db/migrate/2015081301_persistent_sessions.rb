class PersistentSessions < ActiveRecord::Migration 

def self.up

 execute %{

 alter table sessions add column persistent int2 default 0;
 update sessions set persistent = 0;

}

end

def self.down
  raise "No you can't!"
end

end

