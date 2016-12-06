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
stud_lookup = {}
members.each do |name, rfid, studid|
  rfid = rfid.rjust(10, "0")
  rfid_lookup[rfid] = name
  stud_lookup[studid.chomp] = rfid
end

punches = {}

last_member = "Lightning Attendance System"
status = ""
input = ""
kickoff = Time.new(2017,1,7,10)
bag = Time.new(2017,2,22)
log = File.open("rfid.log")
screen = Screen.new
screen.poll do |evt, scr|
  scr.text(last_member, 10, 10)
  scr.text(status, 10, 80)
  scr.text(input, 10, 150)
  now = Time.now
  scr.text(now.strftime("%d %b %Y %l:%M:%S %P"), 10, scr.height - 50, 25)
  scr.text(sprintf("%s-%s", online? ? "online" : "offline", ip_address), 
           10, scr.height - 25, 25)
  if kickoff >= now
    scr.text(sprintf("kickoff: %d days %d:%02d:%02d", *seconds_to_dhms(kickoff- now)), 10, scr.height - 75, 25)
  else
    scr.text(sprintf("bag: %d days %d:%02d:%02d", *seconds_to_dhms(bag- now)), 10, scr.height - 75, 25)
  end
begin
  if line = log.gets
    if line.match(/^(.*) (\d+)$/) 
      date,rfid = $1,$2
      date = Time.parse(date) 
      last_member = rfid_lookup[rfid]
      input = "" 
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

  if evt.type == :KEYUP 
    # puts "Event #{evt.key.keysym.sym.inspect}"
    # puts (evt.key.public_methods - Object.new.public_methods).sort.join("\n")
    # STDOUT.flush

    key = evt.key.keysym.sym
    ch = key.to_s
    if ch.match(/KP_(\d)/)
      last_member = " " 
      status = " " 
      input += $1
    elsif key == :BACKSPACE
      input = input[0..-2]
    elsif key == :KP_ENTER
      if input.size > 0 && stud_lookup[input] != nil
        status = stud_lookup[input]
        last_member = rfid_lookup[status]
      else 
        last_member = "ID not found"
      end 
      File.open("rfid.log", "a") do |l|
        l.puts Time.now.to_s + " " + status 
      end   
      input = "" 
    elsif key == :KP_MULTIPLY 
      last_member = "Joe is mom, don't forget to thank mom"
      status = "" 
      input = ""
    elsif key == :KP_PERIOD 
      last_member = "Mr. O is the  best"
      status = "" 
      input = ""
    elsif key == :KP_PLUS 
      last_member = "You ugly! You your daddy's son!"
      status = "" 
      input = ""
    elsif key == :KP_MINUS 
      last_member = "ALLISON IS SUMPREMEST HUMAN!!!"
      status = "" 
      input = ""
    elsif key == :KP_DIVIDE 
      last_member = "Ada Lovelace, ask programming"
      status = "" 
      input = ""
    elsif key == :NUMLOCKCLEAR 
      last_member = "Ouch don't press that"
      status = "" 
      input = ""
    else
      last_member = key.to_s
      status = "" 
      input = ""
    end
     
  end

  if evt.type == :MOUSEBUTTONUP 
    # puts evt.button.x
    # puts evt.button.y

  else 
  end

end

