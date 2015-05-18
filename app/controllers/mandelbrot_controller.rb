class MandelbrotController < ApplicationController

 def index
  @x = -0.746
  @y = 0.21065
  @zoom = 200000
  @max_iter = 120
  @antialias = 1.0
 end

end
