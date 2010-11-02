module Ruby2D
  Cache = Class.new do
  def initialize
    @data = {}
    @local = ['']
  end
  
  def load_bitmap name
    return @data[name] if @data.include? name
    @local.each {|path| load_with_path path, name }
    return @data[name] if @data.include? name
    fail Errno::ENOENT, name
  end
  def add_location local
    @local << local
  end
  def remove_location local
    @local.delete local
  end
  
  private
  def load_with_path path, name
    begin
      case File.extname name
      when '.img'
        @data[name] = load_img path, name
      when '.png'
        @data[name] = load_png path, name
      when '.bmp'
        @data[name] = load_bmp path, name
      when ''
      else
        return false
      end
    rescue Errno::ENOENT
    end
    return true
  end
  
  def load_img path, name
    full_path = path+name
    fail Errno::ENOENT, 'No such file or directory - '+full_path unless FileTest.exist? full_path
    file = File.open full_path, 'rb'
    struct = {:name => name}
    struct[:width]     = file.read(4).unpack('i')[0]
    struct[:height]    = file.read(4).unpack('i')[0]
    struct[:real_size] = file.read(4).unpack('i')[0]
    struct[:data]      = Zlib::Inflate.inflate(file.read)
    file.close
    return struct
  end
  def load_png path, name
    # TODO : improve calculs
    # XXX : reshaping ?
    full_path = path+name
    fail Errno::ENOENT, 'No such file or directory - '+full_path unless FileTest.exist? full_path
    file = File.open full_path, 'rb'
    struct = {:name => name}
    fail 'Invalid .png file' if file.read(8).unpack('C*') != [137, 80, 78, 71, 13, 10, 26, 10]

    struct[:data] = ''
    {} while read_chunks file, struct

    # Correct
    array = Zlib::Inflate.inflate(struct[:data]).unpack('C*')
    corrected = []
    case struct[:color_type]
    when 2 # RGB
      for y in 0...struct[:height]
        for x in 0...struct[:width]
          z = 3*struct[:width]*y + y + 3*x + 1
          corrected << array[z  ] # R
          corrected << array[z+1] # G
          corrected << array[z+2] # B
          corrected << 255 # A (add)
        end
        for x in struct[:width]...struct[:real_size]
          corrected << 0
          corrected << 0
          corrected << 0
          corrected << 0
        end
      end
      blank = [0]*4*struct[:real_size]
      (struct[:real_size]-struct[:height]).times {corrected.push *blank} # cause of too deep stack level
    when 3 # PLTE
      # p [@plte[3*i], @plte[3*i+1], @plte[3*i+2]]
#~       p array
#~       p @width, @height, array.size
      for y in 0...struct[:height]
        for x in 0...struct[:width]
          z = struct[:width]*y + y + x + 1
          i = (array[z]+1)%2
          corrected << struct[:plte][3*i  ] # R
          corrected << struct[:plte][3*i+1] # G
          corrected << struct[:plte][3*i+2] # B
          if struct[:px_trns]
            corrected << struct[:px_trns][i] # A
          end
        end
      end
      #TODO:ganz horrible
      #aarg ! (norealsize)
    when 6 # RGBA
      blank = [0]*4*(struct[:real_size]-struct[:width])
      for y in 0...struct[:height]
        for x in 0...struct[:width]
          z = 4*struct[:width]*y + y + 4*x + 1
          corrected << array[z  ] # R
          corrected << array[z+1] # G
          corrected << array[z+2] # B
          corrected << array[z+3] # A
        end
        corrected.push *blank
      end
      blank = [0]*4*struct[:real_size]
      # cause of too deep stack level
      (struct[:real_size]-struct[:height]).times {corrected.push *blank}
    when 7 # RGB + one alpha
      blank = [0]*4*(struct[:real_size]-struct[:width])
      for y in 0...struct[:height]
        for x in 0...struct[:width]
          z = 3*struct[:width]*y + y + 3*x + 1
          corrected << array[z  ] # R
          corrected << array[z+1] # G
          corrected << array[z+2] # B
          if corrected[-3, 3] == struct[:px_trns]
            corrected << 0 # A
          else
            corrected << 255 # A
          end
        end
        corrected.push *blank
      end
      blank = [0]*4*struct[:real_size]
      # cause of too deep stack level
      (struct[:real_size]-struct[:height]).times {corrected.push *blank}
    end
    struct[:data] = corrected.pack('C*')

    file.close
    return struct
  end
  def read_chunks file, struct
    size   = file.read(4).unpack('N')[0]
    header = file.read(4)
    data   = file.read(size)
    crc    = file.read(4).unpack('N')[0]
    fail 'Invalid .png file' if crc != Zlib.crc32(header + data)

    #p header
    case header
    when 'IHDR'
      struct[:width] = data[0..3].unpack('N')[0]
      struct[:height] = data[4..7].unpack('N')[0]
      struct[:real_size]  = 2**Math.log2([struct[:width], struct[:height]].max).ceil
      struct[:bit_depth] = data[8].ord
      struct[:color_type] = data[9].ord
      struct[:compression_method] = data[10].ord
      struct[:filter_method] = data[11].ord
      struct[:interlace_method] = data[12].ord
#      ap struct
    when 'PLTE'
      struct[:plte] = data.unpack('C*')
    when 'IDAT'
      struct[:data] += data
    when 'IEND'
      return false
    when 'tRNS'
      if struct[:color_type] == 3
        struct[:px_trns] = data.unpack('C*')
      else
        struct[:px_trns] = *data.unpack('n*')
      end
    when 'tEXt', 'tIME', 'pHYs', 'gAMA'
      # Normalement peu importants
    else
      ap data
      puts 'Catastrophe !', 'un nouveau type de chunk !', header
    end
    return true
  end

  def load_bmp path, name
    full_path = path+name
    fail Errno::ENOENT, 'No such file or directory - '+full_path unless FileTest.exist? full_path
    file = File.open full_path, 'rb'
    struct = {:name => name}
    file.seek(18, IO::SEEK_CUR)
    struct[:width]      = file.read(4).unpack('i')[0]
    struct[:height]     = file.read(4).unpack('i')[0]
    struct[:real_size]  = 2**Math.log2([struct[:width], struct[:height]].max).ceil
    file.seek(28, IO::SEEK_CUR)
    size = struct[:width]*struct[:height]*3
    data = file.read(size).unpack('C*')
    file.close
    corrected = []
    # BGR => RGB & miror y
    blank = [0]*4*(struct[:real_size]-struct[:width])
    for y in 0...(struct[:height])
      for x in 0...(struct[:width])
        z = (struct[:height]-y-1)*struct[:width]*3 + 3*x
        corrected.push *data[z,3].reverse
        corrected << 255
      end
      corrected.push *blank
    end
    blank = [0]*4*struct[:real_size]
    (struct[:real_size]-struct[:height]).times {corrected.push *blank} # cause of too deep stack level
    struct[:data] = corrected.pack('C*')
    return struct
  end
end.new
end