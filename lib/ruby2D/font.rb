class Ruby2D::Font
  Size = 16
  def initialize name
    @bitmap = Ruby2D::Bitmap.new name
  end
  def render text
    strs = text.split(/\n/)
    he = strs.size*Size
    we = strs.map(&:size).max*Size
    bitmap = Ruby2D::Bitmap.new strs.map(&:size).max*Size, strs.size*Size
    s = Rect.new 0..16, 0..16
    strs.each.with_index do |str,j|
      i = 0
      str.encode('ISO-8859-1').each_byte do |b|
        s.move!(16*(b%16), 16*(b/16))
        w = 12
        (0...16).each do |x|
          next unless (0...16).map {|y| @bitmap.get_pixel(16*(b%16)+(15-x),16*(b/16)+y).a != 0}.any?
          w = 15-x
          break
        end
        bitmap.blt @bitmap, s, i, Size*j, :source
        i += w + 1
      end
    end
    bitmap
  end
end