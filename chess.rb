class Board
  attr_reader :board

  def initialize(to_populate = true)
    @board = make_board
    populate_board if to_populate
  end

  def make_board  #currently makes a blank board of nils
    Array.new(8) {Array.new(8)}
  end

  def deep_dup # => INCOMPLETE
    [].tap do |new_array|
      self.board.each do |element|
        new_array << (element.is_a?(Array) ? element.deep_dup : element)
      end
    end
  end

  def [](row, col)  # => getter
    @board[row][col]
  end

  def []=(row, col) # => setter
    [row][col] = @board[row][col]
  end

  def populate_board
    @board[0][0] = Rook.new(self, [0,0], "black")
    @board[0][7] = Rook.new(self, [0,7], "black")
    @board[7][0] = Rook.new(self, [7,0], "white")
    @board[7][7] = Rook.new(self, [7,7], "white")

    @board[0][1] = Knight.new(self, [0,1], "black")
    @board[0][6] = Knight.new(self, [0,6], "black")
    @board[7][1] = Knight.new(self, [7,1], "white")
    @board[7][6] = Knight.new(self, [7,6], "white")

    @board[0][2] = Bishop.new(self, [0,2], "black")
    @board[0][5] = Bishop.new(self, [0,5], "black")
    @board[7][2] = Bishop.new(self, [7,2], "white")
    @board[7][5] = Bishop.new(self, [7,5], "white")

    @board[0][3] = Queen.new(self, [0,3], "black")
    @board[7][3] = Queen.new(self, [7,3], "white")

    @board[0][4] = King.new(self, [0,4], "black")
    @board[7][4] = King.new(self, [7,4], "white")

    row = 1
    8.times{ |col| @board[row][col] = Pawn.new(self, [row,col], "black") }
    row = 6
    8.times{ |col| @board[row][col] = Pawn.new(self, [row,col], "white") }
  end

  def move
    print "enter row from: "
    row_f = gets.chomp.to_i
    return "that is not a valid row" if row_f < 0 || row_f > 7
    print "enter col from: "
    col_f = gets.chomp.to_i
    return "that is not a valid column" if col_f < 0 || col_f > 7

    if self[row_f, col_f].nil?
      return "there's no piece there"
    elsif self[row_f, col_f].possible_moves.empty?
      return "there are no possible moves for that piece"
    else
      puts "you chose a #{self[row_f, col_f].class}"
      puts "your possible moves:"
      p self[row_f, col_f].possible_moves
    end

    print "enter row to: "
    row_t = gets.chomp.to_i
    print "enter col to: "
    col_t = gets.chomp.to_i

    if self[row_f, col_f].possible_moves.include?([row_t, col_t])
      piece = @board[row_f][col_f]
      piece.update_position([row_t, col_t])

      @board[row_t][col_t] = piece
      @board[row_f][col_f] = nil
      piece.update_board(self)
      self.display
    else
      return "you can't move there"
    end
  end

  def display
    # display_board = dup
    display_board = make_board  # => display_board is just a blank board

    # => the following loops just set our blank board to match master board
    @board.each_with_index do |row, r_idx|    #referring to original board
      row.each_with_index do |tile, c_idx|
        if @board[r_idx][c_idx].is_a?(Piece)
          display_board[r_idx][c_idx] = tile.symbol
        elsif @board[r_idx][c_idx].nil?
          display_board[r_idx][c_idx] = "__"
        end
      end
    end

    print "\n\n\t"+['0 ','1 ','2 ','3 ','4 ','5 ','6 ','7 '].join('   ')+"\n\n"
    display_board.each_with_index do |row, idx|
      print "\n"
      print idx.to_s + "\t"
      puts row.join('   ')
    end
    puts "\n\n"
    nil
  end

  def pieces(color)
    answer = []
    (0..7).each do |num|
      answer += self.board[num]
    end
    answer.compact.select{ |piece| piece.color == color }
  end

  def find_king(color)  #returns coordinates of KING
    pieces(color).select{ |piece| piece.is_a?(King)}[0].position
  end

  def all_moves(color)
    moves = []
    pieces(color).each do |piece|
      moves << piece.possible_moves
    end
    moves
    flattened = []
    moves.each do |move|
      flattened += move
    end
    flattened
  end

  def in_check?(king_color)
    enemy_color = king_color == "white" ? "black" : "white"
    king_location = find_king(king_color)
    all_moves(enemy_color).include?(king_location)
  end

  def checkmate?(color) #???
  end

end

class Piece
  attr_reader :position, :ref_board, :symbol, :color

  def initialize(ref_board, position, color)
    @position = position
    @ref_board = ref_board
    @color = color
  end

  def update_position(new_position)
    @position = new_position
  end

  def update_board(current_board)
    @ref_board = current_board
  end

  def move_into_check?(position) #INCOMPLETE; filters out moves that lead to check
    duped_board = @ref_board.deep_dup
    duped_board.move #then preform the move
    #look to see if the player is in check after move (Board.in_check?)
  end

end

class SlidingPiece < Piece
  LINES = [ [0,1], [1,0], [0, -1], [-1, 0] ]
  DIAGONALS = [ [1, 1], [-1, -1], [1, -1], [-1, 1] ]

end

class SteppingPiece < Piece
  KNIGHT_MOVES = [
    [-1, 2], [1, -2], [-1, -2], [1, 2],
    [-2, 1], [2, -1], [-2, -1], [2, 1]
  ]

  KING_MOVES = [
    [0, 1], [1, 0], [0, -1], [-1, 0],
    [1, 1], [-1, -1], [1, -1], [-1, 1]
  ]

