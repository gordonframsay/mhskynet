class GameRoom < ActiveRecord::Base

 validates_presence_of	:game_id
 validates_presence_of	:title
 validates_presence_of	:description
 validates_presence_of	:image_url

end
