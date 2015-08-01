Rails.application.routes.draw do

   root 'home#index'
   get 'suggestions' => 'suggestions#index'

   get 'screening_room/change_time_zone' => 'screening_room#change_time_zone', :via => [:get, :post]
   get 'screening_room/schedule_movie(/:screening_room)' => 'screening_room#schedule_movie',:constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]
   get 'screening_room/history(/:screening_room)' => 'screening_room#history',:constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]
   get 'screening_room/change_time_zone' => 'screening_room#change_time_zone', :via => [:get, :post]
   get 'screening_room/currently_playing_moviesign' => 'screening_room#currently_playing_moviesign', :via => [:get, :post]
   get 'screening_room(/:screening_room)' => 'screening_room#index', :constraints => { :screening_room => (1..10).to_a }, :via => [:get, :post]

   get 'screening_room/edit(/:id)' => 'screening_room#edit', :via => [:get, :post]
   get 'screening_room/delete(/:id)' => 'screening_room#delete'
 
   get ':controller(/:action(/:id))', :via => [:get, :post]
   post ':controller(/:action(/:id))', :via => [:get, :post]
 
   get 'hang_man/game(/:id)' => 'hang_man#game'
   post 'hang_man/game(/:id)' => 'hang_man#game'

end
