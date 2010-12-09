# Ruby 2D library
# by Darkleo

# Extern libraries
require 'opengl'
require 'glut'
require 'fmod'
require 'zlib'
require 'Win32API'

# Stuff ...
Thread.abort_on_exception = true
$>.sync = true

# Ruby2D
module Ruby2D
  # Popup
  MessageBox = Win32API.new 'user32','MessageBox','lppl','i'
  def self.popup *args
    puts *args
    MessageBox.call 0, args*"\n", 'Popup :', 0
    nil
  end
  Mutex = Mutex.new
end

# Ruby2D library
require 'ruby2D/graphic'
require 'ruby2D/sprite'
require 'ruby2D/PNG'
require 'ruby2D/BMP'
require 'ruby2D/cache'
require 'ruby2D/bitmap'
require 'ruby2D/window'
require 'ruby2D/mouse'
require 'ruby2D/input'
require 'ruby2D/graphics'
require 'ruby2D/shapes'
require 'ruby2D/color'