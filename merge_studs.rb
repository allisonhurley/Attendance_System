require 'pp'
require_relative "attendance"
require "time"

attendance = Attendance.new

stud_form = attendance.session.spreadsheet_by_title("Lightning Attendance Thing (Responses)")
results = stud_form.worksheets[0]

responses = {}
(1..results.num_rows).each do |row|
  responses[results[row,2]] = [results[row,3], results[row, 4]]
end

responses.keys.each do |name|
  row = attendance.get_name_row(name)

  if row.nil? 
    puts "Unable to find #{name.inspect}"
  else
    studid = responses[name].first
    email = responses[name].last
    attendance.set(row, Attendance::STUDCOL, studid)
    attendance.set(row, Attendance::EMAILCOL, email)
  end
end

attendance.save
