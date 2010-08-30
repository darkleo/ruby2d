# Ruby 2D library
# by Darkleo

# Require libraries
require 'opengl'
require 'glut'
require 'fmod'
require 'zlib'
require 'Win32API'

module Ruby2D
  extend self

  MessageBox = Win32API.new('user32','MessageBox','lppl','i')
  # Create a small windows where args will be showed
  #
  # call .to_s when necessary
  def popup *args
    puts *args
    MessageBox.call(0, args*"\n", 'Popup :', 0)
    nil
  end
  
  # Create a small windows where args will be showed
  #
  # Don't stop the flow
  #
  # call .to_s when necessary
  def popupup *args
    Thread.new {popup *args}
  end
end
include Ruby2D

# Low level
require 'ruby2D/application'
require 'ruby2D/window'
require 'ruby2D/mouse'
require 'ruby2D/input'
# High level
require 'ruby2D/cache'
require 'ruby2D/texture'
require 'ruby2D/sprite'
# Modules
require 'ruby2D/graphics'
# Stuff
require 'ruby2D/shapes'
require 'ruby2D/color'