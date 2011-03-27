module Ruby2D
module Graphics
  extend self
  
  @main_frame = Frame.new nil
  attr_accessor :main_frame
  
  @frame_count = 0
  @fps = 0
  @fps_last_time = 0
  @fps_in_title = false
  @need_bind = true
  
  attr_reader :framerate
  attr_accessor :frame_count
  attr_accessor :fps_in_title
  attr_accessor :need_bind, :need_update
  
  def frame_reset
    @last_time = GLUT.Get GLUT::ELAPSED_TIME
  end
  def framerate= fps
    @framerate = fps
    @waiting_time = 1000/fps*0.8
    @fps_delay = fps == 1.0/0 ? 500 : 2*fps/3
    if @frame_count == 0
      # Glut isn't launched yet
      @last_time = 0
    else
      frame_reset
    end
  end
  self.framerate = 60

  def update force=false
    now = GLUT.Get GLUT::ELAPSED_TIME
    while now - @last_time < @waiting_time
      now = GLUT.Get GLUT::ELAPSED_TIME
    end
    @frame_count += 1
    @last_time = now
    return unless @fps_in_title
    if @frame_count % @fps_delay == 0
      @fps = @fps_delay*1000/(now-@fps_last_time)
      Window.name_suffix = " - #@fps fps"
      @fps_last_time = now
    end
  end
  def output
    @main_frame.output
  end
end
end
