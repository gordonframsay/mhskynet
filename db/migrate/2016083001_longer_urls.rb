class LongerUrls < ActiveRecord::Migration 

def self.up

 execute %{

  ALTER TABLE cached_files rename column original_url to original_url_old;
  ALTER TABLE cached_files add column original_url varchar(1024);
  UPDATE TABLE cached_files set original_url = original_url_old;
  ALTER TABLE cached_files drop column original_url_old;

}
end

def self.down
  raise "No you can't!"
end

end

