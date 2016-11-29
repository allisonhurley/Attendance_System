#!/usr/bin/ruby 

require 'sdl2/ttf'
require 'sdl2/image'
require 'socket'
require 'time' 
require 'net/ping'

require_relative 'screen'

def online?
  if @last_check.nil? || (Time.now - @last_check) > 300
    # @last_check_status = Net::Ping::HTTP.new("http://google.com").ping?
    @last_check_status = Net::Ping::TCP.new("8.8.8.8", 53).ping?
  else
    @last_check_status
  end
end

def ip_address
  Socket.ip_address_list.detect{|a| a.ipv4? && !a.ipv4_loopback? && !a.ipv4_multicast? }.getnameinfo.first
end

def seconds_to_dhms(seconds)
  days,seconds = seconds.divmod(86400)
  hours,seconds = seconds.divmod(3600)
  mins,seconds = seconds.divmod(60)
  [days, hours, mins, seconds]
end

sleep 1
Dir.chdir(File.expand_path(File.dirname(__FILE__)))

members = IO.read("members.dat").each_line.map {|l| l.split("\t")}
rfid_lookup = {}
members.each do |name, rfid, studid|
  rfid_lookup[rfid.rjust(10,"0")] = name
end

punches = {}

last_member = "Lightning Robotics"
status = "Attendance System"

log = File.open("rfid.log")
screen = Screen.new
screen.poll do |evt, scr|
  scr.text(last_member, 10, 10)
  scr.text(status, 10, 80)
  now = Time.now
  scr.text(now.strftime("%d %b %Y %l:%M:%S %P"), 10, scr.height - 50, 25)
  scr.text(sprintf("%s-%s", online? ? "online" : "offline", ip_address), 
           10, scr.height - 25, 25)

begin
  if line = log.gets
    if line.match(/^(.*) (\d+)$/) 
      date,rfid = $1,$2
      date = Time.parse(date) 
      last_member = rfid_lookup[rfid]
      if punches[rfid] 
        seconds = (date.to_i - punches[rfid].to_i)
        days,hours,minutes,seconds = seconds_to_dhms(seconds)
        status = sprintf("Hours %02d:%02d:%02d", hours, minutes, seconds)
      else
        punches[rfid] = date
        status = "Punch In"  
      end
    end
  else
    if log.stat.size <= 0
      log.close
      punches = {}
      log = File.open("rfid.log")
    end
  end

rescue Exception => e
  puts "Error: #{e}"
end
  
  next if evt.nil? 

  if evt.type == :MOUSEBUTTONUP 
    puts evt.button.x
    puts evt.button.y

  else 
  end

end

