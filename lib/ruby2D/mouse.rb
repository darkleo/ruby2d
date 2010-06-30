# A module that handles input data from a mouse.

module Mouse
  extend self

  Left   = :left
  Middle = :middle
  Right  = :right
  Empty  = {:left => :off,
            :middle => :off,
            :right => :off}
  @data = Empty.clone
  @data[:x] = 0
  @data[:y] = 0
  @next = Empty.clone


  # Updates input data.
  # 
  # As a rule, this method is called once per frame.
  def update
    @data.update @next
    @next = Empty.clone
    [:left, :middle, :right].each do |key|
      @next[key] = :on  if @data[key] == :down
      @next[key] = :on  if @data[key] == :on
      @next[key] = :off if @data[key] == :up
    end
    nil
  end

  def feed hash
    hash.keys.each do |key|
      case key
      when :x, :y
        @data[key] = hash[key]
      when :left, :middle, :right
        @next[key] = hash[key]
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

  def in? shape
    shape === position
  end
end
