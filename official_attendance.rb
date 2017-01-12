require 'google_drive'
require 'faker'

class OfficialAttendance 
  def initialize 
    @session = GoogleDrive.saved_session("config.json")
    @sheet = @session.spreadsheet_by_title("2016-2017 Attendance Tracker")
    puts "You have #{@sheet.worksheets.size} tabs"
    @sheet.worksheets.each do |ws|
      puts " --> #{ws.title}"
    end
    #puts @sheet.worksheets.inspect
    @hours = @sheet.worksheets.find { |ws| ws.title == "Attendance" }
  end
 
  def session
    @session
  end

  def set(row, col,value)
    @hours[row,col] = value
  end

  def get(row, col)
    @hours[row,col]
  end

  def save 
    @hours.save
  end 

  FIRST_NAMECOL = 1
  LAST_NAMECOL = 2

  FIRST_EVENT_COL = 3
  DATEROW = 2
  STUDENT_ROW = 7

  def dump_members
    puts "We have #{@hours.num_rows} rows of students"

    (STUDENT_ROW..@hours.num_rows).each do |row|
      name = "#{@hours[row,FIRST_NAMECOL]} #{@hours[row,LAST_NAMECOL]}".strip
      puts "Name: #{name}"
    end
  end

  def get_date_col(date)
    (FIRST_EVENT_COL..@hours.num_cols).each do |col|
      if date == Time.parse(@hours[DATEROW,col]).to_date.to_s
        return col
      end
    end

    nil
  end 

  def get_rfid_row(rfid)
    rfid = rfid.to_i
    (1..@hours.num_rows).each do |row|
      if rfid == @hours[row, RFIDCOL].to_i
        return row
      end 
    end 
    #could not find the id number
    new_row = @hours.num_rows + 1 
    @hours[new_row, RFIDCOL] = rfid
    @hours[new_row, TOTALCOL] = "=SUM(G#{new_row}:#{new_row})"  
    return new_row
  end 

  def get_name_row(lname, fname)
    lname = lname.to_s.strip.gsub(/\s+/," ")
    fname = fname.to_s.strip.gsub(/\s+/," ")
    (1..@hours.num_rows).each do |row|
      if fname == @hours[row, FIRST_NAMECOL].strip && lname == @hours[row, LAST_NAMECOL].strip
        return row
      end 
    end 

    return nil
  end 
end 

