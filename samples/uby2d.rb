# Ruby 2D library
# Alternative require
# by Darkleo

p 'alternative launch'

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

$: << File.split(File.dirname(__FILE__))[0]

# Low level
require 'lib/ruby2D/application'
require 'lib/ruby2D/window'
require 'lib/ruby2D/mouse'
require 'lib/ruby2D/input'
# High level
require 'lib/ruby2D/cache'
require 'lib/ruby2D/texture'
require 'lib/ruby2D/sprite'
# Modules
require 'lib/ruby2D/graphics'
# Stuff
require 'lib/ruby2D/shapes'
require 'lib/ruby2D/color'