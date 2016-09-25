require 'google_drive'

class Attendance 
  def initialize 
    @session = GoogleDrive.saved_session("config.json")
    @sheet = @session.spreadsheet_by_title("Attendance")
    @hours = @sheet.worksheets[0]
  end
  
  def set(row, col,value)
    @hours[row,col] = value
  end

  def save 
    @hours.save
  end 

  DATEROW = 1
  RFIDCOL = 2

  def get_date_col(date)
    (1..@hours.num_cols).each do |col|
      if date == @hours[DATEROW,col]
        return col
      end
    end
    # did not find date, add it 
    @hours[DATEROW, @hours.num_cols + 1] = date 
    return @hours.num_cols
  end 

  def get_rfid_row(rfid)
    (1..@hours.num_rows).each do |row|
      if rfid == @hours[row, RFIDCOL].to_i
        return row
      end 
    end 
    #could not find the id number 
    @hours[@hours.num_rows + 1, RFIDCOL] = rfid 
    return @hours.num_rows
  end 
end 
