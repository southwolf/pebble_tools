#!/usr/bin/env ruby

class Image
  attr_accessor :width, :height, :bitmap
end

img = Image.new

hexmap = nil
File.open(ARGV[0], 'rb') do |f|
  data = f.read
  img.width = data[0].ord
  img.height = data[1].ord
  img.bitmap = ""
  puts "#{img.width} x #{img.height}"
  hexmap = data[8..-1].unpack("H*")[0]  # hex string. Caution when begin with ZERO. cannot use to_i(16).to_s(2)!!
end

# puts hexmap
hexmap.each_char do |c|
 bin =  c.to_i(16).to_s(2)
 (4 - bin.length).times { bin = "0" + bin }
 img.bitmap  = img.bitmap + bin
end

bit_array = img.bitmap.scan(/......../)
bit_array.each { |s| s.reverse! }
bitmap2 = bit_array.join

bitmap2.each_char.with_index do |c, i|
  line_num = i / img.width
  
  if line_num  == img.height
    break
  end
  
  if i % img.width == 0
    print "#{line_num + 1}\t"
  end
  if(c == '1')
    print 'x'
  else
    print '.'
  end
  if((i+1) % img.width == 0)
    puts
  else
    print ' '
  end
end