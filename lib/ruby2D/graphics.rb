class Ruby2D::Graphics
  @framecount = 0
  @fps_last_time = 0
  @fps_last_count = 0
  @fps_in_title = false
  @need_bind = true
  @main_frame = Ruby2D::Frame.new nil
  def @main_frame.dispose
    fail 'You cannot simply dispose the main Frame'
  end
end

class << Ruby2D::Graphics       
  attr_accessor :main_frame
  attr_reader :framerate
  attr_accessor :framecount
  attr_accessor :fps_in_title
  attr_accessor :need_bind, :need_update
  
  def frame_reset
    @last_time = @framecount == 0 ? 0 : GLUT.Get(GLUT::ELAPSED_TIME)
  end
  def framerate= fps
    @framerate = fps
    @waiting_time = (1000/fps).to_i
    frame_reset
  end

  def update force=false
    now = GLUT.Get(GLUT::ELAPSED_TIME)
    delta = @last_time + @waiting_time - now
    sleep (delta-1)/1000.0 if delta > 0
    
    @framecount += 1
    @last_time = now
    GLUT.PostRedisplay()
    
    return unless @fps_in_title
    if now - @fps_last_time > 1000
      Window.name_suffix = " - #{(@framecount - @fps_last_count)*1000/(now-@fps_last_time)} fps"
      @fps_last_count = @framecount
      @fps_last_time = now
    end
  end
  def output
    @main_frame.output
  end
end
Ruby2D::Graphics.framerate = 60
