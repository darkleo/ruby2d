# To change this template, choose Tools | Templates
# and open the template in the editor.

class Window
  def initialize hash={}
    @name   = hash[:name]||'OpenGL Window'
    @width  = hash[:width]||640
    @height = hash[:height]||480
    @x      = hash[:x]||(1600-640)/2
    @y      = hash[:y]||(1050-480)/2
  end
  def create
    GLUT.Init
    GLUT.InitDisplayMode(GLUT::RGBA|GLUT::DOUBLE|GLUT::ALPHA|GLUT::DEPTH)

    GLUT.InitWindowSize(@width, @height)
    GLUT.InitWindowPosition(@x, @y)
    @glut_window = GLUT.CreateWindow(@name)
    p Glut.glutSetIconTitle('favicon.ico')

    GLUT.ReshapeFunc(method('reshape').to_proc)
    GLUT.DisplayFunc(method('display').to_proc)
    # Keyboard
    GLUT.KeyboardFunc(method('keyboard').to_proc)
    GLUT.KeyboardUpFunc(method('keyboard_up').to_proc)
    GLUT.SpecialFunc(method('special_keyboard').to_proc)
    GLUT.SpecialUpFunc(method('special_keyboard_up').to_proc)
    # Mouse
    GLUT.MouseFunc(method('mouse').to_proc)
    GLUT.PassiveMotionFunc(method('mouse_passive').to_proc)
    GLUT.MotionFunc(method('motion').to_proc)
    # Other
    GLUT.IdleFunc(method('update').to_proc)
    GLUT.EntryFunc(method('entry').to_proc)
    # ?
#    GLUT.DialsFunc(method('dials').to_proc)
#    GLUT.VisibilityFunc(method('visibility').to_proc)
#    GLUT.WindowStatusFunc(method('window_status').to_proc)


    GL.Enable(GL::BLEND)
    GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
#    GL.BlendFunc(GL::SRC_ALPHA, GL::ONE)
#    GL.BlendFunc(GL::ONE_MINUS_SRC_ALPHA, GL::ONE)
    GL.Enable(GL::TEXTURE_2D)
#    GL.Enable(GL::DEPTH_TEST)
  end

  def update
    return unless @state
    sleep 0.01 # Indispensable !
    Graphics.update_intern
    GLUT.PostRedisplay()
  end

  def reshape(width, height)
    width = [1, width].max
    height = [1, height].max
    GL.Viewport(0, 0,  width,  height)
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GL.Ortho(0.0, width, -height, 0.0, -1, 10_000)
    GL.MatrixMode(GL::MODELVIEW)
    @width  = width
    @height = height
  end
  
  private
  def display
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
#    GL.Clear(GL::COLOR_BUFFER_BIT)
    Graphics.all.each {|graph| graph.output}
    GL.Flush()
    GLUT.SwapBuffers()
  end
  def keyboard(key, x, y)
#    p [key, :down]
    exit if key == ?\e
    gm = GLUT.GetModifiers
    case gm
    when 1 ; Input.feed 'maj' => :press
    when 2 ; Input.feed 'ctrl' => :press
    when 4 ; Input.feed 'alt' => :press
    when 6 ; Input.feed 'altg' => :press
    end
    Input.feed key => :trig
  end
  def keyboard_up(key, x, y)
#    p [key.chr, :up]
    gm = GLUT.GetModifiers
    case gm
    when 1 ; Input.feed 'maj' => :press
    when 2 ; Input.feed 'ctrl' => :press
    when 4 ; Input.feed 'alt' => :press
    when 6 ; Input.feed 'altg' => :press
    end
    Input.feed key.chr => :release
  end
  SpecialKeys = %w/F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
    DOWN LEFT RIGHT UP PAGE_UP PAGE_DOWN
    END HOME INSERT/
  def get_special_key n
    SpecialKeys.each {|k| return k if eval("GLUT::KEY_#{k} == n")}
  end
  def special_keyboard(key, x, y)
    Input.feed get_special_key(key) => :trig
    # KEY_F1 => KEY_F12
    # KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_UP
    # KEY_PAGE_UP, KEY_PAGE_DOWN
    # KEY_END, KEY_HOME, KEY_INSERT
    case key
    when GLUT::KEY_F12
#~       puts 'No F12 function...'
#~       Thread.new{`./Game.exe`}
      # Thread.new {system('Game.exe')}
      #exit
    else
#~       p key
    end
  end
  def special_keyboard_up(key, x, y)
    Input.feed get_special_key(key) => :release
  end
  
  def mouse(key, state, x, y)
    case key
    when 0 ; nkey = Mouse::Left
    when 1 ; nkey = Mouse::Middle
    when 2 ; nkey = Mouse::Right
    end
    case state
    when 0 ; nstate = :down
    when 1 ; nstate = :up
    end
    Mouse.feed nkey => nstate, :x => x, :y => y
  end
  def mouse_passive(x, y)
    Mouse.feed :x => x, :y => y
  end
  def motion(*args)
#    p 'motion'
#    p args
  end
  def dials(*args)
#    p 'dials'
#    p args
  end
  def entry(state)
    @state = state == 1
#    puts "GLUT 'entry' said : #{@state}"
#     0 => Window is inactive
#     1 => Window is active
  end
  def visibility(*args)
#    p 'visibility'
#    p args
  end
  def window_status(*args)
#    p 'window_status'
#    p args
  end
end