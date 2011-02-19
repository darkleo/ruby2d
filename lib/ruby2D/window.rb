module Ruby2D
  Window = Class.new do
  def initialize
    @name = 'OpenGL'
    @name_suffix = ''
    @width = 640
    @height = 480
    @x = 192
    @y = 144
    @fullscreen = false
    @window = nil
    @to_set = {}
    
    create_procs
  end
  
  def name= name
    @to_set[:name] = name
    @name = name
  end
  def name_suffix= name
    @to_set[:name_suffix] = name
    @name_suffix = name
  end
  def resize w, h
    fail Errno::EDOM unless w>0 && h>0
    @to_set[:size] = [w, h]
    @width, @height = w, h
  end
  def size
    [@width, @height]
  end
  def move x, y
		@to_set[:position] = [x,y]
    @x, @y = x, y
  end
  def position
    [@x, @y]
  end
  def fullscreen b=true
		@to_set[:fullscreen] = b
    @fullscreen = b
  end
  def fullscreen?
    @fullscreen
  end
  
  def run &block
    GLUT.Init
    GLUT.InitDisplayMode GLUT::RGBA|GLUT::DOUBLE|GLUT::ALPHA|GLUT::DEPTH
    
    GLUT.InitWindowSize @width, @height
    GLUT.InitWindowPosition @x, @y
    @window = GLUT.CreateWindow @name
    # TODO : change icon
    #~ Glut.glutSetIconTitle('favicon.ico')
    GLUT.FullScreen if @fullscreen
    
    GLUT.ReshapeFunc @procs[:reshape]
    GLUT.DisplayFunc @procs[:display]
    #GLUT.TimerFunc 0, @procs[:timer], 0
    # Keyboard
    GLUT.KeyboardFunc(@procs[:keyboard])
    GLUT.KeyboardUpFunc(@procs[:keyboard_up])
    GLUT.SpecialFunc(@procs[:special_keyboard])
    GLUT.SpecialUpFunc(@procs[:special_keyboard_up])
    # Mouse
    GLUT.MouseFunc(@procs[:mouse])
    GLUT.PassiveMotionFunc(@procs[:mouse_passive])
    GLUT.MotionFunc(@procs[:motion])
    # Other
    GLUT.IdleFunc(@procs[:idle])
    #~ GLUT.EntryFunc(@procs[:entry])
    #~ GLUT.VisibilityFunc(@procs[:visibility])
    #~ GLUT.WindowStatusFunc(@procs[:window_status])
    # ?
    #~ GLUT.ButtonBoxFunc(@procs[:button_box])
    #~ GLUT.DialsFunc(@procs[:dials])
    #~ GLUT.WindowStatusFunc(@procs[:window_status])
    
    GL.Enable GL::BLEND
    GL.BlendFunc GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA
    #~ GL.BlendFunc GL::SRC_ALPHA, GL::ONE
    #~ GL.BlendFunc GL::ONE_MINUS_SRC_ALPHA, GL::ONE
    GL.Enable GL::TEXTURE_2D
    #~ GL.Enable GL::DEPTH_TEST
    GL.Disable GL::CULL_FACE
    
    Thread.new { yield block }
    GLUT.MainLoop()
  end
  
  private
  def create_procs
  @procs = {}
  @procs[:reshape] = proc { |w, h|
    width  = [1, w].max
    height = [1, h].max
    GL.Viewport(0, 0,  width,  height)
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GL.Ortho(0.0, width, -height, 0.0, -1, 10_000)
    GL.MatrixMode(GL::MODELVIEW)
    @width  = width
    @height = height
  }
  @procs[:display] = lambda {
    #~ GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    #~ Mutex.synchronize {
      if Graphics.need_bind
        ObjectSpace.each_object(Graphic) {|g| g.bitmap.bind rescue nil}
        Graphics.need_bind = false
      end
    #~ }
    Graphics.all.each {|graphic| graphic.output}
    #~ GL.Flush()
    GLUT.SwapBuffers()
  }
  #@procs[:timer] = lambda {|i|
    #GLUT.TimerFunc(10, @procs[:timer], i)
  #}
  @procs[:keyboard] = lambda {|key,x,y|
    exit if key == ?\e
    Input.feed key => :trig
    gm = GLUT.GetModifiers
    case gm
    when 1 ; Input.feed 'maj' => :press
    when 2 ; Input.feed 'ctrl' => :press
    when 4 ; Input.feed 'alt' => :press
    when 6 ; Input.feed 'altg' => :press
    end
  }
  @procs[:keyboard_up] = lambda {|key,x,y|
    Input.feed key.chr => :release
    gm = GLUT.GetModifiers
    case gm
    when 1 ; Input.feed 'maj' => :press
    when 2 ; Input.feed 'ctrl' => :press
    when 4 ; Input.feed 'alt' => :press
    when 6 ; Input.feed 'altg' => :press
    end
  }
  @procs[:special_keyboard] = lambda {|key,x,y|
    Input.feed get_special_key(key) => :trig
  }
  @procs[:special_keyboard_up] = lambda {|key,x,y|
    Input.feed get_special_key(key) => :release
  }
  @procs[:mouse] = lambda {|key,state,x,y|
    case key
    when 0 ; nkey = Mouse::Left
    when 1 ; nkey = Mouse::Middle
    when 2 ; nkey = Mouse::Right
    when 3 ; nkey = Mouse::Wheel_Up
    when 4 ; nkey = Mouse::Wheel_Down
    end
    case state
    when 0 ; nstate = :down
    when 1 ; nstate = :up
    end
    Mouse.feed nkey => nstate, :x => x, :y => y
  }
  @procs[:mouse_passive] = lambda {|x,y|
    Mouse.feed :x => x, :y => y
  }
  @procs[:motion] = lambda {|x,y|
    Mouse.feed :x => x, :y => y
  }
  @procs[:idle] = lambda {
    GLUT.PostRedisplay()
		@to_set.each_pair do |key, value|
      case key
      when :name
        GLUT.SetWindowTitle value+@name_suffix
      when :name_suffix
        GLUT.SetWindowTitle @name+value 
      when :size
        GLUT.ReshapeWindow(*value)
      when :position
        GLUT.PositionWindow(*value)
      when :fullscreen
        if value
          GLUT.FullScreen
        else
          resize @width, @height
        end
      end
		end
		@to_set.clear
  }
  #@procs[:entry] = lambda {|state|
    #@state = state == 1 # 0:left / 1:entered
  #}
  #~ @procs[:visibility] = lambda {|v|
  #~ }
  #~ @procs[:window_status] = lambda {|state|
  #~ }
  end
  
  SpecialKeys = %w/F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
    DOWN LEFT RIGHT UP PAGE_UP PAGE_DOWN
    END HOME INSERT/
  def get_special_key n
    SpecialKeys.each {|k| return k if eval("GLUT::KEY_#{k} == n")}
  end
end.new
end
