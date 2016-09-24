
require_relative 'rfid'

def process_rfid(device)
  RFID.open(device) do |rfid|
    File.open("rfid.log", "w") do |log|
      while true
        log.puts rfid.next_id
      end
    end
  end
end

Dir.glob("/dev/input/event*").each do |event|
  Thread.new { process_rfid(event) }
end

while true
  sleep 30
end

