class GameController < ApplicationController

 before_filter :check_login, :only => [:add_room, :edit_room]

 def index
  @game_room = GameRoom.find(params[:room_id])
# @game = Game.find(params[:game_id])
 end

 def add_room
  @room = GameRoom.new
  @room.game_id = params[:game_id]
  if request.post?
   @room = GameRoom.new(params[:room].permit(@room.attributes.keys - ["id","created_at","updated_at"]))
   if @room.save
    flash[:notice] = "Saved!"
    @room = GameRoom.new
    redirect_to "/game/"+params[:game_id]+"/"+(@room.id.to_s)
   else
    flash[:notice] = "Please fix before continuing: "+@room.errors.full_messages.to_sentence
   end
  end
 end

 def edit_room
  @room = GameRoom.find(params[:room_id])
  if request.post?
   if @room.update(params[:room].permit(@room.attributes.keys - ["id","created_at","updated_at"]))
    flash[:notice] = "Saved!"
    redirect_to "/game/"+params[:game_id]+"/"+(@room.id.to_s)
   else
    flash[:notice] = "Please fix before continuing: "+@room.errors.full_messages.to_sentence
   end
  end
 end

 # TODO: Could be DRYer.  See the Admin controller.
 private

 def check_login
  unless session[:superuser]
   redirect_to '/account/admin_login'
   return false
  end
 end

end
