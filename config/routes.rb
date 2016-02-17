Rails.application.routes.draw do

   root 'home#index'

   get 'archive' => 'home#archive'

   get 'suggestions' => 'suggestions#index'

   get 'screening_room/change_time_zone' => 'screening_room#change_time_zone', :via => [:get, :post]
   get 'screening_room/schedule_movie(/:screening_room)' => 'screening_room#schedule_movie',:constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]
   get 'screening_room/history(/:screening_room)' => 'screening_room#history',:constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]
   get 'screening_room/change_time_zone' => 'screening_room#change_time_zone', :via => [:get, :post]
   get 'screening_room/currently_playing_moviesign' => 'screening_room#currently_playing_moviesign', :via => [:get, :post]
   get 'screening_room(/:screening_room)' => 'screening_room#index', :constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]

   get 'screening_room/edit(/:id)' => 'screening_room#edit', :via => [:get, :post]
   get 'screening_room/delete(/:id)' => 'screening_room#delete'

   get 'hang_man/game(/:id)' => 'hang_man#game'
   post 'hang_man/game(/:id)' => 'hang_man#game'

   get 'game/:game_id/add_room' => 'game#add_room'
   post 'game/:game_id/add_room' => 'game#add_room'
   get 'game/:game_id/edit_room/:room_id' => 'game#edit_room'
   post 'game/:game_id/edit_room/:room_id' => 'game#edit_room'
   get 'game/:game_id(/:room_id)' => 'game#index'
   post 'game/:game_id(/:room_id)' => 'game#index'
 
   get ':controller(/:action(/:id))', :via => [:get, :post]
   post ':controller(/:action(/:id))', :via => [:get, :post]
 

end
