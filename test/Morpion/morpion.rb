# Morpion
# By Darkleo

require 'ap'
require '../uby2d'

Cache.add_location 'Morpion/'
Size = 85
class Move
  @@board = [nil]*9
  X = Texture.new 'X.png'
  O = Texture.new 'O.png'
  attr_reader :win_move, :valid, :x, :y
  def initialize x, y, c
    @valid = @@board[x + 3*y].nil?
    return unless @valid
    t = c == :x ? X : O
    @x, @y = x, y
    @sprite = Sprite.new :x => Size*x, :y => Size*y, :texture => t
    @@board[x + 3*y] = c
    @win_move = win? c
    true
  end
  def dispose
    @sprite.dispose
    @@board[@x+3*@y] = nil
  end
  def win? c
    3.times {|k| return true if [@@board[k], @@board[k+3], @@board[k+6]] == [c]*3}
    3.times {|k| return true if [@@board[3*k], @@board[3*k+1], @@board[3*k+2]] == [c]*3}
    return true if [@@board[0], @@board[4], @@board[8]] == [c]*3
    return true if [@@board[2], @@board[4], @@board[6]] == [c]*3
    return false
  end
end

app = Application.new :name => 'Morpion', :width => 3*Size, :height => 3*Size
app.launch {
  @back = Sprite.new :texture => Texture.new('back.png')
  @moves = []
  loop {
    Graphics.update
    Mouse.update
    sleep 0.1
    if Mouse.trigger? Mouse::Left
      c = @moves.size % 2 == 0 ? :x : :o
      m = Move.new(Mouse.x/Size, Mouse.y/Size, c)
      next unless m.valid
      @moves << m
      break if m.win_move
    end
    break if @moves.size == 9
  }
  if @moves.size == 9
    @back.texture = Texture.new('lose.png')
    @moves.each {|m| m.dispose}
  else
    @back.texture = Texture.new('win.png')
    c = @moves.size % 2 == 0 ? :o : :x
    @moves.each {|m| m.dispose}
    @winmove = Move.new(1, 0.5, c)
  end
  Graphics.update
  sleep 0.5
  loop {
    Mouse.update
    exit! if Mouse.trigger? Mouse::Left
  }
}