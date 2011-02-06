# Ruby 2D library
# by Darkleo

# Extern libraries
require 'opengl'
require 'glut'
require 'zlib'
require 'Win32API' if RUBY_PLATFORM =~ /mswin/

# Stuff ...
Thread.abort_on_exception = true
$>.sync = true

# Ruby2D
module Ruby2D
  # Popup
  if RUBY_PLATFORM =~ /mswin/
    MessageBox = Win32API.new 'user32','MessageBox','lppl','i'
    def self.popup *args
      puts *args
      MessageBox.call 0, args*"\n", 'Popup :', 0
      nil
    end
  else
    def self.popup *args
      puts *args
    end
  end
  Mutex = Mutex.new
end

# Ruby2D library
require_relative 'ruby2D/graphic'
require_relative 'ruby2D/sprite'
require_relative 'ruby2D/PNG'
require_relative 'ruby2D/BMP'
require_relative 'ruby2D/cache'
require_relative 'ruby2D/bitmap'
require_relative 'ruby2D/window'
require_relative 'ruby2D/mouse'
require_relative 'ruby2D/input'
require_relative 'ruby2D/graphics'
require_relative 'ruby2D/shapes'
require_relative 'ruby2D/color'
