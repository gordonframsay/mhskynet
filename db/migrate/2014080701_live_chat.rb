class LiveChat < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE authors (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	username varchar(255),
	password varchar(255),
	email_address varchar(255),
	active int2 default 0,
	disabled int2 default 0
);

CREATE TABLE messages (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	message text,
	author_id int4 references authors(id)
);

CREATE INDEX messages_author_id_index on messages(author_id);

}

end

def self.down
  raise "No you can't!"
end

end