end

class King < SteppingPiece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "Ki"
  end

  # def possible_moves(current_position)

  def possible_moves  # => removed argument for simplicity
    KING_MOVES.map do |coord|
      # [coord[0] + current_position[0], coord[1] + current_position[1]]
      [coord[0] + self.position[0], coord[1] + self.position[1]]
    end.select do |x, y|
      [x, y].all? do |coord|
        coord.between?(0, 7)
      end
    end.select do |x, y|
      ( self.ref_board[x, y].nil? ) || ( self.ref_board[x,y].color != self.color )
    end

  end

end

class Knight < SteppingPiece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "Kn"
  end

  def possible_moves
    KNIGHT_MOVES.map do |coord|
      [coord[0] + self.position[0], coord[1] + self.position[1]]
    end.select do |x, y|
      [x, y].all? do |coord|
        coord.between?(0, 7)
      end
    end.select do |x, y|
      ( self.ref_board[x, y].nil? ) || ( self.ref_board[x,y].color != self.color )
    end
  end
end

class Queen < SlidingPiece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "Q "
  end

  def possible_moves

    answer = Array.new(8) { [] }

    (1..7).each do |multiplier|
      (LINES + DIAGONALS).each_with_index do |coord, index|
        x_coord = coord[0] * multiplier + self.position[0]
        y_coord = coord[1] * multiplier + self.position[1]
        answer[index] << [x_coord, y_coord]
      end
    end

    f1_moves = []
    (0..7).each do |ans_idx|
      f1_moves << answer[ans_idx].select do |x, y|
        [x, y].all? do |coord|
          coord.between?(0, 7)
        end
      end
    end

    f2_moves = []

    f1_moves.each do |series|
      series.each do |x, y|
        if self.ref_board[x, y].nil?
          f2_moves << [x,y]
        elsif self.ref_board[x, y].color != self.color
          f2_moves << [x,y]
          break
        else
          break
        end
      end
    end

    f2_moves
  end
end

class Bishop < SlidingPiece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "B "
  end

  def possible_moves

    answer = Array.new(8) { [] }

    (1..7).each do |multiplier|
      (DIAGONALS).each_with_index do |coord, index|
        x_coord = coord[0] * multiplier + self.position[0]
        y_coord = coord[1] * multiplier + self.position[1]
        answer[index] << [x_coord, y_coord]
      end
    end

    f1_moves = []
    (0..7).each do |ans_idx|
      f1_moves << answer[ans_idx].select do |x, y|
        [x, y].all? do |coord|
          coord.between?(0, 7)
        end
      end
    end

    f2_moves = []

    f1_moves.each do |series|
      series.each do |x, y|
        if self.ref_board[x, y].nil?
          f2_moves << [x,y]
        elsif self.ref_board[x, y].color != self.color
          f2_moves << [x,y]
          break
        else
          break
        end
      end
    end

    f2_moves
  end

end

class Rook < SlidingPiece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "R "
  end

  def possible_moves

    answer = Array.new(8) { [] }

    (1..7).each do |multiplier|
      (LINES).each_with_index do |coord, index|
        x_coord = coord[0] * multiplier + self.position[0]
        y_coord = coord[1] * multiplier + self.position[1]
        answer[index] << [x_coord, y_coord]
      end
    end

    f1_moves = []
    (0..7).each do |ans_idx|
      f1_moves << answer[ans_idx].select do |x, y|
        [x, y].all? do |coord|
          coord.between?(0, 7)
        end
      end
    end

    f2_moves = []

    f1_moves.each do |series|
      series.each do |x, y|
        if self.ref_board[x, y].nil?
          f2_moves << [x,y]
        elsif self.ref_board[x, y].color != self.color
          f2_moves << [x,y]
          break
        else
          break
        end
      end
    end

    f2_moves
  end

end

class Pawn < Piece

  def initialize(ref_board, position, color)
    super(ref_board, position, color)
    @symbol = "P "
  end

  def possible_moves
    move_array = []
    x, y = self.position[0], self.position[1]
    if self.color == 'white'
      unless self.ref_board[x - 1, y - 1].nil?
        if self.ref_board[x - 1, y - 1].color == 'black'
          move_array << [x - 1, y - 1]
        end
      end
      unless self.ref_board[x - 1, y + 1].nil?
        if self.ref_board[x - 1, y + 1].color == 'black'
          move_array << [x - 1, y + 1]
        end
      end

      if self.ref_board[x - 1, y].nil?
        move_array << [x - 1, y]
        if x == 6 && self.ref_board[x - 2, y].nil?
          move_array << [x - 2, y]
        end
      end
      #ALL WHITE OPTIONS

    else
      unless self.ref_board[x + 1, y + 1].nil?
        if self.ref_board[x + 1, y + 1].color == 'white'
          move_array << [x + 1, y + 1]
        end
      end
      unless self.ref_board[x + 1, y - 1].nil?
        if self.ref_board[x + 1, y - 1].color == 'white'
          move_array << [x + 1, y - 1]
        end
      end

      if self.ref_board[x + 1, y].nil?
        move_array << [x + 1, y]
        if x == 1 && self.ref_board[x + 2, y].nil?
          move_array << [x + 2, y]
        end
      end

      #ALL BLACK OPTIONS

    end #ENDS THE IF/ELSE TREE

    move_array.select do |x, y|
      [x, y].all? do |coord|
        coord.between?(0, 7)
      end
    end

  end #ENDS THE DEF POSSIBLE_MOVES METHOD

end