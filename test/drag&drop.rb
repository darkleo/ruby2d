# drag&drop tests

$:.insert 0, '../lib/'
require 'ruby2d'

Window.name = 'drag&drop'
Window.resize 516, 384
Window.run {
  loop {
    Graphics.update
    Mouse.update
    d = Mouse.drop? :left
    p d if d
  }
}