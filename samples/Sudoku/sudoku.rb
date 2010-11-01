# Sudoku solver
# By Darkleo

$:.insert 0, '../../lib/'
require 'ruby2d'
Cache.add_location 'Sudoku/'

def solve board
  i = board.index '0'
  if i == nil
    fail board
    return
  end
  list = (1..9).to_a
  9.times do |k|
    list.delete board[i/9*9+k].to_i
    list.delete board[i%9+9*k].to_i
    list.delete board[i/27*27+k/3*9+i%9/3*3+k%3].to_i
  end
  for m in list
    b = board.dup
    b[i] = m.to_s
    solve b
  end
end

Size = 42
Window.name = 'Sudoku'
Window.resize 378, 462
Window.run {
  @back = Sprite.new Bitmap.new('back.png')
  @cursor1 = Sprite.new Bitmap.new('curs1.png')
  @cursor1.visible = false
  @cursor2 = Sprite.new Bitmap.new('curs2.png')
  @cursor2.visible = false
  @cursor2.y = 9*Size
  @numbers = Bitmap.new 'numbers.png'
  @grid = Sprite.new Bitmap.new(378, 378)

  # Input
  board = "0"*81
  need_to_solve = false
  until need_to_solve
    Graphics.update
    Mouse.update
    Input.update
    if Mouse.y >= 9*Size
      @cursor1.visible = false
      @cursor2.visible = true
      need_to_solve = Mouse.trigger? Mouse::Left
    else
      @cursor2.visible = false
      @cursor1.visible = true
      @cursor1.x = Mouse.x/Size*Size
      @cursor1.y = Mouse.y/Size*Size
    end
    key = Input.dir9
    if key != 0
      rect = Rect.new(0...Size, 0...Size)
      rect.translate!((key-1)%3*Size, (key-1)/3*Size)
      @grid.bitmap.blt @numbers, rect, @cursor1.x, @cursor1.y, :source
      x = @cursor1.x/Size
      y = @cursor1.y/Size
      board[x+9*y] = key.to_s
    end
    if Input.press?(' ') or Input.press?('0')
      rect = Rect.new(0...Size, 0...Size)
      rect.translate! @cursor1.x, @cursor1.y
      @grid.bitmap.clear rect
      x = @cursor1.x/Size
      y = @cursor1.y/Size
      board[x+9*y] = '0'
    end
  end

  # Result
  solve board rescue solved = $!.message
  popop 'no solution' unless solved
  81.times {|i|
    x = i%9*Size
    y = i/9*Size
    rect = Rect.new(0...Size, 0...Size)
    rect.translate! (solved[i].to_i-1)%3*Size, (solved[i].to_i-1)/3*Size
    @grid.bitmap.blt @numbers, rect, x, y, :source
    Graphics.update
  }
  loop {
    Mouse.update
    sleep 0.01
    exit if Mouse.press?
  }
}