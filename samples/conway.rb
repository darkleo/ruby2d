require '../lib/ruby2D'
include Ruby2D

class Map
  Black = Color.rgb 0, 0, 0
  White = Color.rgb 255, 255, 255
  def initialize w, h, s=0.5
    @w, @h = w, h
    @data = Array.new(w) { Array.new(h) {rand <= s}}
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new w, h
    @sprite.zoom = 4
    Window.resize 4*h, 4*w
  end
  def update
    @data = @data.map.with_index do |row,i|
      row.map.with_index do |state,j|
        bool = case neighbours i, j
            when 0, 1, 4 then false
            when 2 then state
            when 3 then true
            end
        @sprite.bitmap.set_pixel i, j, (bool ? White : Black)
        bool
      end
    end
  end
  def neighbours i, j
    [[i-1,j-1],
      [i-1,j],
      [i-1,j+1-@h],
      [i,j-1],
      [i,j+1-@h],
      [i+1-@w,j-1],
      [i+1-@w,j],
      [i+1-@w,j+1-@h]
    ].count {|(a, b)| @data[a][b]}
  end
end

Window.name = 'Conway\'s Game of Life'
Window.run do
  @map = Map.new 40, 40
  loop { Graphics.update ; @map.update}
end