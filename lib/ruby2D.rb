# Ruby 2D library
# by Darkleo

# Require libraries
require 'opengl'
require 'glut'
require 'fmod'
require 'zlib'
require 'Win32API'

Thread.abort_on_exception = true
$>.sync = true

module Ruby2D
  extend self
  
  # Constants
  MessageBox = Win32API.new 'user32','MessageBox','lppl','i'
  
  # Popup
  def popup *args
    puts *args
    MessageBox.call 0, args*"\n", 'Popup :', 0
    nil
  end
end
include Ruby2D

# High level
require 'ruby2D/graphic'
require 'ruby2D/sprite'
require 'ruby2D/cache'
require 'ruby2D/bitmap'
# Low level
require 'ruby2D/window'
require 'ruby2D/mouse'
require 'ruby2D/input'
# Modules
require 'ruby2D/graphics'
# Stuff
require 'ruby2D/shapes'
require 'ruby2D/color'