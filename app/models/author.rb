class Author < ActiveRecord::Base

 has_many :messages

 validates_length_of           :name,  :in=> 4..20


end
