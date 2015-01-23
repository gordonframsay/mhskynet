class IpFiltering < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE blocked_ips (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	address cidr,
	reason varchar(255)
);

CREATE TABLE cached_ips (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	address cidr,
	blocked int2,
	reason varchar(255)
);

}

end

def self.down
  raise "No you can't!"
end

end

