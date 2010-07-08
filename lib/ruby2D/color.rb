# To change this template, choose Tools | Templates
# and open the template in the editor.

class Color
  attr_accessor :r, :g, :b, :a
  def initialize r=0, g=0, b=0, a=255
    @r, @g, @b, @a = r, g, b, a
  end
  def data
    [@r, @g, @b, @a]
  end

  def self.rand
    Color.new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
  def self.rand_a
    Color.new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
end

# TODO : Add default colors
