class Message < ActiveRecord::Base

 belongs_to :author

 validates_presence_of	:author_id

 validates_length_of	:message, :maximum => 400

end
