module Ruby2D
class Graphic
  attr_reader :z
  attr_accessor :x, :y, :ox, :oy
  attr_accessor :angle, :zoom_x, :zoom_y
  attr_accessor :opacity
  attr_accessor :visible
  attr_accessor :belongs_to
  def z= z
    @z = z
    @belongs_to.sort!
  end
  def zoom= zoom
    @zoom_x, @zoom_y = zoom, zoom
  end
  def zoom
    fail 'Invalid use of self.zoom : @zoom_x != @zoom_y' if @zoom_x != @zoom_y
    @zoom_x
  end
  def <=> graph
    self.z <=> graph.z
  end
  def update
  end
end
end