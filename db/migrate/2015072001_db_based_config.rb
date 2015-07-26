class DbBasedConfig < ActiveRecord::Migration 


# This lets us put site specific secrets/config in the DB instead of in the public code

def self.up

 execute %{

CREATE TABLE site_defaults (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	key_name varchar(255),
	description text,
	key_value varchar(255),
	key_type varchar(255)
);


}

end

def self.down
  raise "No you can't!"
end

end

