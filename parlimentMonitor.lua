--- @type string?, string?, string?
local option, arg1, arg2 = ...


---@param billName string
local function displayBill(billName)
    
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