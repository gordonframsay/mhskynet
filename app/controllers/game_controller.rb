class GameController < ApplicationController


 def index
  @game_room = GameRoom.find(params[:room_id])
# @game = Game.find(params[:game_id])
 end

end
