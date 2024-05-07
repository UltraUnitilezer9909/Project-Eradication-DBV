# How to use:

# arckyTextWrapping(bitmap, text, x, y, lineHeight, textPos, textWidths, base, shadow, lineCount = 0, noOutLine = false)
# Possible arguments:

#  - bitmap: the sprite you want to draw the text on (since you named it overlay, you just put overlay as the argument)
#  - text: the text you want to draw.
#  - x: the X position
#  - y: the Y position
#  - lineHeight: the height of each line (make the number smaller to have each line closer to the one above and below)
#  - textPos: 0 is left alligned, 1 is centered and 2 is right alligned.
#  - textWidths: is an array with each width 1 line can have at max, if you want all the same for all lines only put [[200, 1]] as the       argument. (yes in double array)
#  - base: the base color for the text.
#  - shadow: the shadow color for the text:
#  - lineCount (optional): to count the total lines the text will take.
#  - noOutLine (optional): only set to true if you want shadow instead of outline.
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