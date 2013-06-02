module TfIdfSimilarity::MatrixMethods
private

  # @return [GSL::Matrix,NArray,NMatrix,Matrix] all document vectors as unit vectors
  #
  # @note Lucene normalizes document length differently.
  def normalize
    case @library
    when :gsl
      @matrix.clone.each_col(&:normalize!)
    when :narray # @see https://github.com/masa16/narray/issues/21
      NArray.refer(@matrix / NMath.sqrt((@matrix ** 2).sum(1).reshape(@matrix.shape[0], 1)))
    when :nmatrix # @see https://github.com/SciRuby/nmatrix/issues/38
      normal = NMatrix.new(:dense, @matrix.shape, :float64)
      (0...@matrix.shape[1]).each do |j|
        column = @matrix.column(j)
        norm = Math.sqrt(column.transpose.dot(column)[0, 0])
        (0...@matrix.shape[0]).each do |i|
          normal[i, j] = @matrix[i, j] / norm
        end
      end
      normal
    else
      Matrix.columns(@matrix.column_vectors.map(&:normalize))
    end
  end

  # @param [Integer] index the row index
  # @return [GSL::Vector::View,NArray,NMatrix,Vector] a row
  def row(index)
    case @library
    when :narray
      @matrix[true, index]
    else
      @matrix.row(index)
    end
  end

  # @param [Integer] index the column index
  # @return [GSL::Vector::View,NArray,NMatrix,Vector] a column
  def column(index)
    case @library
    when :narray
      @matrix[index, true]
    else
      @matrix.column(index)
    end
  end

  # @return [Float] the number of rows in the matrix
  def row_size
    case @library
    when :gsl, :nmatrix
      @matrix.shape[0]
    when :narray
      @matrix.shape[1]
    else
      @matrix.row_size
    end
  end

  # @return [Float] the number of columns in the matrix
  def column_size
    case @library
    when :gsl, :nmatrix
      @matrix.shape[1]
    when :narray
      @matrix.shape[0]
    else
      @matrix.column_size
    end
  end

  # @return [Array<Float>] the matrix's values
  def values
    case @library
    when :nmatrix
      @matrix.each.to_a
    else
      @matrix.to_a.flatten
    end
  end

  # @return [Float] the sum of all values in the matrix
  def sum
    case @library
    when :narray
      @matrix.sum
    else
      values.reduce(0, :+)
    end
  end

  # @param [Array<Array>] array matrix rows
  # @return [GSL::Matrix,NArray,NMatrix,Matrix] a matrix
  def initialize_matrix(array)
    case @library
    when :gsl
      GSL::Matrix[*array]
    when :narray
      NArray[*array]
    when :nmatrix # @see https://github.com/SciRuby/nmatrix/issues/91
      NMatrix.new(:dense, [array.size, array[0].size], array.flatten)
    else
      Matrix[*array]
    end
  end

  # @param [GSL::Matrix,NArray,NMatrix,Matrix] matrix a matrix
  # @return [GSL::Matrix,NArray,NMatrix,Matrix] the product
  def multiply_self(matrix)
    case @library
    when :nmatrix
      matrix.transpose.dot(matrix)
    else
      matrix.transpose * matrix
    end
  end

  def log(number)
    case @library
    when :gsl
      GSL::Sf::log(number)
    when :narray
      NMath.log(number)
    else
      Math.log(number)
    end
  end

  def sqrt(number)
    case @library
    when :narray
      NMath.sqrt(number)
    else
      Math.sqrt(number)
    end
  end
end
