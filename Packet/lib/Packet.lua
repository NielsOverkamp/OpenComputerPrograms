local WordList = {}

function WordList:new(wordLength)
  local wordList = {
    __n = 0,
    __wordLength = wordLength or 8,
    fields = {}
  }
  setmetatable(wordList, self)
  self.__index = self
  return wordList
end

function WordList:addNumber32Field(lengthInWords, number)
  self.fields[#self.fields + 1] = self.NumberField32:new(lengthInWords, number)
  self.__n = self.__n + field:getWordCount()
end

WordList.NumberField32 = {
  new =
  function (self, lengthInWords, number)
    number = number or 0
    field = {
      lengthInWords = lengthInWords,
      number = number,
    }
    setmetatable(field, self)
    self.__index = self
    return field
  end,

  getWord =
  function (self, index, wordLength)
    return bit32.band(
      bit32.rshift(self.number, index * wordLength),
      bit32.lshift(1, wordLength) - 1)
  end,

  setWord =
  function (self, index, wordLength, value)
    self.number = self.number - self:getWord(index, wordLength)
    self.number = self.number + bit32.lshift(
      bit32.band(value, bit32.lshift(1, wordLength) - 1)),
    index * wordLength
  end,

  getWordCount =
  function (self)
    return self.lengthInWords
  end
}

function WordList:getStringRepresentation()
  local result = ""
  local currentCharInByte = 0
  local byteBitPointer = 0
  for _, field in ipairs(self.fields) do
    for index = 0, (field:getWordCount() - 1) do
      local word = field:getWord(index, self.__wordLength)

      if byteBitPointer >= 8 then
        byteBitPointer = 0
        result = result .. string.char(currentCharInByte)
        currentCharInByte = 0
      end

      if (8 - byteBitPointer ) >= self.__wordLength then
        currentCharInByte = currentCharInByte +
        bit32.lshift(word, byteBitPointer)
        byteBitPointer = byteBitPointer + self.__wordLength
      else
        local wordBitPointer = 0
        currentCharInByte = currentCharInByte + bit32.lshift(
          bit32.band(bit32.rshift(word,wordBitPointer), bit32.lshift(1, 7 - byteBitPointer)), byteBitPointer
        )
        wordBitPointer = wordBitPointer + 8 - byteBitPointer
        byteBitPointer = 0
        result = result .. string.char(currentCharInByte)
        currentCharInByte = 0
        while (wordBitPointer < self.__wordLength) do
          result = result .. string.char(
            bit32.band(bit32.rshift(word,wordBitPointer), bit32.lshift(1, 7))
          )
          wordBitPointer = wordBitPointer + 8
        end
        byteBitPointer = wordBitPointer - self.__wordLength
        wordBitPointer = 0
      end
    end
    result = result .. string.char(currentCharInByte)
  end
  return result
end

function WordList:fillInFromString(wordListString)
  local byteArray = {string.byte(wordListString, 1, #wordListString)}
  local byteArrayPointer = 1
  local byteBitPointer = 0
  for _, field in ipairs(self.fields) do
    for index = 0, (field:getWordCount() - 1) do
      if byteBitPointer >= 8 then
        byteBitPointer = 0
        byteArrayPointer = byteArrayPointer + 1
      end

      if (8 - byteBitPointer) <= self.__wordLength then
        currentCharInByte = currentCharInByte +
        bit32.lshift(word, byteBitPointer)
        byteBitPointer = byteBitPointer + self.__wordLength
      else
        local wordBitPointer = 0
        currentCharInByte = currentCharInByte + bit32.lshift(
          bit32.band(bit32.rshift(word,wordBitPointer), bit32.lshift(1, 7 - byteBitPointer)), byteBitPointer
        )
        wordBitPointer = wordBitPointer + 8 - byteBitPointer
        byteBitPointer = 0
        result = result .. string.char(currentCharInByte)
        currentCharInByte = 0
        while (wordBitPointer < self.__wordLength) do
          result = result .. string.char(
            bit32.band(bit32.rshift(word,wordBitPointer), bit32.lshift(1, 7))
          )
          wordBitPointer = wordBitPointer + 8
        end
        byteBitPointer = wordBitPointer - self.__wordLength
        wordBitPointer = 0
      end
    end
    result = result .. string.char(currentCharInByte)
  end
  return result

















  byteArray = {string.byte(wordListString, 1, #wordListString)}
  fieldBitPointer = 0
  fieldPointer = 1
  for _, byte in ipairs(byteArray) do
    for byteBitPointer = 0, 7 do
      self.field[fieldPointer]:setBitAt(i, )

      for _, field in ipairs(self.fields) do
        for i = 0, (field:getWordCount()-1) do
          field:setBitAt(i, bit32.rshift(byteArray[charPointer], bitPointer))
          bitPointer = bitPointer + 1
          if bitPointer >= 8 then
            bitPointer = 0
            charPointer = charPointer + 1
            if (charPointer > #byteArray) then
              return
            end
          end
        end
      end
    end
  end
end

return WordList
