Rails.application.routes.draw do

   root 'home#index'
   get 'suggestions' => 'suggestions#index'
 
   get ':controller(/:action)'
   post ':controller(/:action)'
 
   get 'hang_man/game(/:id)' => 'hang_man#game'
   post 'hang_man/game(/:id)' => 'hang_man#game'

end
