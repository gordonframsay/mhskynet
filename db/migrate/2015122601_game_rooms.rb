class GameRooms < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE game_rooms (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	game_id int4,
	title varchar(255),
	image_url varchar(512),
	north_room_id int4,
	east_room_id int4,
	west_room_id int4,
	south_room_id int4,
	other_room_id int4,
	description text
);

}

end

def self.down
  raise "No you can't!"
end

end

