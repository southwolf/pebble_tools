# http://pebbledev.org/wiki/Resource_Font_Format
require "./stm32_crc"

class Character
  attr_accessor :index, :unicode, :char, :offset, :length, :width, :height, :image #:byte2, :byte3, :bytes4to7,
end

File.open(ARGV[0], 'rb') do |f|
  f.seek(1)
  font_size = f.read(1)[0].ord
  puts "Font Size: #{font_size}"
  num_of_chars = f.read(2).unpack('S*')[0]
  puts "Number of Chars: #{num_of_chars}"
  chars = Array.new(num_of_chars)
  
  f.seek(6)
  f2 = File.open(ARGV[0], 'rb')
  chars.each_with_index  do |c,i|
    c = Character.new
    charInfo = f.read(4)
    c.index = i
    c.unicode = charInfo[0..1].unpack('S*')[0]
    c.char = [c.unicode].pack('U*')
    c.offset = charInfo[2..3].unpack('S*')[0]
    chars[i] = c
  
    if(i > 0)
      chars[i-1].length = 4 * (c.offset - chars[i-1].offset)
    end
  end
  
  chars.last.length = f.size - 6 - 4 * num_of_chars - 4 * chars.last.offset

  Dir.mkdir("_#{ARGV[0]}")
  chars_list = File.open("_#{ARGV[0]}/glyphs.txt", 'a+:BOM|UTF-8')
  
  f2.seek(6 + 4 * num_of_chars + 4 * chars[0].offset)
  chars.each_with_index do |c,i|
      charData = f2.read(c.length)
      c.width = charData[0].ord
      c.height = charData[1].ord
      # c.byte2 = charData[2].ord
      # c.byte3 = charData[3].ord
      # c.bytes4to7 = charData[4..7].unpack('L*')[0]
      c.image = charData[8..c.length]
      chars_list.puts "#{c.index}:\t#{c.char}\t#{c.width} x #{c.height}\tu: #{c.unicode}\tl: #{c.length}"
      fout = File.open("_#{ARGV[0]}/#{i}", 'wb')
      # fout.write(c.image)
      fout.write(charData)
      if i == chars.length - 1
        break
      end
  end
end