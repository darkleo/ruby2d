# A module that handles input data from a keyboard.

module Input
  extend self
  @current = {}
  @next    = {}
  
  # Updates input data.
  # 
  # As a rule, this method is called once per frame.
  def update
    for key in @current.keys | @next.keys
      if @next[key] != nil
        case @next[key]
        when :press
          @current[key] = (@current[key]||1)+1
        when :trig
          @current[key] = (@current[key]||0)+1
        when :release
          @current[key] = -1
        end
        @next.delete key
      elsif @current[key] == -1
        @current.delete key
      else
        @current[key] += 1
      end
    end
    nil
  end

  def feed(hash)
    @next.update hash
    nil
  end

  # Determines whether the button _key_ is being pressed again.
  #
  # "Pressed again" is seen as time having passed between the button being not pressed and being pressed.
  #
  # If the button is being pressed, returns +TRUE+.
  # If not, returns +FALSE+.
  def trigger? key
    @current[key.to_s] == 1 rescue false
  end

  # Determines whether the button _key_ is currently being pressed.
  #
  # If the button is being pressed, returns +TRUE+.
  # If not, returns +FALSE+.
  def press? key
    @current[key.to_s] > 0 rescue false
  end

  # Determines whether the button _key_ is currently being releassed.
  #
  # If the button is being released, returns +TRUE+.
  # If not, returns +FALSE+.
  def release? key
    @current[key.to_s] == -1 rescue false
  end

  # Determines whether the button _key_ is being pressed again.
  #
  # Unlike trigger?, takes into account the repeat input of a button being held down continuously.
  #
  # If the button is being pressed, returns +TRUE+.
  # If not, returns +FALSE+.
  def repeat? key
    i = key.to_s
    (@current[i] > 8 and @current[i]%4 == 0) rescue false
  end

  # Checks the status of the directional buttons,
  # translates the data into a specialized 4-direction input format,
  # and returns the number pad equivalent (2, 4, 6, 8).
  #
  # If no directional buttons are being pressed (or the equivalent),
  # returns 0.
  def dir4
    (1..4).each {|i| return 2*i if press? (2*i).to_s}
    0
  end

  # Checks the status of the directional buttons,
  # translates the data into a specialized 8-direction input format,
  # and returns the number pad equivalent (1, 2, 3, 4, 6, 7, 8, 9).
  #
  # If no directional buttons are being pressed (or the equivalent),
  # returns 0.
  def dir8
    (1..4).each {|i| return 2*i-1 if press? (2*i-1).to_s}
    dir4
  end

  # Checks the status of the directional buttons,
  # translates the data into a specialized 9-direction input format,
  # and returns the number pad equivalent (1, 2, 3, 4, 5, 6, 7, 8, 9).
  #
  # If no directional buttons are being pressed (or the equivalent),
  # returns 0.
  def dir9
    (1..9).each {|i| return i if press? i.to_s}
    0
  end
end
