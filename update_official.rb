
require_relative 'official_attendance'
require_relative 'attendance'
require 'date'
require 'time'

puts "Here we go"
attendance = Attendance.new
official = OfficialAttendance.new

today = Time.now.to_date.to_s
puts "Today: #{today}"
puts "Found at: #{official.get_date_col(today).inspect}"

attendance.each_date do |col, date|
  ocol = official.get_date_col(date)
  base_hours = 4
  base_hours = 8 if Date.parse(date).wday == 6
  min_hours = base_hours / 2

  puts "Date #{date} found at #{ocol}"
  attendance.each_student(col) do |row, fname, lname, hours|
    next if lname.to_s.strip.size == 0
    next if fname.to_s.strip.size == 0
    orow = official.get_name_row(lname,fname)
    next if orow.nil?
    next if hours.to_s.strip.size == 0
    hours = min_hours if hours == "X"
    next if hours.to_f < 0.01

    puts "#{lname}: #{hours} at #{official.get_name_row(lname,fname)}"
    hours = hours.to_f
    hours = min_hours if hours < min_hours
    hours = (hours * 4).ceil.to_f / 4

    puts "#{lname}: #{hours} at #{official.get_name_row(lname,fname)}"
    official.set(orow, ocol, hours.to_s)
  end
end
official.save

