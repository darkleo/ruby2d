module Ruby2D
module Graphics
  extend self
  
  @display_list = []
  
  @frames = 0
  @last_time = 0
  @fps_count = 1
  @fps = 0
  @fps_in_title = false
  
  attr_reader :frames, :framerate
  attr_accessor :fps_in_title
  attr_accessor :need_bind, :need_update
  
  def framerate= fps
    @framerate = fps
    @waiting_time = 950.0/fps
    @fps_delay = fps == 1.0/0 ? 1000 : 2*fps/3
  end
  self.framerate = 60

  def all
    @display_list
  end
  def add graph
    graph.update
    @display_list << graph
    sort!
  end
  def remove graph
    @display_list.delete graph
  end
  def get graph_name
    @display_list.each {|graph| return graph if graph.name == graph_name}
    fail 'Graph not found'
  end
  def sort!
    @display_list.sort!
  end

  def update force=false
    now = GLUT.Get GLUT::ELAPSED_TIME
    while now - @last_time < @waiting_time
      now = GLUT.Get GLUT::ELAPSED_TIME
    end
    @frames += 1
    if @frames % @fps_delay == 0
      @fps = @fps_delay*1000/(now-@fps_count)
      @fps_count = now
      Window.name_suffix = " - #@fps fps" if @fps_in_title
    end
    @last_time = now
    #~ Mutex.synchronize { @need_bind = true }
    @need_bind = true
  end
end
end
