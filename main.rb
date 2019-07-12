#! /usr/bin/env ruby

# Usage: ~/Code/CLI/flowcharts/chartwolf.rb ~/file.gv

## DEPENDENCIES

require "fileutils"
require_relative "./lib/verbose"
require_relative "./lib/flowchart_keyword_list"
require_relative "./lib/diacritic_list"

## OPTION PARSER

# none

## PATHS

TEMP_FILE = "#{Dir.home}/temp_graphviz.gv"

## CONSTANTS

MARKERS = {
  start_node: "## NODES",
  end_node: "## EDGES"
}

LINE_LENGTH = 40
TABLE_BORDER_THICKNESS = 3 # TODO: move to Configure border thickness in the flowchart_keyword_list.

## DIALOGUE

VERBOSE = true

DIALOGUE_ARRAY = {
  sorted: "Sorted",
  formatted: "Formatted",
  processed: "Processed. Number of lines:",
  diacritics: "Diacritics corrected",
  trash: "Trashed SVG temp files"
}

TEMP_FILES = [ ".svg" ]

$overall_text = {
  prenode: [],
  node: [],
  postnode: []
}

def calc_table_line_length_per_column(columns)
  case columns
  when 1 then LINE_LENGTH
  when 2..6 then LINE_LENGTH - (columns * 5)
  else LINE_LENGTH/4
  end
end

## CLASSES

class Cell
  attr_accessor :row_span, :additional_for_row_span, :col_span

  def initialize(cell)
    @cell = cell
  end

  def highlight? # an asterisk in the prefix means highlight the row. (and highlighting usually means colour background + bold.)
    @cell.highlight?
  end

  def text # an asterisk in the prefix means highlight the row. (and highlighting usually means colour background + bold.)
    @cell.text
  end

  def col_span_thingy(table_line_length_per_column)
    table_line_length_per_column*@col_span
  end

end

