# http://pebbledev.org/wiki/Firmware_Updates

require "./stm32_crc"
class Resource
  attr_accessor :index, :offset, :size, :crc, :data
end


File.open('system_resources.pbpack', 'rb') do |f|
  
  # 0x00 : Number of resources
  num_of_res = f.read(1)[0].ord
	
  puts "Number of resources: #{num_of_res}"

  # 0x04 - 0x07 : CRC of 0x101C-EOF (all resource data without header)
  f.seek(4)

  puts "CRC of resources: " + f.read(4).unpack('H*')[0].to_s

  f.seek(4124)
  puts "Expected: #{Stm32Crc.crc(f.read)}"

  # 0x0C - 0x1B
  f.seek(12)
  version = f.read(15)
  puts "Version: " + version

  # 0x1C - 0x101B: Resource entries
  resources = Array.new(num_of_res)
  f.seek(28)

  (1..num_of_res).each do
    res = f.read(16) # Length of a entry
    resIdx = res[0].ord - 1 # Ensure the index
    resources[resIdx] = Resource.new
    resources[resIdx].index = res[0].ord
    resources[resIdx].offset = res[4..7].unpack('L*')[0]
    resources[resIdx].size = res[8..11].unpack('L*')[0]
    resources[resIdx].crc = res[12..15].unpack('H*')[0]

    # Read Data
    f2 = File.open('system_resources.pbpack', 'rb')
    # Data begins at 0x101C
    f2.seek(4124+resources[resIdx].offset)
    resources[resIdx].data = f2.read(resources[resIdx].size)
     
    fout = File.open("res#{resIdx+1}", 'wb')
    fout.write(resources[resIdx].data)
    fout.close
    
    fdone = File.open("res#{resIdx+1}", 'rb')
    crcactual = Stm32Crc.crc(fdone.read)
    if(resources[resIdx].crc != crcactual)
      puts "CRC of resource #{resIdx+1} mismatch, expected: #{resources[resIdx].crc}, actual: #{crcactual}"
    end
  end

end