class GameController < ApplicationController

 before_action :check_login, :only => [:add_room, :edit_room]

 def index
  @game_room = GameRoom.find(params[:room_id])
# @game = Game.find(params[:game_id])
 end

 def add_room
  @room = GameRoom.new
  @room.game_id = params[:game_id]
  if (params[:from] && params[:dir]) # NOTE: Default the backward link to the source
   @room.south_room_id = params[:from] if (params[:dir] == "north")
   @room.west_room_id  = params[:from] if (params[:dir] == "east")
   @room.east_room_id  = params[:from] if (params[:dir] == "west")
   @room.north_room_id = params[:from] if (params[:dir] == "south")
  end
  if request.post?
   @room = GameRoom.new(params[:room].permit(@room.attributes.keys - ["id","created_at","updated_at"]))
   if @room.save
    if (params[:from] && params[:dir]) # NOTE: Add a source link to the new room.
     source_gr = GameRoom.find(params[:from])
     source_gr.north_room_id = @room.id if ((params[:dir] == "north") && (source_gr.north_room_id.nil?))
     source_gr.east_room_id = @room.id if ((params[:dir] == "east") && (source_gr.east_room_id.nil?))
     source_gr.west_room_id = @room.id if ((params[:dir] == "west") && (source_gr.west_room_id.nil?))
     source_gr.south_room_id = @room.id if ((params[:dir] == "south") && (source_gr.south_room_id.nil?))
     source_gr.save!
     flash[:notice] = "Saved and linked previous room to this one!"
    else
     flash[:notice] = "Saved!"
    end
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

end
