class Color
  attr_accessor :r, :g, :b, :a
  # Create a new Rect object.
  def initialize r=0, g=0, b=0, a=255
    @r, @g, @b, @a = r, g, b, a
  end
  # Return color data
  #
  # [r, g, b, a]
  def data
    [@r, @g, @b, @a]
  end
  
  # Return random color
  def self.rand
    Color.new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
  # Return random color, with random alpha
  def self.rand_a
    Color.new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
end

# TODO : Add default colors