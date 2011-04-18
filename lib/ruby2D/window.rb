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
  def fullscreen= b=true
		@to_set[:fullscreen] = b
    @fullscreen = b
  end
  def fullscreen?
    @fullscreen
  end
  def screenshot x, y, w, h
    temp = []
    @to_set[:screenshot] = [temp, x, @height-h-y, w, h]
    sleep(0) while temp.empty?
    temp.first
  end
  
  def run &block
    GLUT.Init
    GLUT.InitDisplayMode GLUT::RGBA|GLUT::DOUBLE#|GLUT::ALPHA
    
    GLUT.InitWindowSize @width, @height
    GLUT.InitWindowPosition((GLUT.Get(GLUT::SCREEN_WIDTH)-@width)/2,
                          (GLUT.Get(GLUT::SCREEN_HEIGHT)-@height)/2)
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
    
    #~ p GL.GetString GL::VERSION
    #~ p GL.GetString GL::EXTENSIONS
    GL.Enable GL::BLEND
    GL.BlendFunc GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA
    #~ GL.BlendFunc GL::SRC_ALPHA, GL::ONE
    #~ GL.BlendFunc GL::ONE_MINUS_SRC_ALPHA, GL::ONE
    GL.Enable GL::TEXTURE_2D
    GL.Disable GL::CULL_FACE
    
    Thread.new { yield block }
    GLUT.MainLoop
  end
  
  private
  def create_procs
    @procs = {}
    @procs[:reshape] = lambda do |w, h|
      width  = [1, w].max
      height = [1, h].max
      GL.Viewport(0, 0,  width,  height)
      GL.MatrixMode(GL::PROJECTION)
      GL.LoadIdentity()
      GL.Ortho(0.0, width, -height, 0.0, -1, 1)
      GL.MatrixMode(GL::MODELVIEW)
      @width  = width
      @height = height
    end
    @procs[:display] = lambda do
      GL.Clear GL::COLOR_BUFFER_BIT
      Graphics.output
      GLUT.SwapBuffers()
    end
    #~ @procs[:timer] = lambda do |i|
      #~ GLUT.TimerFunc(10, @procs[:timer], i)
    #~ end
    @procs[:keyboard] = lambda do |key,x,y|
      exit if key == ?\e
      Input.feed key => :trig
      gm = GLUT.GetModifiers
      case gm
      when 1 ; Input.feed 'maj' => :press
      when 2 ; Input.feed 'ctrl' => :press
      when 4 ; Input.feed 'alt' => :press
      when 6 ; Input.feed 'altg' => :press
      end
    end
    @procs[:keyboard_up] = lambda do |key,x,y|
      Input.feed key.chr => :release
      gm = GLUT.GetModifiers
      case gm
      when 1 ; Input.feed 'maj' => :press
      when 2 ; Input.feed 'ctrl' => :press
      when 4 ; Input.feed 'alt' => :press
      when 6 ; Input.feed 'altg' => :press
      end
    end
    @procs[:special_keyboard] = lambda do |key,x,y|
      Input.feed get_special_key(key) => :trig
    end
    @procs[:special_keyboard_up] = lambda do |key,x,y|
      Input.feed get_special_key(key) => :release
    end
    @procs[:mouse] = lambda do |key,state,x,y|
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
    end
    @procs[:mouse_passive] = lambda do |x,y|
      Mouse.feed :x => x, :y => y
    end
    @procs[:motion] = lambda do |x,y|
      Mouse.feed :x => x, :y => y
    end
    @procs[:idle] = lambda do
      return unless @to_set
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
        when :screenshot
          # ??? GLUT.PostRedisplay
          # ??? GLUT.SwapBuffers
          value[0] << GL.ReadPixels(value[1], value[2], value[3], value[4], GL::RGBA, GL::UNSIGNED_BYTE)
        end
      end
      @to_set.clear
    end
    #~ @procs[:entry] = lambda do |state|
      #~ @state = state == 1 # 0:left / 1:entered
    #~ end
    #~ @procs[:visibility] = lambda do |v|
    #~ end
    #~ @procs[:window_status] = lambda do |state|
    #~ end
  end
  
  SpecialKeys = %w/F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
    DOWN LEFT RIGHT UP PAGE_UP PAGE_DOWN
    END HOME INSERT/
  def get_special_key n
    SpecialKeys.each {|k| return k if GLUT.const_get('KEY_'+k) == n}
  end
end.new
end
