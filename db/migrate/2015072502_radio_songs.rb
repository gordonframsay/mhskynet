class RadioSongs < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE radio_songs (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	identifier varchar(255),
	service varchar(255) default 'youtube',
	session_id varchar(255),
	source_ip cidr
);

}

end

def self.down
  raise "No you can't!"
end

end

