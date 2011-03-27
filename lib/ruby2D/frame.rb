module Ruby2D
class Frame < Graphic
  def initialize frame=Ruby2D::Graphics.main_frame
    @list = []
    @x = @y = @ox = @oy = 0
    @angle = 0
    @zoom_x = @zoom_y = 100
    @opacity = 100
    @color = Color.gray 255
    @visible = true
    frame << self if frame
    #~ Ruby2D::Graphics.main_frame << self unless main
  end
  def << graph
    graph.belongs_to >> graph rescue nil
    @list << graph
    graph.belongs_to = self
  end
  def >> graph
    @list.delete graph
    graph.belongs_to = nil
  end
  def sort!
    @list.sort!
  end
  def update
    @list.each(&:update)
  end
  def output
    return unless @visible
    return unless @opacity != 0
    
    GL.PushMatrix
    GL.Translate(@x, -@y, 0)
    GL.Rotate(@angle, 0, 0, 1) if @angle != 0
    GL.Scale(@zoom_x/100.0, @zoom_y/100.0, 1)
    GL.Translate(-@ox, @oy, 0)
    GL.Color(@color.r/255.0, @color.g/255.0, @color.b/255.0, @opacity/100.0)
    
    @list.each(&:output)
    
    GL.PopMatrix
  end
end
end