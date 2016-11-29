require_relative "attendance"
require "time"

def log_rfid_running?
  system %Q|pgrep -f "^ruby log_rfids.rb"|
end

def new_day? 
  if !File.exists?("lastran")
    File.open("lastran","w") do |lr|
      lr.puts Date.today
    end
  end 

  IO.read("lastran").chomp != Date.today.to_s
end

def stop_log_rfid
  system %Q|pkill -f "^ruby log_rfids.rb"|
end
 
def rename_log_file
  system %Q|mv rfid.log rfid-#{IO.read("lastran").chomp}.log|
end
 
def start_log_rfid
  log_file = ['/home/pi/Attendance_System/reader.log', 'a']
  pid = Process.spawn("ruby log_rfids.rb", :out => log_file, :err => log_file)
  # Detach the spawned process
  Process.detach pid
end

punches = {}
today = nil 

if new_day?
  stop_log_rfid
  rename_log_file
  start_log_rfid
  File.unlink "lastran"
else
  # verify log_rfids is running
  if !log_rfid_running?
    start_log_rfid
  end
end

attendance = Attendance.new

File.open("rfid.log", "r") do |log|
  log.each_line do |line|
    if line.match /(.*) (.+)$/
      time,id=Time.parse($1),$2
      col = attendance.get_date_col(time.to_date.to_s)
      row = attendance.get_rfid_row(id.to_i)
      if today != time.to_date
        today = time.to_date
        punches = {} 
      end 
       
      # puts "Process #{id} at #{time} for #{today} (#{row},#{col})"
      if punches[id]
        attendance.set(row, col, (time - punches[id])/(60*60))
      else 
        punches[id] = time
        attendance.set(row,col,"X")
      end 
    end   
  end
end
attendance.save
