# To change this template, choose Tools | Templates
# and open the template in the editor.

module Graphics
  extend self

  @@display_list ||= []
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

  def update
    @@display_list.each {|graph| graph.update}
  end
  def update_intern
    # No GL calls in Threads
    @@display_list.each {|graph| graph.update_texture}
  end
end