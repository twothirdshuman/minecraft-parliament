local function urlEncode(str)
    local encode = string.gsub(str, " ", "%%20")
    return encode
end

local function toWin1252(input)
    -- Replace UTF-8 section sign (C2 A7) with Windows-1252 section sign (A7)
    return input:gsub("\194\167", "\167")  -- 194 = 0xC2, 167 = 0xA7
end


local function getBillText(billName) 
    ---@diagnostic disable-next-line: undefined-global
    local url = "https://raw.githubusercontent.com/twothirdshuman/minecraft-parliament/refs/heads/main/"..urlEncode(billName)..".txt"
    ---@diagnostic disable-next-line: undefined-global, unbalanced-assignments
    local res, reason, errRes = http.get(url)
    if res == nil then
        print("url: "..url)
        if errRes == nil then
            error("could not get bill no http response: "..reason)
        end
        error("could not get bill got code: "..tostring(errRes.getResponseCode()))
    end
    --- @type string
    local billText = toWin1252(res.readAll())

    return billText
end

---@param text string
local function printText(text) 
    ---@diagnostic disable-next-line: undefined-global
    local printer = peripheral.find("printer")

    local lines = require "cc.strings".wrap(text, 25)
    local lineIndex = 1
    while true do
        -- Start a new page, or print an error.
        if not printer.newPage() then
            error("Cannot start a new page. Do you have ink and paper?")
        end

        ---@type number, number
        ---@diagnostic disable-next-line: unbalanced-assignments
        local _, height = printer.getPageSize()
        for _=1,height do
            printer.write(lines[lineIndex])
            ---@type number, number
            ---@diagnostic disable-next-line: unbalanced-assignments
            local _, y = printer.getCursorPos()
            printer.setCursorPos(1, y + 1)
            lineIndex = lineIndex + 1
            if lineIndex > #lines then
                return
            end
        end

        sleep(0.5)

        -- And finally print the page!
        if not printer.endPage() then
            error("Cannot end the page. Is there enough space?")
        end
    end
end

local name = ...
printText(getBillText(name))