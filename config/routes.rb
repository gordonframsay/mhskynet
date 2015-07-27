Rails.application.routes.draw do

   root 'home#index'
   get 'suggestions' => 'suggestions#index'

   get 'screening_room' => 'screening_room#index', :via => [:get, :post]
   get 'screening_room/schedule_movie' => 'screening_room#schedule_movie', :via => [:get, :post]

   get 'screening_room/edit(/:id)' => 'screening_room#edit', :via => [:get, :post]
   get 'screening_room/delete(/:id)' => 'screening_room#delete'
 
   get ':controller(/:action)', :via => [:get, :post]
   post ':controller(/:action)', :via => [:get, :post]
 
   get 'hang_man/game(/:id)' => 'hang_man#game'
   post 'hang_man/game(/:id)' => 'hang_man#game'

end
