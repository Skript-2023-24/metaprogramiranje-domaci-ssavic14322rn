require "google_drive"

session = GoogleDrive::Session.from_config("config.json")
ws = session.spreadsheet_by_key("1ZwnNhN4Uj96DklpoDbJylT8tNVakcjoJK3m9cghfoqQ").worksheets[0]

class MyColumn

    attr_accessor :arr, :worksheet, :col_idx

    def initialize(col_idx, worksheet, row_start, col_start)
        @arr = []
        @col_idx = col_idx
        @row_start = row_start
        @col_start = col_start
        @worksheet = worksheet
    end

    def avg
        suma = @arr.sum(&:to_i)
        suma.to_f / @arr.length
    end

    def sum
        @arr.sum(&:to_i)
    end

    def map(&block)
        @arr.map(&block)
    end

    def select(&block)
        @arr.select(&block)
    end

    def reduce(&block)
       
    end

    def [](idx)
        @arr[idx]
    end

    def []= (idx, data)
        return unless idx
        @arr[idx] = data.to_s
        @worksheet[idx + @row_start, @col_idx + @col_start] = data.to_s
        @worksheet.save
    end

end

class MyTable
    include Enumerable
    attr_accessor :table, :worksheet, :row_start, :col_start, :headers, :table_r
  
    def initialize(worksheet)
      @worksheet = worksheet
      @row_start = nil
      @col_start = nil
      @headers = []
      @table_r = []
      @table = {}
      find_start
      header
      init_table
      col_method
    end
  
    private def init_table
      @headers.each_with_index do |header, i|
        @table[header] = MyColumn.new(i, @worksheet, @row_start, @col_start)
      end
  
      ((@row_start + 1)..@worksheet.num_rows).each do |row|
        tmp_row = []
        (@col_start..@worksheet.num_cols).each_with_index do |col, j|
          break if @worksheet[row, col] == 'subtotal' || @worksheet[row, col] == 'total'

          @table[@headers[j]].arr << worksheet[row, col]
          tmp_row << worksheet[row, col]
        end
        @table_r << tmp_row unless tmp_row.empty?
      end
    end
  
    private def header
      (@col_start..@worksheet.num_cols).each do |col|
        @headers << @worksheet[@row_start, col]
      end
    end
  
    private def find_start
      (1..@worksheet.num_rows).each do |row|
        (1..@worksheet.num_cols).each do |col|
          if @row_start.nil? && @worksheet[row, col] != ''
            @row_start = row
            @col_start = col
          end
        end
      end
    end
  
    private def col_method
      @headers.each do |col_name|
        col_name.downcase!
        method_name = col_name.split.map(&:capitalize).join
        method_name[0] = method_name[0].downcase!
        self.class.define_method(method_name) { @table[col_name] }
      end
    end
  
    def [](idx)
      @table[idx]
    end
  
    def row(index)
        @table_r[index-1]
    end
  
    def each
      (row_start..@worksheet.num_rows).each do |row|
        (col_start..@worksheet.num_cols).each do |col|
            value = @worksheet[row, col]
            yield value if block_given?
        end
      end
    end

    def +(other_table)
        raise "Tabele nemaju iste header-e" unless @headers == other_table.headers
    
        new_table = MyTable.new(@worksheet)
        @headers.each do |header|
          new_table.table[header] = @table[header] + other_table.table[header]
        end
        new_table
    end
    
    def -(other_table)
        raise "Tabele nemaju iste header-e" unless @headers == other_table.headers
    
        new_table = MyTable.new(@worksheet)
        @headers.each do |header|
          new_table.table[header] = @table[header] - other_table.table[header]
        end
        new_table
    end

end

t = MyTable.new(ws)
# puts t["prva kolona"][3]
t["prva kolona"][2]= 99
puts t.row(2)
puts t.prvaKolona
puts t.prvaKolona.avg
puts t.prvaKolona.map{ |cell| cell.to_i.even? }

t.each do |el|
    puts el

end