module Ruby2D
ImageFile ||= Class.new {attr_reader :width, :height, :real_size, :data}
class BMP < ImageFile
  def initialize path, name
    @path, @name = path, name
    @data = correct(read)
  end
  
  private
  def read
    fail Errno::ENOENT, 'No such file or directory - '+@path+@name unless FileTest.exist? @path+@name
    file = File.open @path+@name, 'rb'
    file.seek 18, IO::SEEK_CUR
    @width  = file.read(4).unpack('i')[0]
    @height = file.read(4).unpack('i')[0]
    @real_size  = 2**Math.log2([@width, @height].max).ceil
    file.seek 28, IO::SEEK_CUR
    @size = @width*@height*3
    data = file.read(@size).unpack('C*')
    file.close
    data
  end
  def correct data
    corrected = []
    # BGR => RGB & miror y
    data.each_slice(3*@width) do |line|
      temp = []
      line.each_slice(3) {|pixel| temp.push(*pixel.reverse << 255)}
      corrected = temp.push(*corrected)
    end
    corrected.pack 'C*'
  end
end
end