--- @type string?, string?, string?
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

---@param billName string
local function displayBill(billName)
    local billText = getBillText(billName)

    ---@diagnostic disable-next-line: undefined-global
    local monitor = peripheral.find("monitor")[1]

    monitor.write(billText)
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