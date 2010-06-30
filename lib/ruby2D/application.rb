# To change this template, choose Tools | Templates
# and open the template in the editor.

class Application
  # Argument is a Hash in which could be specified the following
  # * :name
  # * :width
  # * :height
  def initialize hash={}
    hash[:name]   ||= 'Noname'
    hash[:width]  ||= 640
    hash[:height] ||= 480
    
    @window = Window.new hash
    @window.create
  end
  
  # Launch the main Thread
  def launch &block
    Thread.abort_on_exception = true
    thread = Thread.new { yield block }
    GLUT.MainLoop()
  end
end