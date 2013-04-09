# Original by Hexxeh https://github.com/Hexxeh/libpebble

class Stm32Crc
  
  CRC_POLY = 0x04C11DB7
  
  def self.process_word(data, crc=0xffffffff)
    if(data.length < 4)
      d_array = data.unpack('C*')
      (4 - data.length).times { d_array.insert(0,0) }
      d_array.reverse!
      data = d_array.pack('C*')  
    
    end
    d = data.unpack('L*')[0]
    crc = crc ^ d
    (0..31).each do
      if( crc & 0x80000000) != 0
        crc = (crc << 1) ^ CRC_POLY
      else
        crc = (crc << 1)
      end
    end
    result = crc & 0xffffffff
  end

  def self.process_buffer(buf, c = 0xffffffff)
    word_count = (buf.length / 4.0).ceil
    crc = c
    (0..word_count-1).each do |i|
      crc = process_word(buf[i * 4..(i+1) * 4], crc)
    end
    return crc
  end
  
  def self.hex(crc)
    [crc].pack('V').unpack('H*')[0]
  end
  def self.crc(data)
    hex(process_buffer(data))
  end
end