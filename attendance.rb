require 'google_drive'
require 'faker'

class Attendance 
  def initialize 
    @session = GoogleDrive.saved_session("config.json")
    @sheet = @session.spreadsheet_by_title("Attendance")
    @hours = @sheet.worksheets[0]
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
  RFIDCOL = 3
  TOTALCOL = 4
  STUDCOL = 5
  EMAILCOL = 6
  FIRST_DATE_COL = 7

  DATEROW = 1

  def dump_members
    File.open("members.dat", "w") do |members|
      (DATEROW + 1..@hours.num_rows).each do |row|
        name = "#{@hours[row,FIRST_NAMECOL]} #{@hours[row,LAST_NAMECOL]}".strip
        id = @hours[row, RFIDCOL].to_s.rjust(10,'0')
        @hours[row, RFIDCOL + 3] = id
        stud = @hours[row, STUDCOL]
        studid = @hours[row, STUDCOL].to_s
        @hours[row, STUDCOL] = studid

        name = Faker::Name.name if name.to_s.length == 0
        members.puts "#{name}\t#{id}\t#{stud}"
      end
    end
  end

  def get_date_col(date)
    (1..@hours.num_cols).each do |col|
      next if col <= EMAILCOL

      if date == @hours[DATEROW,col]
        return col
      end
    end

    # did not find date, add it 
    @hours[DATEROW, @hours.num_cols + 1] = date 
    return @hours.num_cols
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

  def get_name_row(name)
    name = name.to_s.strip.gsub(/\s+/," ")
    (1..@hours.num_rows).each do |row|
      if name == "#{@hours[row, FIRST_NAMECOL]} #{@hours[row, LAST_NAMECOL]}".strip.gsub(/\s+/," ")
        return row
      end 
    end 

    return nil
  end 

  def each_date 
    (FIRST_DATE_COL..@hours.num_cols).each do |col|
      yield col, @hours[DATEROW, col]
    end
  end

  def each_student(col)
    data = nil
    (2..@hours.num_rows).each do |row|
      data = @hours[row, col] unless col.nil?
      yield row, @hours[row, FIRST_NAMECOL], @hours[row, LAST_NAMECOL], data
    end
  end

end 

