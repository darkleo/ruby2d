module Ruby2D
ImageFile ||= Class.new {attr_reader :width, :height, :real_size, :data}
class PNG < ImageFile
  vars = [:path, :name, :width, :height, :bit_depth,
    :color_type, :compression_method, :filter_method,
    :interlace_method, :plte]
  attr_reader(*vars)
  def initialize path='', name
    @path, @name = path, name
    @data = read
    @corrected = false
  end
  def data force=false
    correct unless @corrected||force
    @data
  end
  def read
    fail Errno::ENOENT, 'No such file or directory - '+@path+@name unless FileTest.exist? @path+@name
    file = File.open @path+@name, 'rb'
    fail 'Invalid .png file' if file.read(8).unpack('C*') != [137, 80, 78, 71, 13, 10, 26, 10]
    @data = ''
    {} while read_chunks file
    file.close
    @data
  end
  def read_chunks file
    size   = file.read(4).unpack('N')[0]
    header = file.read(4)
    data   = file.read(size)
    crc    = file.read(4).unpack('N')[0]
    fail 'Invalid .png file' if crc != Zlib.crc32(header + data)
    
    case header
    when 'IHDR'
      @width = data[0..3].unpack('N')[0]
      @height = data[4..7].unpack('N')[0]
      @bit_depth = data[8].ord
      @color_type = data[9].ord
      @compression_method = data[10].ord
      fail 'Unknown compression' if @compression_method != 0
      @filter_method = data[11].ord
      fail 'Unknown filter' if @filter_method != 0
      @interlace_method = data[12].ord
      warn 'WARNING: Adam7 interlace method not supported' if @interlace_method == 1
    when 'PLTE'
      fail 'PLTE Error : chunk length not divisible by 3' if data.size%3 != 0
      @plte = []
      data.unpack('C*').each_slice(3){|s|@plte << s}
    when 'tRNS'
      @trns = case @color_type
      when 2 ; data.unpack('n*')
      when 3 ; data.unpack('C*')
      else
        fail 'tRNS still not supported'
      end
    when 'IDAT'
      @data += data
    when 'IEND'
      return false
    #~ when 'tRNS'
      #~ p data
      #~ if @color_type == 3
        #~ @px_trns = data.unpack('C*')
      #~ else
        #~ @px_trns = *data.unpack('n*')
      #~ end
    when 'tEXt', 'tIME', 'pHYs', 'gAMA', 'sBIT', 'zTXt', 'iTXt', 'cHRM', 'sRGB'
      #~ # Normalement peu importants
    else
      puts 'Catastrophe !', 'un nouveau type de chunk !', header
      p data
    end
    return true
  end
  def correct
    # TODOBETTER!
    str = Zlib::Inflate.inflate @data
    corrected = []
    case @color_type
    when 0 # Grayscale
      array = str.scan(/.{#{1+(@width*@bit_depth/8.0).ceil}}/m)
      i = 0
      last_line = [0]*(@width+1)
      array.each do |scanline|
        filter = scanline.slice!(0).unpack('C').first
        j = 0
        left = 0
        line = []
        corrected_line = []
        scanline.unpack('B*').first.scan(/.{#{@bit_depth}}/).each do |b|
          c = Integer('0b'+b)*255/(2**@bit_depth-1)
          c += case filter
            when 0 ; 0
            when 1 ; left
            when 2 ; last_line[j]
            when 3 ; (left + last_line[j])/2
            when 4 ; paeth last_line[j], left, last_line[j-1]
          end
          c = c%256
          left = c
          line << c
          corrected_line.push c, c, c, 255
          j += 1
        end
        i += 1
        corrected << corrected_line
        last_line = line << 0
      end
    when 2 # RGB
      fail "bit_depth = #{@bit_depth} non supported" unless @bit_depth == 8
      array = str.scan(/(.)(.{#{(3*@width*@bit_depth/8.0).ceil}})/m)
      i = 0
      last_line = [0]*3*(@width+1)
      array.each do |scanline|
        filter = scanline.first.unpack('C').first
        j = 0
        left = [0]*3
        line = []
        corrected_line = []
        scanline.last.unpack('C*').each_slice 3 do |c|
          3.times do |k|
            c[k] += case filter
              when 0 ; 0
              when 1 ; left[k]
              when 2 ; last_line[3*j+k]
              when 3 ; (left[k] + last_line[3*j+k])/2
              when 4 ; paeth last_line[3*j+k], left[k], last_line[3*j-3+k]
              else   ; 0
            end
            c[k] = c[k]%256
          end
          left = c
          line.push(*c)
          corrected_line.push(*c << (c == @trns ? 0 : 255))
          j += 1
        end
        i += 1
        corrected << corrected_line
        last_line = line.push 0, 0, 0
      end
    when 3 # PLTE
      array = str.scan(/(.)(.{#{(@width*@bit_depth/8.0).ceil}})/m)
      array.each do |scanline|
        filter = scanline.first.unpack('C').first
        line = []
        scanline.last.unpack('B*').first.scan(/.{#{@bit_depth}}/).each do |k|
          i = Integer('0b'+k)
          pixel = @trns.include?(i) ? [0, 0, 0, 0] : (@plte[i].dup << 255)
          line.push(*pixel)
        end
        corrected << line
      end
    when 4 # Grayscale + alpha
      array = str.scan(/.{#{1+(2*@width*@bit_depth/8.0).ceil}}/m)
      i = 0
      last_line = [0]*(2*@width+1)
      array.each do |scanline|
        filter = scanline.slice!(0).unpack('C').first
        j = 0
        left = [0]*2
        line = []
        corrected_line = []
        scanline.unpack('B*').first.scan(/(.{#{@bit_depth}})(.{#{@bit_depth}})/).each do |c|
          2.times do |k|
            c[k] = Integer('0b'+c[k])*255/(2**@bit_depth-1)
            c[k] += case filter
              when 0 ; 0
              when 1 ; left[k]
              when 2 ; last_line[2*j+k]
              when 3 ; (left[k] + last_line[2*j+k])/2
              when 4 ; paeth last_line[2*j+k], left[k], last_line[2*j-2+k]
              else   ; 0
            end
            c[k] = c[k]%256
          end
          left = c
          line.push(*c)
          corrected_line.push c[0], c[0], c[0], c[1]
          j += 1
        end
        i += 1
        corrected << corrected_line
        last_line = line.push 0, 0
      end
    when 6 # RGBA
      fail "bit_depth = #{@bit_depth} non supported" unless @bit_depth == 8
      array = str.scan(/(.)(.{#{(4*@width*@bit_depth/8.0).ceil}})/m)
      i = 0
      last_line = [0]*4*(@width+1)
      array.each do |scanline|
        filter = scanline.first.unpack('C').first
        j = 0
        left = [0]*4
        line = []
        scanline.last.unpack('C*').each_slice 4 do |c|
          4.times do |k|
            c[k] += case filter
              when 0 ; 0
              when 1 ; left[k]
              when 2 ; last_line[4*j+k]
              when 3 ; (left[k] + last_line[4*j+k])/2
              when 4 ; paeth last_line[4*j+k], left[k], last_line[4*j-4+k]
              else   ; 0
            end
            c[k] = c[k]%256
          end
          left = c
          line.push(*c)
          j += 1
        end
        corrected << line.dup
        last_line = line.push 0, 0, 0, 0
        i += 1
      end
    else
      fail 'PNG mode unknow'
    end
    @data = corrected.map {|line| line.pack 'C*'}
    @corrected = true
  end
  def paeth a, b, c
    e = a + b - c
    ea, eb, ec = *[a, b, c].map {|k| (e-k).abs}
    return a if ea<=eb && ea<=ec
    eb<=ec ? b : c
  end
  protected :paeth
  
  def self.write bitmap, path
    file = File.new(path, 'wb')
    file.write([137, 80, 78, 71, 13, 10, 26, 10].pack('C*'))
    write_chunk file, 'IHDR', [bitmap.width, bitmap.height, 8, 6, 0, 0, 0].pack('NNCCCCC')
    data = bitmap.data.map {|s| [0].pack('C')+s}.join
    write_chunk file, 'IDAT', Zlib::Deflate.deflate(data)
    write_chunk file, 'IEND'
    file.close
  end
  def self.write_chunk file, header, data=''
    file.write([data.size].pack('N')+header+data+[Zlib.crc32(header+data)].pack('N'))
  end
end
end