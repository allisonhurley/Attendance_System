#!/usr/bin/ruby 

require 'sdl2/ttf'
require 'sdl2/image'
require "time" 

require_relative 'screen'

sleep 7
Dir.chdir("/home/pi/Attendance_System")

members = IO.read("members.dat").each_line.map {|l| l.split("\t")}
rfid_lookup = {}
members.each do |name, rfid, studid|
  rfid_lookup[rfid.rjust(10,"0")] = name
end

punches = {}

last_member = "Lightning Robotics Attendance System"

log = File.open("rfid.log")
status = " " 
screen = Screen.new
screen.poll do |evt, scr|
  scr.text(last_member, 10, 10)
  scr.text(status, 10, 80)
  scr.text(Time.now, 10, 200, 25)

begin
  if line = log.gets
    if line.match(/^(.*) (\d+)$/) 
      date,rfid = $1,$2
      date = Time.parse(date) 
      last_member = rfid_lookup[rfid]
      if punches[rfid] 
        seconds = (date.to_i - punches[rfid].to_i)
        hours = 0
        minutes = 0  
        while seconds >= 3600 
          hours+=1
          seconds-=3600
        end
        while seconds >= 60
          minutes+=1
          seconds-=60
        end
        status = sprintf("Hours %02d:%02d", hours,minutes)
      else
        punches[rfid] = date
        status = "Punch In"  
      end
    end
  else
    sleep(0) 
  end

rescue Exception => e
  puts "Error: #{e}"
end
  
  next if evt.nil? 

  if evt.type == :QUIT 
    scr.quit

  elsif evt.type == :KEYUP && evt.key.keysym.sym == :Q
    scr.quit
  
  elsif evt.type == :MOUSEBUTTONUP 
    puts evt.button.x
    puts evt.button.y

  else 
  end

end

