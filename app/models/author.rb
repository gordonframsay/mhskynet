class Author < ActiveRecord::Base

 has_many :messages

 validates_length_of           :username,  :in=> 4..20


end
