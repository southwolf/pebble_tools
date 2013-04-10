#!/usr/bin/env ruby

class Image
  attr_accessor :width, :height, :bitmap
end

img = Image.new

File.open(ARGV[0], 'rb') do |file|
  f = file.readlines
  fail if f[0].strip != "P1"
  img.width, img.height = f[1].strip.split(' ').map {|e| e.to_i}
  img.bitmap = ""
  (2..f.length - 1).each do |line|
    img.bitmap += f[line].strip.gsub(/\s/, "")
  end
  
  if img.bitmap.size % 32 != 0
    img.bitmap = img.bitmap + "0" * (32 - (img.bitmap.size % 32))
  end
  bit_array = img.bitmap.scan(/......../)
  bit_array.each { |s| s.reverse! }
  print bit_array.map! {|e| e.to_i(2)}
  hexmap = bit_array.pack("C*")
  File.open("font233", 'wb+') {|f| f.write(hexmap)}
end