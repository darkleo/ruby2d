# drag&drop tests

require 'uby2d'

app = Application.new :name => 'drag&drop', :width => 516, :height => 384
app.launch {
  loop {
    Graphics.update
    Mouse.update
    d = Mouse.drop? :left
    p d if d
  }
}