class Line
  @@lines = []

  attr_accessor :line, :text, :prefix, :row_span, :additional_for_row_span, :col_span

  def initialize(line, current_row)
    @line = line
    @current_row = current_row
    @line_match = @line.match(/^([\#\s\*\+\-]*)(.+)/) # two capture groups: prefix and text
    @prefix = $1
    @text = $2
    @@lines << self # add this to the list of lines in the item
    @row_span = 1
  end

  def column_begin(previous_rows, previous_columns_on_this_row) # on what column does this cell (incl multi-column cell) start?
    if stack? # TODO: this will be OK for the moment (because I won't have many rack-rack-rack tables. but will need to be adjusted (i.e. if third column in a rack table has some further stacked subdivisions, they would be one-spaced, but in fact in third column).)
      iterator = @prefix.match(/^\s*[\#\s\*\+\-]/).to_s.count(" ") # how many spaces tells you what column it is in. 0=first, etc.
    elsif rack? # can't I just count the array items in previous_columns_on_this_row and get the column_begin of the last item in previous_rows???
      previous_lines = previous_rows + previous_columns_on_this_row
      iterator = 0
      previous_lines.flatten.reverse.each { |line|
        if line.line.start_with?(/[\s]*\-/)
          iterator = (iterator + line.column_begin(previous_rows, previous_columns_on_this_row)) # might have to change these variables
          break
        else # could make this .start_with?(/[\s]*\+/) for extra security
          iterator += 1
        end
        } #how many +s before, added to the position of the previous stack, tells you what column it is in. first-child of first-column = 0+0= 0=first, etc. first-child of second column = 0+1=1, etc.
    end
    iterator
  end

#  def col_span_thingy(table_line_length_per_column)
#    table_line_length_per_column*@col_span
#  end

  def type?(type)
    symbol = case type
    when :name then "\#"
    when :style then "{"
    when :stack then "-"
    when rack then "+"
    when highlight then "*"
    when item_end then ""
    end
    @prefix.include?(symbol)
  end

  def name? # [DEPRECATED: type? method] a hash in the prefix means this is the name of the row
    @prefix.include?("\#")
  end

  def style? # beginning with curly braces means this is the style
    @line.include?("{")
  end

  def stack? # [DEPRECATED: type? method] an hyphen in the prefix means a 'stack' i.e. vertical list
    @prefix.include?("-") # any advantage to  @line.match(/^[\s]*\-/)   ?
  end

  def rack? # [DEPRECATED: type? method] a plus in the prefix means a 'rack' i.e. horizontal list
    @prefix.include?("+")
  end

  def highlight? # [DEPRECATED: type? method] an asterisk in the prefix means highlight the row. (and highlighting usually means colour background + bold.)
    @prefix.include?("*")
  end

  def item_end? # is this line a divider between items?
    @line.strip.eql?("") # empty (or spaces) string ## isn't line an array?
  end

  def self.lines
    @@lines
  end
end

class Item
  @@items = []

  attr_accessor :item, :name_text, :item_name, :item_style, :color, :shape, :table_line_length_per_column

  def initialize(name)
    @item = [] # create array, to put lines into
    @name_text = name.delete_prefix("# ")
    @@items << self # add this to the list of items in the chart
  end

  def add_line_to_item(line) # add line to array of lines.
    @item << line.rstrip
  end

  def item_size
    @item.size
  end

  def item_lines
    @item
  end

  def self.all_items
    @@items
  end

  def complete? # check if complete # last item will always be empty (or spaces) string
    @item.last.strip.eql?("") #why does .item_end? not work here?
  end

  def check_for_row_spans(temp_row_array)
    array_of_indent_counts = []
    temp_row_array.flatten.reverse.each { |line|
        if line.type?(:stack) then array_of_indent_counts << line.prefix.count(" ") end
      }
    previous_row_indent_number = -1
    iterator = 0
    array_of_stacks_within_rows = []
    array_of_indent_counts.each { |this_row_indent_number|
      if this_row_indent_number.eql?(previous_row_indent_number) then array_of_stacks_within_rows << [iterator, (iterator + 1)] end
      previous_row_indent_number = this_row_indent_number
      iterator += 1
    }
    array_of_stacks_within_rows
  end

  def act_on_row_spans(temp_row_array, array_of_stacks_within_rows)
    iterator = 0
    temp_row_array.each { |line|
      if array_of_stacks_within_rows.flatten.include?(iterator)
        line.row_span = 1
        line.additional_for_row_span = "</TR><TR>"
      else
        line.row_span = 2 # TODO: this is specific case. What about: array_of_stacks_within_rows.flatten.uniq.size
      end
      iterator += 1
    }
  end

  def sort_lines_into_row_arrays # sort lines into table_matrix
    table_matrix = []
    if complete?
      temp_row_array = []
      current_row = 0
      iterator = 0 # for each column_begin below will need to add the item_lines array truncated to the iterator.
      item_lines.each { |line|
        current_line = Line.new(line, current_row)
        if current_line.item_end? # if this is the last line in the item
          array_of_stacks_within_rows = check_for_row_spans(temp_row_array)
          if array_of_stacks_within_rows.size > 0
            act_on_row_spans(temp_row_array, array_of_stacks_within_rows)
          end
          table_matrix << temp_row_array # add the last row to the table_matrix (not including divider.)
        elsif current_line.type?(:name)
          @item_name = current_line #might be better to make this the text rather than object
        elsif current_line.style?
          @item_style = get_style(current_line) #@item_style = current_line.line.delete('{}').gsub("-", "_").gsub(/\s.*/, "").to_sym
        elsif current_line.column_begin(table_matrix, temp_row_array).eql?(0) # if this is the first cell in a new row
          array_of_stacks_within_rows = check_for_row_spans(temp_row_array)
          if array_of_stacks_within_rows.size > 0 then act_on_row_spans(temp_row_array, array_of_stacks_within_rows) end
          table_matrix << temp_row_array # put previous row into table_matrix
          temp_row_array = [] # wipe old row array
          current_row += 1
          temp_row_array.insert(current_line.column_begin(table_matrix, temp_row_array), current_line) # insert cell text at column_begin position in array.
        else # if this is neither last line in item, nor new row
          temp_row_array.insert(current_line.column_begin(table_matrix, temp_row_array), current_line) # insert cell text at column_begin position in array. #TODO: is column_begin right here?
        end #row is dealt with because the array _is_ the row. # think about the 0th item? # if skip a position, it is filled with 'nil'. that means I can use that to fill (either from top or from l-side? but how to tell diff?) with multi-span rows/columns. # Think multi-row-spans will not be registered in this way. May not be registered at all as really they are 'within' the overarching initial row. (And I'm not planning to support more creative tables yet) # do something about length for merged cells. (e.g. special characters to mean 'inherits from cell above', or 'inherits from cell to left')
        iterator += 1
      }
      table_matrix # need to bring in column-spanning cells that are not just table-spanning
    end
  end

  def max_columns(table_matrix)
    max_columns = 1
    table_matrix.each { |row|
      array_of_stacks_within_rows = check_for_row_spans(row)
      real_row_size =
        if array_of_stacks_within_rows.size > 0
          recalculate_row_size(array_of_stacks_within_rows, row.size)
        else
          row.size
        end
      max_columns = real_row_size > max_columns ? real_row_size : max_columns
    }
    max_columns
  end

  def recalculate_row_size(array_of_stacks_within_rows, row_size)
    row_size - array_of_stacks_within_rows.flatten.uniq.size + 1
  end

  def get_style(current_line)
    current_line.line.delete('{}').gsub("-", "_").gsub(/\s.*/, "").to_sym
  end
end

## METHODS

def html(item, component, cell = nil)
  case component
  when :table_opener then "[label=<<TABLE ALIGN=\"LEFT\" BORDER=\"#{TABLE_BORDER_THICKNESS}\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\" STYLE=\"ROUNDED\" COLOR=\"#{item.color}\">"
  when :table_new_cell then "<TD COLSPAN=\"#{cell.col_span}\" ROWSPAN=\"#{cell.row_span}\" #{cell.highlight? ? "BGCOLOR=\"#{item.color}\"><FONT COLOR=\"WHITE\"><B>" : ">"}#{add_line_breaks(cell.text, cell.col_span_thingy(item.table_line_length_per_column))}#{cell.highlight? ? "</B></FONT>" : ""}</TD>"
  when :table_open_row then "<TR>"
  when :table_close_row then "</TR>"
  when :table_closer then "</TABLE>>, shape = #{item.shape}]"
  end
end

def tidy_up!(label)
  label.gsub!(/\s+/, " ") # tidy up: condense multiple spaces
  #label.gsub!(" \\n ", "\\n") # tidy up: condense multiple spaces
  label.gsub!(" <BR/> ", "<BR/>") # tidy up: condense multiple spaces
  label.gsub!("' s ", "'s ") # tidy up: rejoin posessives
  label.gsub!(/(\w\-)\s(\w)/, '\1\2') # tidy up: hyphens
  label.gsub!(/(\w)\s\'\s(\w)/, '\1 \'\2') # tidy up: opening quotation marks
  label.gsub!(/<(\/?)\s(\w+)>/, '<\1\2>') # Avoid spaces in e.g. <I>, <B>, <FONT> and </I>, </B>, </FONT>
  label.gsub!("< BR/>", "<BR/>") # Quickfix: more weird spaces
  label.gsub!("</<BR/>I>", "</I><BR/>") # Quickfix: more annoying things
  label.gsub!("</<BR/>B>", "</B><BR/>") # Quickfix: more annoying things
  label.gsub!("<<BR/>", "<BR/><") # Quickfix: angle-bracket clash
end

@target_arr = ""

def trash_intermediary_files(extension_array)
  extension_array.each { |ext|
    Dir.glob("#{@target_arr[0]}/*#{ext}").each { |file| `trash '#{file}'` }
  }
end

def process_file_name(original_extension, suffix = "")
 source_file = ""
 if File.exist?(ARGV[0])
  source_file = File.new(ARGV[0], "r") # variable with file in it.
  @target_arr = File.split(source_file).insert(1, "/") # target_arr is ["filepath" "/" "filename.ext"]
  @target_arr[2].sub!("#{original_extension}", "#{suffix}") # target_arr is now ["filepath" "/" "filename"]
 else
  puts("#{ARGV[0]} does not exist. Check and try again.")
  exit
 end
 source_file
end

=begin
 Explain REGEX below
 \W? = maybe a non-word letter.
 [a-zA-Z0-9_\<\>\/]+ = one or more alphanumeric-or-underscore/anglebracket/forwardslash characters.
 \W = one non-word letter. NOTE THIS MEANS THE array includes spaces and punctuation.
 [^\s\w\(] = zero or more characters which are not spaces/letters/opening-bracket. This is to capture words followed by several non-word chars (e.g. full-stop then close quotation mark), without capturing the opening bracket of a following word.
 NB: The following exceptions are not captured: (1) one-word labels (2) the last word of a label which ends without fullstop/bracket etc.
=end

def add_line_breaks(label, line_length) # move a version of this into the table object. then use the table number of columns method to change the line length (and other shortcuts?)
  number_of_letters = label.scan(/[a-zA-Z0-9_\<\>\/\s\(\)]/).size
  $desired_number_of_lines = (number_of_letters/line_length + 1) # For fewer than LINE_LENGTH letters, produce one line, etc.
  @label_words_array = label.scan(/\W?[a-zA-Z0-9_\<\>\/]+\W[^\s\w\(]*/) # array of the label's words.
  if label.match?(/\w$/) # Deal with above exceptions: if last char in label is a letter, add it to @label_words_array
    @label_words_array << label.scan(/\w+/).last
  end
  $current_word = 0
  $current_number_of_lines = 1
  $reset = false
  while $current_number_of_lines < $desired_number_of_lines do
    $current_line_length = 0
    while $current_line_length < line_length do
      if @label_words_array[$current_word]
        if @label_words_array[$current_word].include?("<BR/>") # if this is already formatted (e.g. if title)
          $current_line_length = line_length
          number_of_letters_left = @label_words_array[$current_word..-1].join.size
          $desired_number_of_lines = (number_of_letters_left/line_length + 1) + $current_number_of_lines + 1
          $reset = true
        else
          $current_line_length += @label_words_array[$current_word].size
        end
        $current_word += 1
      else
        $current_line_length = line_length # this is a bit dodgy.
      end
    end
    unless $reset
      @label_words_array = @label_words_array.insert($current_word, "<BR/>")
      $current_word += 1
    end
    $reset = false
    $current_number_of_lines += 1
  end
  label = @label_words_array * " " # Do I need this? already have spaces in @label_words_array, and in next line I delete double-spaces...
  tidy_up!(label)
  label
end

def add_edge_formatting!(line) # {{key}}
  FlowchartKeywords::EDGE_KEYS.select { |key| line.match("\{\{#{key}\}\}") }.each {|key, value|
    line.sub!("\{\{#{key}\}\}", "[color = #{value.fetch(:color, "blue4")}, style = #{value.fetch(:style, "solid")}]")
  }
end

def add_node_formatting!(line) # {{key}}
  FlowchartKeywords::NODE_KEYS.select { |key| line.match("\{\{#{key}\}\}") }.each {|key, value|
    line.sub!("\{\{#{key}\}\}", ", color = #{value.fetch(:color, "blue4")}, shape = #{value.fetch(:shape, "rectangle, style = rounded, penwidth = 3")}, style = #{value.fetch(:borderstyle, "solid")}")
  }
end

def do_titles!(original_lines) # this is at the end because otherwise rogue linebreaks might break it up. (maybe no more needed)
  original_lines.each { |line| line.gsub(/<(\/?)FOREIGN>/, "<\\1I>").gsub("<TITLE>", "<B>").gsub("</TITLE>", "</B><BR/><BR/>") }
end

def section(passed_nodes, passed_edges)
  if passed_nodes
    passed_edges ? :postnode : :node
  else
    :prenode
  end
end

def ignore_line(line, new_item)
  comment = line.match(/^\#[\s\#]/) ? true : false # is this a comment?
  double_blank_line = new_item && line.strip.eql?("") # is this the second of two blank lines?
  comment | double_blank_line # returns true if line is commented out or the second of two blank lines.
end

def sort_lines_into_items(original_lines)
  new_item = false
  passed_nodes = false
  passed_edges = false
  original_lines.each { |line|
    if line.include?(MARKERS[:end_node]) then passed_edges = true end
    unless ignore_line(line, new_item)
      case section(passed_nodes, passed_edges)
      when :node
        if new_item then @current_item = Item.new(line) end
        if @current_item then @current_item.add_line_to_item(line) end
        new_item = line.strip.eql?("") ? true : false #.item_end? ? true : false #
      else
        $overall_text[section(passed_nodes, passed_edges)] << line
      end
    end
    if line.include?(MARKERS[:start_node]) then passed_nodes = true end
  }
  verbose("Recorded #{Item.all_items.size} items")
  Item.all_items
end

def process_items(raw_items) # processes lines into items
  processed_lines = []
  raw_items.each { |item|
    matrix = item.sort_lines_into_row_arrays
    max_columns = item.max_columns(matrix)
    item.table_line_length_per_column = calc_table_line_length_per_column(max_columns)
    item.color = FlowchartKeywords::NODE_KEYS[item.item_style].fetch(:color, "blue4")
    item.shape = FlowchartKeywords::NODE_KEYS[item.item_style].fetch(:shape, "plaintext")
    processed_lines << "\n" + item.name_text.delete_prefix("#")
    if item.shape.eql?("plaintext")
      processed_lines << html(item, :table_opener)
      processed_lines << html(item, :table_open_row)
      matrix.each { |row|
        if row.size.eql?(0) then next end
        line_iterator = 0
        additional_for_row_span = ""
        array_of_stacks_within_rows = item.check_for_row_spans(row)
        real_row_size = ""
        if array_of_stacks_within_rows.size > 0
          real_row_size = item.recalculate_row_size(array_of_stacks_within_rows, row.size)
        else
          real_row_size = row.size
        end
        row.each { |line|
          cell = Cell.new(line)
          cell.col_span = max_columns/real_row_size # (max_columns * each number of columns)/ real_row_size
          cell.row_span = line.row_span
          cell.additional_for_row_span = line.additional_for_row_span
          if additional_for_row_span then processed_lines << additional_for_row_span end # purposefully this way round so the first sub-row doesn't get a </TR><TR>
          if cell.additional_for_row_span then additional_for_row_span = cell.additional_for_row_span end
          processed_lines << html(item, :table_new_cell, cell)
          line_iterator += 1
        }
        processed_lines << html(item, :table_close_row) + html(item, :table_open_row)
      }
      processed_lines.delete_at(-1)
      processed_lines = processed_lines + [html(item, :table_close_row), html(item, :table_closer)]
    else
      processed_lines << "[label = <#{add_line_breaks(matrix[1][0].text, table_line_length_per_column*1)}>, color = #{item.color}, shape = #{item.shape}, style = solid]"
    end
  }
  processed_lines
end

def format_node_lines(lines_with_tables_done)
  formatted_lines = []
  lines_with_tables_done.each { |line|
    label_raw = line.match(/label \= \"(.*)\"/) {|match| match[1].to_s } || "" # matches the label string (without quotation marks)
    label_with_breaks = add_line_breaks(label_raw, LINE_LENGTH)
    line.sub!(/label \= \".*\"/, "label = \<#{label_with_breaks}\>")
    add_node_formatting!(line)
    formatted_lines << line
  }
  formatted_lines
end

def write_to_temp_file(formatted_lines)
  File.open(TEMP_FILE, 'w') do |file|
    formatted_lines.each { |line| file.puts(line) }
  end
end

def correct_diacritics(formatted_lines)
  DiacriticCorrection::DIACRITICS.each_pair { |wrong, right|
    formatted_lines.each { |line| line.gsub!(wrong, right) }
  }
end

def convert_GV_to_SVG(filepath, filename) # note: filename should exclude extension
  `dot -Tsvg #{TEMP_FILE} -o #{filepath}#{filename}.svg` # change this. make TEMP_FILE a parameter.
end

def convert_SVG_to_PDF(filepath, filename) # note: filename should exclude extension
  `inkscape -f #{filepath}#{filename}.svg -A #{filepath}#{filename}.pdf --without-gui`
end

def convert_GV_to_PDF(filepath, filename) # note: filename should exclude extension.
  convert_GV_to_SVG(filepath, filename) && convert_SVG_to_PDF(filepath, filename) # Two separate conversion methods because dot doesn't do italics if you convert straight to pdf
end

## MAIN

# read file
@source_file = process_file_name(".gv")
original_lines = []
IO.readlines(@source_file).each { |line| original_lines << line} ## load all lines from the source_file into the original_lines array.

item_arrays = sort_lines_into_items(original_lines)
verbose(:sorted)

processed_lines = process_items(item_arrays)
verbose(:processed)
verbose("#{processed_lines.size}")# verbose("Processing done! #{processed_lines.size} lines")

formatted_lines = format_node_lines(processed_lines)
verbose(:formatted)

correct_diacritics(formatted_lines) && verbose(:diacritics)

$overall_text[:node] = formatted_lines
$overall_text[:postnode] = $overall_text[:postnode].each { |line| add_edge_formatting!(line) }

# writing graph
write_to_temp_file($overall_text[:prenode] + $overall_text[:node] + $overall_text[:postnode]) && verbose("Written to temp file: #{TEMP_FILE}.\nNext step takes a while.")

# tidying up
convert_GV_to_PDF(@target_arr[0..1].join, @target_arr[2]) && verbose("converted #{@target_arr[0..1].join}#{@target_arr[2]}")
trash_intermediary_files(TEMP_FILES) && verbose(:trash)
