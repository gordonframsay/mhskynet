class MovieQueue < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE queued_movies (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	identifier varchar(255),
	service varchar(255),
	title varchar(255),
	preview_image_url varchar(512),
	start_time timestamp,
	duration int4
);

}

end

def self.down
  raise "No you can't!"
end

end

