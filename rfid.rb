
class RFID
  
  def initialize(dev)
    @io = File.open(dev, "rb")
  end

  def close
    @io.close
  end

  def self.open(dev)
    rfid = RFID.new(dev)
    yield rfid
  ensure
    rfid.close
  end

  SPACE = 32
  RETURN = 28

  def next_char
    while true
      ev = @io.read(48);
      next if ev.size < 48
 
      v1, type, code, v2 = ev.unpack("x12lx8SSl")

      next if v1 == SPACE
      next if v2 != 1
      next if type != 1

      return nil if code == RETURN
      code -= 1
      code = 0 if code == 10
      return code.to_s
    end
  end

  def next_id
    buf = ""
    while ch = next_char
      buf += ch
    end
    return buf
  end
end


