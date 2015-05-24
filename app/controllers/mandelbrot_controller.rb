class MandelbrotController < ApplicationController

 def index
  @x = (params[:center_x])?(params[:center_x].to_d):-0.746
  @y = (params[:center_y])?(params[:center_y].to_d):0.21065
  @zoom = (params[:zoom])?(params[:zoom].to_i):200000
  @max_iter = (params[:max_iter])?(params[:max_iter].to_i):120
  @antialias = (params[:antialias])?(params[:antialias].to_d):1
 end

end
