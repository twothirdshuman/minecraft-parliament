
--- @type string?, string?, string?
--- @diagnostic disable-next-line: unbalanced-assignments
local option, arg1, arg2 = ...

---@param str string
---@return string
local function urlEncode(str)
    local encode = string.gsub(str, " ", "%%20")
    return encode
end

---@param billName string
---@return string
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
    local billText = res.readAll()

    return billText
end


---@param monitor unknown
local function scrollIfNeed(monitor)
    --- @type number, number
    --- @diagnostic disable-next-line: unbalanced-assignments
    local _, height = monitor.getSize()

    --- @type number, number
    --- @diagnostic disable-next-line: unbalanced-assignments
    local _, y = monitor.getCursorPos()
    monitor.setCursorPos(1, y + 1)
    --- @diagnostic disable-next-line: unbalanced-assignments
    _, y = monitor.getCursorPos()

    if y > height then
        monitor.scroll(1)
        monitor.setCursorPos(1, y - 1)
    end
end

---@param text string
---@param monitor unknown
local function writeToScreen(text, monitor)
    monitor.setTextScale(1.5)

    --- @type number, number
    --- @diagnostic disable-next-line: unbalanced-assignments
    local width, height = monitor.getSize()

    --- @type string[]
    local words = {}

    for word in string.gmatch(text, "[^ ]+") do
        table.insert(words, word)
    end

    monitor.clear()
    monitor.setCursorPos(1, 1)

    for wordIndex = 1,#words do
        local word = words[wordIndex]
        --- @type number, number
        --- @diagnostic disable-next-line: unbalanced-assignments
        local x, _ = monitor.getCursorPos()

        if (x + #word - 1) > width then
            scrollIfNeed(monitor)
        end

        for i = 1, #word do
            local char = string.sub(word, i, i)
            monitor.write(char)
            if char == "\n" then
                scrollIfNeed(monitor)
            end
        end
        monitor.write(" ")
    end
end

---@param wholeText string
---@param writingFunction fun(text: string): nil
local function scrollControll(wholeText, writingFunction)
    local words = {}

    for word in string.gmatch(wholeText, "[^ ]+") do
        table.insert(words, word)
    end

    local nWords = 10

    while true do
        local toWrite = ""

        ---@diagnostic disable-next-line: undefined-global
        term.clear()
        for i=1,nWords do
            toWrite = toWrite..words[i].." "
        end
        writingFunction(toWrite)
        ---@diagnostic disable-next-line: undefined-global
        write(toWrite.."\nPress space to scroll, q to quit ")

        --- @diagnostic disable-next-line: unbalanced-assignments, undefined-field
        local type, char = os.pullEvent()

        if type == "char" then
            if char == "q" then
                return
            elseif char == " " then
                nWords = nWords + 10
            end
        end
    end
end
---@param billName string
local function displayBill(billName)
    local billText = getBillText(billName)

    ---@diagnostic disable-next-line: undefined-global
    local monitor = peripheral.find("monitor")

    scrollControll(billText, function(text) 
        writeToScreen(text, monitor)
    end)
end

if option == "display" then
    if arg1 == nil then
        error("Please specify a bill to display")
    end
    displayBill(arg1)
elseif option == "vote" then

elseif option == nil then
    print("Uses:")
    print(" - display [billName]")
    print(" - vote [title]")
end