require_relative "attendance"
require "time"

attendance = Attendance.new
punches = {}
today = nil 
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
      if punches[id]
        attendance.set(row, col, (time - punches[id])/(60*60))
      else 
        punches[id] = time
        attendance.set(row,col,0)
      end 
    end   
  end
end
attendance.save
