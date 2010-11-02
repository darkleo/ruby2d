module Ruby2D
  Graphics = Class.new do
  def initialize
    @display_list = []
    
    @frames = 0
    @framerate = 60
    @timebase = 0
    @framebase = 0
  end
  
  attr_reader :frametotal
  attr_accessor :frames, :framerate, :timebase, :framebase
  attr_accessor :need_bind, :need_update

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
    @frames += 1
    #~ return if force or @frames%2==0
    loop do
      Mutex.synchronize do
        if @need_update
          @need_update = false
          @need_bind = true
          return
        end
      end
      sleep 0.01
    end
  end
end.new
end