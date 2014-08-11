class HangMan < ActiveRecord::Migration 

def self.up

 execute %{

CREATE TABLE hang_man_games (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	phrase varchar(255),
	letters_guessed varchar(255)
);

}

end

def self.down
  raise "No you can't!"
end

end

