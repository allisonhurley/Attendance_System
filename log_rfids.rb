
require_relative 'rfid'

def process_rfid(device)
  # puts "Opening #{device}"
  RFID.open(device) do |rfid|

    # puts "Opened #{device}"
    File.open("rfid.log","a") do |log|

      while true
        id = rfid.next_id
        # puts "We have >#{id}<"
        log.puts Time.now.to_s + " " + id
        log.flush
      end

      sleep 0.5
    end
  end
end

Dir.glob("/dev/input/by-id/usb-Sycread*").each do |event|
  Thread.new do 
    while true
      begin
        process_rfid(event) 
      rescue StandardError => e
        File.open("error.log", "a") do |err|
          err.puts "Error: #{e}"
        end
      end
      sleep 5
    end
  end

  sleep 3
end

while true
  sleep 30
end

