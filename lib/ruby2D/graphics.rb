module Graphics
  extend self

  @@display_list ||= []
  
  attr_reader :frametotal
  attr_accessor :frames, :framerate, :timebase, :framebase
  attr_accessor :need_bind, :need_update
  
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
    sort!
  end
  def remove graph
    @@display_list.delete graph
  end
  def get graph_name
    @@display_list.each {|graph| return graph if graph.name == graph_name}
    fail 'Graph not found'
  end
  def sort!
    @@display_list.sort!
  end

  def update
    catch :done do
      loop do
        sleep 0.01
        $mutex.synchronize do
          if @need_update
            @need_update = false
            @need_bind = true
            throw :done
          end
        end
      end
    end
    @frames += 1
  end
end