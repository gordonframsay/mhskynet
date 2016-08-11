class PersistentAttachments < ActiveRecord::Migration 

# NOTE: Technically, this isn't Kosher.  Files belong in a filing system, not in a database.
#       But, we're on a virtual server that can have the files not in version control
#       wiped out occationally.  Plus, the site isn't high traffic.


def self.up

 execute %{

  CREATE TABLE cached_files (
        id serial primary key,
        created_at timestamp ,
        updated_at timestamp ,
	md5_hash char(32),
	original_url varchar(255),
	is_upload int2,
	ip_address inet,
	title varchar(255),
	mime_type varchar(255),
	data bytea,
	active int2 default 1,
	accessed_count int4 default 0
  );

  CREATE INDEX cached_files_md5_hash_index on cached_files(md5_hash);

}
end

def self.down
  raise "No you can't!"
end

end

