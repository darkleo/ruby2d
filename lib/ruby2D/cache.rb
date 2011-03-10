module Ruby2D
module Cache
  extend self
  
  @data = {}
  @local = ['']
  EXTS = %w(.png .bmp)
  
  def load_bitmap name
    return @data[name] if @data.include? name
    unless File.extname(name).empty?
      names = [name]
    else
      names = EXTS.map {|ext| name+ext}
    end
    @local.reverse_each do |path|
      names.each do |str|
        load_with_path path, str, name
        return @data[name] if @data.include? name
      end
    end
    fail Errno::ENOENT, name
  end
  def add_location local
    @local << local
  end
  def remove_location local
    @local.delete local
  end
  
  private
  def load_with_path path, name, original_name
    begin
      case File.extname name
      when '.img'
        @data[original_name] = load_img path, name
      when '.png', '.PNG'
        @data[original_name] = PNG.new path, name
      when '.bmp'
        @data[original_name] = BMP.new path, name
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
end
end