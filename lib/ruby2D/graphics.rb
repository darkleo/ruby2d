module Graphics
  extend self

  @@display_list ||= []
  
  attr_reader :frametotal
  attr_accessor :frames, :framerate, :timebase, :framebase
  
  @frames = 0
  @framerate = 60
  @timebase = 0
  @framebase = 0

  def all
    @@display_list
  end

  def add graph
    graph.update
    @@display_list << graph
    @@display_list.sort!
  end
  def remove graph
    @@display_list.delete graph
  end
  def get graph_name
    @@display_list.each {|graph| return graph if graph.name == graph_name}
    fail 'Graph not found'
  end

  def allow_update
    @need_update = true
  end
  def update
    sleep 0.01 until @need_update
    @need_update = false
    @frames += 1
    @@display_list.each {|graph| graph.update}
  end
  def update_intern
#    epoch = Time.now.to_f
#    eps = epoch-@last_time
#    return unless eps > 1.0/@framerate
#    @last_time = epoch
    #~ @need_update = false
#    p 1/eps rescue -1
    # No GL calls in Threads
    @@display_list.sort! # moche
    @@display_list.each {|graph| graph.update_texture}
  end
end