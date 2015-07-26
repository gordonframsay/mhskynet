class SiteDefault < ActiveRecord::Base

 validates_presence_of	:key_name
 validates_presence_of	:description
 validates_presence_of	:key_value
 validates_presence_of	:key_type

end
