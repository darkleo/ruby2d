# Ruby2D

## Empty window
    require 'ruby2D'
    
    Ruby2D::Window.run {}

## Basic configuration
    require 'ruby2D'
    include Ruby2D
    
    Window.name = 'Empty'
    Window.resize 256, 256
    Window.run {}

## Let start something !
    require 'ruby2D'
    include Ruby2D
    
    Window.name = 'Light'
    Window.resize 128, 128
    Window.run do
      # Creation
      @sprite = Sprite.new
      @sprite.bitmap = Bitmap.new('Light')
      
      # Set up origin to center of bitmap
      @sprite.ox = @sprite.oy = @sprite.x = @sprite.y = 64
      
      # Rotate the star arround its center
      loop do
        Graphics.update
        @sprite.angle += 1
      end
    end

## Installation
Run the following command:

    gem install ruby2D

This requires the rubyopengl gem to be installed.

# Features
* Cool 2D rendering engine