def arckyTextWrapping(bitmap, text, x, y, lineHeight, textPos, textWidths, base, shadow, lineCount = 0, noOutLine = false)
    bitmap.clear
    textWidth = 0
    array = []
    words = text.split(' ')
    words.each do |word|
      array << bitmap.text_size(word).width
    end
    currSum = 0
    newLineIndex = []
    space = bitmap.text_size(' ').width
    array.each_with_index do |width, index|
      textWidths.each do |linewidth, line|
        if textWidth != linewidth && lineCount == line
          textWidth = linewidth
          break
        end
      end 
      currSum += (width + space)
      if currSum > textWidth
        newLineIndex << index - 1
        currSum = (width + space)
        lineCount += 1
      end
    end
    lines = []
    startIndex = 0
    newLineIndex.each do |index|
      lines << words[startIndex..index].join(' ')
      startIndex = index + 1
    end
    lines << words[startIndex..].join(' ')
    lines.each_with_index do |line, i|
      pbDrawTextPositions(bitmap, [[line, x, y + (lineHeight * i), textPos, base, shadow, noOutLine]])
    end 
    return lineCount
  end 