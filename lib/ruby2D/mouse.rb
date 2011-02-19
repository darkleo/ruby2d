module Ruby2D
# Handles input data from a mouse.
module Mouse
  extend self
  
  Left   = :left
  Middle = :middle
  Right  = :right
  Wheel_Up   = :wheel_up
  Wheel_Down = :wheel_down
  Empty  = {:left   => :off,
            :middle => :off,
            :right  => :off,
            :wheel_up   => false,
            :wheel_down => false}
  
  @data = Empty.clone
  @data[:x] = 0
  @data[:y] = 0
  @next = Empty.clone
  @drag = {:left   => false,
           :middle => false,
           :right  => false}
  @drop = {:left   => false,
           :middle => false,
           :right  => false}
  
  # Updates input data.
  # 
  # As a rule, this method is called once per frame.
  def update
    [:left, :middle, :right].each do |key|
      @next[key] = :down if @next[key] == :on  and @data[key] == :off
      @next[key] = :up   if @next[key] == :off and @data[key] == :on
    end
    [:left, :middle, :right].each do |key|
      if @next[key] == :down
        @drag[key] = self.position 
        @drop[key] = false
      elsif @next[key] == :up
        @drop[key] = [@drag[key], self.position]
        @drag[key] = false
      else
        @drop[key] = false
      end
    end
    @data.update @next
    @next = Empty.clone
    [:left, :middle, :right].each do |key|
      @next[key] = :on  if @data[key] == :down
      @next[key] = :on  if @data[key] == :on
      @next[key] = :off if @data[key] == :up
    end
    [:wheel_up, :wheel_down].each do |key|
      @next[key] = false  if @data[key]
    end
    nil
  end
  
  def feed hash
    # todo : each
    hash.keys.each do |key|
      case key
      when :x, :y
        @data[key] = hash[key]
      when :left, :middle, :right
        @next[key] = hash[key]
      when :wheel_up, :wheel_down
        @next[key] = true
      end
    end
  end
  
  def move! x, y
    @data[:x] = x
    @data[:y] = y
  end
  
  # The X-coordinate of the mouse.
  def x
    @data[:x]
  end
  # The Y-coordinate of the mouse.
  def y
    @data[:y]
  end
  # Both coordinate of the mouse
  def position
    [x, y]
  end
  
  # Determines whether the button _key_ is being pressed again.
  #
  # "Pressed again" is seen as time having passed between the button being not pressed and being pressed.
  #
  # If the button is being pressed, returns +TRUE+.
  # If not, returns +FALSE+.
  def trigger? key=:any
    return @data.include? :down if key == :any
    @data[key] == :down
  end

  # Determines whether the button _key_ is currently being pressed.
  #
  # If the button is being pressed, returns +TRUE+.
  # If not, returns +FALSE+.
  def press? key=:any
    return @data.include? :on if key == :any
    @data[key] != :off
  end

  # Determines whether the button _key_ is currently being releassed.
  #
  # If the button is being released, returns +TRUE+.
  # If not, returns +FALSE+.
  def release? key=:any
    return @data.include? :up if key == :any
    @data[key] == :up
  end
  
  def wheel
    return :up   if @data[:wheel_up]
    return :down if @data[:wheel_down]
    nil
  end
  def wheel_up?
    @data[:wheel_up]
  end
  def wheel_down?
    @data[:wheel_down]
  end
  
  def drag? key
    @drag[key]
  end
  
  def drop? key
    @drop[key]
  end

  def in? shape
    shape === position
  end
end
end
