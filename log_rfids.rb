require 'thread'
require_relative 'rfid'

@queue = Queue.new

def process_rfid(device)
  puts "Opening #{device}"
  RFID.open(device) do |rfid|

    while true
      id = rfid.next_id

      # assume an error state and attempt to reopen
      return if id.nil? || id.size != 10

      puts "We have >#{id}<"
      @queue << id
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
  id = @queue.pop
  puts "Process #{id}"

  File.open("rfid.log","a") do |log|
    log.puts Time.now.to_s + " " + id
  end
end

