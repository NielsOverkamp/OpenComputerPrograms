local modem = require("component").modem
local event = require("event")
--require ( "mobdebug" ).start()



local function towords(numbers)
    local wordlength = 8 -- So a byte
    local r = {}
    local word_1s = 0xff
    local signword_1s = 0x7f
    local esc_byte = 0
    local sep_byte = 1
    local sign_bit, word
    for _, number in ipairs(numbers) do
        sign_bit = bit32.rshift(number, 31)
        if bit32.btest(sign_bit) then
            number = -number
        end
        word = bit32.bor(bit32.lshift(bit32.band(number, signword_1s), 1), sign_bit)
        if word == esc_byte then
            table.insert(r, word)
        end
        table.insert(r, word)
        number = bit32.rshift(number, wordlength - 1)
        while number ~= 0 do
            word = bit32.band(number, word_1s)
            if word == esc_byte then
                table.insert(r, word)
            end
            table.insert(r, word)
            number = bit32.rshift(number, wordlength)
        end
        table.insert(r, esc_byte)
        table.insert(r, sep_byte)
    end
    return r
end

local function fromwords(words)
    local wordlength = 8
    local byte_i = 0
    local number = 0
    local sign_bit
    local r = {}
    local signword_1s = 0xfe
    local esc_byte = 0
    local sep_byte = 1
    local skip = false
    for i, word in ipairs(words) do
        if (not skip) and (word == esc_byte) and (words[i + 1] == sep_byte) then
            if bit32.btest(sign_bit) then
                number = -number
            end
            table.insert(r, number)
            if i >= #words then
                break
            end
            sign_bit = nil
            skip = true
        elseif not skip then
            if word == esc_byte then
                skip = true
            end
            if sign_bit == nil then
                sign_bit = bit32.band(word, 1)
                number = bit32.rshift(bit32.band(word, signword_1s), 1)
                byte_i = wordlength - 1
            else
                number = bit32.bor(bit32.lshift(word, byte_i), number)
                byte_i = byte_i + wordlength
            end
        else
            skip = false
        end
    end
    return r
end

local com = {}

com.port = 1

function com.send(vein)
    local message = ""
    for _, coord in ipairs(vein) do
        local words = towords(coord)
        for _, word in ipairs(words) do
            message = message .. string.char(word)
        end
    end
    while true do
        modem.broadcast(com.port, message)
        local _, _, _, _, _, answer = event.pull(1, "modem_message")
        if answer == "ACK" then
            break
        end
    end
end

function com.receive()
    modem.open(com.port)
    local _, _, _, _, _, message = event.pull("modem_message")
    modem.broadcast(com.port, "ACK")
    local words = {}
    for i = 1, #message do
        table.insert(words, string.byte(message:sub(i, i)))
    end
    local vein = {}
    local coord = {}
    for _, number in ipairs(fromwords(words)) do
        table.insert(coord, number)
        if #coord >= 3 then
            table.insert(vein, coord)
            coord = {}
        end
    end
    return vein
end

return com