require 'google_drive'

class Attendance
  RFID_COLUMN = 2
  DATE_ROW = 1

  def initialize
    @session = GoogleDrive.saved_session("config.json")
    @sheet = @session.spreadsheet_by_title("Attendance")
    @hours = @sheet.worksheets[0]
    @rfid_cache = {}
    @date_cache = {}
  end

  def find_rfid_row(id)
    row = @rfid_cache[id]
    if row.nil?
      (2..@hours.num_rows).each do |r|
        if @hours[r, RFID_COLUMN].to_i == id.to_i
          @rfid_cache[id] = r
          return r
        end
      end
    end
    row
  end

  def find_date_column(date)
    col = @date_cache[date]
    if col.nil?
      (3..@hours.num_cols).each do |c|
        if @hours[DATE_ROW, c] == date
          @date_cache[date] = c
          return c
        end
      end
    end
    col
  end

  def rfid_row(id)
    row = find_rfid_row(id)
    if row.nil?
      row = @hours.num_rows + 1
      @hours[row, RFID_COLUMN] = id
      @rfid_cache[id] = row
    end
    row
  end

  def date_column(date)
    col = find_date_column(date)
    if col.nil?
      col = @hours.num_cols + 1
      @hours[DATE_ROW, col] = date
      @date_cache[date] = col
    end
    col
  end

  def save
    @hours.save
  end
end

if __FILE__ == $0
  attendance = Attendance.new
  id = "0011830433" 
  puts attendance.date_column(Date.today.to_s)
  attendance.save
end


