class Window
  def initialize hash={}
    @name   = hash[:name]||'OpenGL Window'
    @width  = hash[:width]||640
    @height = hash[:height]||480
    @x      = hash[:x]||(1600-640)/2
    @y      = hash[:y]||(1050-480)/2
  end
  def create
    create_procs
    
    GLUT.Init
    GLUT.InitDisplayMode(GLUT::RGBA|GLUT::DOUBLE|GLUT::ALPHA|GLUT::DEPTH)

    GLUT.InitWindowSize(@width, @height)
    GLUT.InitWindowPosition(@x, @y)
    @glut_window = GLUT.CreateWindow(@name)
    # TODO : change icon
    #~ Glut.glutSetIconTitle('favicon.ico')

    GLUT.ReshapeFunc(@procs[:reshape])
    GLUT.DisplayFunc(@procs[:display])
    GLUT.TimerFunc(0, @procs[:timer], 0)
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
    GLUT.EntryFunc(@procs[:entry])
    # ?
    #~ GLUT.DialsFunc(@procs[:dials])
    #~ GLUT.VisibilityFunc(@procs[:visibility])
    #~ GLUT.WindowStatusFunc(@procs[:window_status])


    GL.Enable(GL::BLEND)
    GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
    #~ GL.BlendFunc(GL::SRC_ALPHA, GL::ONE)
    #~ GL.BlendFunc(GL::ONE_MINUS_SRC_ALPHA, GL::ONE)
    GL.Enable(GL::TEXTURE_2D)
    #~ GL.Enable(GL::DEPTH_TEST)
  end
  
  def create_procs
    @procs = {}
    
    @procs[:reshape] = lambda {|w,h|
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
      GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
      #~ GL.Clear(GL::COLOR_BUFFER_BIT)
      Graphics.update_intern
      Graphics.all.each {|graph| graph.output}
      GL.Flush()
      GLUT.SwapBuffers()
    }
    
    @procs[:timer] = lambda {|i|
      Graphics.allow_update
      if i==200
        t = GLUT.Get(GLUT::ELAPSED_TIME)
        tb = Graphics.timebase
        #~ f = Graphics.frames
        p 200*1000.0/(t-tb)
        Graphics.frames = 0
        Graphics.timebase = t
        i=0
      end
      #~ Graphics.update_intern
      #~ GLUT.PostRedisplay()
      GLUT.TimerFunc(900.0/Graphics.framerate, @procs[:timer], i+1)
    }
    
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
      # GLUT::...
      # KEY_F1 => KEY_F12
      # KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_UP
      # KEY_PAGE_UP, KEY_PAGE_DOWN
      # KEY_END, KEY_HOME, KEY_INSERT
    }
    
    @procs[:special_keyboard_up] = lambda {|key,x,y|
      Input.feed get_special_key(key) => :release
    }
    
    @procs[:mouse] = lambda {|key,state,x,y|
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
    }
    
    @procs[:mouse_passive] = lambda {|x,y|
      Mouse.feed :x => x, :y => y
    }
    @procs[:motion] = lambda {|x,y|
      Mouse.feed :x => x, :y => y
    }
    
    @procs[:idle] = lambda {
      return unless @state
      #~ sleep 0.01 # Indispensable !
      GLUT.PostRedisplay()
    }
    
    @procs[:entry] = lambda {|state|
      @state = state == 1
      # 0:inactive / 1:active
    }
  end
  
  private
  SpecialKeys = %w/F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
    DOWN LEFT RIGHT UP PAGE_UP PAGE_DOWN
    END HOME INSERT/
  def get_special_key n
    SpecialKeys.each {|k| return k if eval("GLUT::KEY_#{k} == n")}
  end
end