local component = require("component")
local redstone = component.redstone
local sides = require("sides")
local event = require("event")

local reco = {}

function reco:setup(opt)
    opt = opt or {}
    self.data_side = opt.data_side or sides.left
    self.read_period = opt.read_period or 0
    self.red_components = opt.red_component or redstone
    self.sync_side = opt.sync_side or self.data_side
    self.sync_timeout = opt.sync_timeout or -1
    for _, side in ipairs({ 0, 1, 2, 3, 4, 5 }) do
        redstone.setOutput(side, 0)
    end
end

function reco:robot_setup()
    return self:setup({ data_side = sides.left, sync_timeout = -1 })
end

function reco:_send_raw(iter, t, a)
    if not self:sync_sender() then
        return false
    end
    local sync_finished = false
    local CLOCK_VAL = 8
    local SEP_VAL = 4
    local clock_bit = 0
    local sep_bit = 0
    if type(iter) == "table" then
        iter, t, a = ipairs(iter)
    end
    local word, next
    a, next = iter(t, a)
    if next and next > 3 then
        error("Can not have a seperator in the first position")
    end


    while next ~= nil do
        word = next
        a, next = iter(t, a)
        if next == 4 then
            sep_bit = bit32.bxor(sep_bit, SEP_VAL)
            a, next = iter(t, a)
            if next and next > 3 then
                error("Can not have seperator after a seperator ")
            end
        elseif next == 5 then
            redstone.setOutput(self.data_side, bit32.bor(bit32.bor(word, clock_bit), bit32.bxor(sep_bit, SEP_VAL)))
            print(bit32.bor(bit32.bor(word, clock_bit), bit32.bxor(sep_bit, SEP_VAL)))
            redstone.setOutput(self.data_side, 0)
            return true
        end
        clock_bit = bit32.bxor(clock_bit, CLOCK_VAL)
        redstone.setOutput(self.data_side, bit32.bor(bit32.bor(word, clock_bit), sep_bit))
        print(bit32.bor(bit32.bor(word, clock_bit), sep_bit))
        if self.read_period > 0 then
            os.sleep(self.read_period)
        elseif not sync_finished then
            redstone.setOutput(self.data_side, redstone.getInput(self.data_side))
            redstone.setOutput(self.data_side, redstone.getInput(self.data_side)) -- Hack to get the receiver and sender to sync up
            sync_finished = true
        end
    end
end

function reco:_receive_raw()
    if not self:sync_receiver() then
        return false
    end
    local words = {}
    local CLOCK_VAL = 8 -- 1000
    local SEP_VAL = 4 -- 0100
    local WORD_VAL = 3 -- 0011
    local clock_bit = 0
    local sep_bit = 0
    local message
    while true do
        message = redstone.getInput(self.data_side)
        if bit32.band(CLOCK_VAL, message) ~= clock_bit then
            print(message)
            table.insert(words, bit32.band(message, WORD_VAL))
            if bit32.band(SEP_VAL, message) ~= sep_bit then
                table.insert(words, 4)
                sep_bit = bit32.bxor(sep_bit, SEP_VAL)
            end
            clock_bit = bit32.bxor(clock_bit, CLOCK_VAL)
        elseif bit32.band(SEP_VAL, message) ~= sep_bit then
            print(message)
            table.insert(words, bit32.band(message, WORD_VAL))
            table.insert(words, 5)
            return true, words
        else
            event.pull("redstone")
        end
    end
end

function reco:sync_sender()
    os.sleep(0.1) -- clear signal queue
    redstone.setOutput(self.sync_side, 0)
    local timerID
    if self.sync_timeout >= 0 then
        timerID = event.timer(self.sync_timeout, function() event.push("sync_timeout") end)
    end
    if redstone.getInput(self.sync_side) == 0 then
        local name = event.pullFiltered(function(name, _, side, _, v)
            print(name, side, v)
            if name == "sync_timeout" or (name == "redstone_changed" and side == self.sync_side and v == 1) then
                return true
            end
        end)
        if name == "sync_timeout" then
            return false
        end
    end
    if timerID then
        event.cancel(timerID)
    end
    return true
end

function reco:sync_receiver()
    os.sleep(0.1) -- clear signal queue
    redstone.setOutput(self.sync_side, 1)
    local timerID
    if self.sync_timeout >= 0 then
        event.timer(self.sync_timeout, function() event.push("sync_timeout") end)
    end
    if redstone.getInput(self.sync_side) == 1 then
        local name = event.pullFiltered(function(name, _, side, _, v)
            print(name, side, v)
            if name == "sync_timeout" or (name == "redstone_changed" and side == self.sync_side and v > 1) then
                redstone.setOutput(self.sync_side, 0)
                return true
            end
        end)
        if name == "sync_timeout" then
            redstone.setOutput(self.sync_side, 0)
            return false
        end
    end
    if timerID then
        event.cancel(timerID)
    end
    redstone.setOutput(self.sync_side, 0)
    return true
end

--function reco:_send_when_synced_raw(words)
--    if self:sync_sender() then
--        return self:send(words)
--    else
--        return false
--    end
--end

--function reco:_sync_and_receive_raw()
--    if self:sync_receiver() then
--        return self:receive()
--    else
--        return false
--    end
--end

function reco:send(numbers)
    return self:_send_raw(reco.towords(numbers))
end

function reco:receive()
    local ok, words = self:_receive_raw()
    if ok then
        return reco.fromwords(words)
    else
        return ok
    end
end

function reco.towords(numbers)
    local wordlength = 2
    if type(numbers) == "number" then
        numbers = { numbers }
    end
    local r = {}
    local word_1s = 0x3
    local unsigned_1s = 0x80000000
    local sign_bit
    for _, number in ipairs(numbers) do
        sign_bit = bit32.rshift(bit32.band(number, unsigned_1s), 31)
        table.insert(r, sign_bit)
        if bit32.btest(sign_bit) then
            number = -number
        end
        while number ~= 0 do
            table.insert(r, bit32.band(number, word_1s))
            number = bit32.rshift(number, wordlength)
        end
        table.insert(r, 4)
    end
    r[#r] = 5
    return r
end

function reco.fromwords(words)
    local wordlength = 2
    local i = 0
    local number = 0
    local sign_bit
    local r = {}
    for _, word in ipairs(words) do
        if word < 4 then
            if sign_bit == nil then
                sign_bit = word
            else
                number = bit32.bor(bit32.lshift(word, i), number)
                i = i + wordlength
            end
        else
            if bit32.btest(sign_bit) then
                number = -number
            end
            table.insert(r, number)
            if word > 4 then
                break
            end
            i = 0
            number = 0
            sign_bit = nil
        end
    end
    return r
end

reco:setup()

return reco