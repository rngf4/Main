local freeBuyToggle = false

local gameMT = getrawmetatable(game)
setreadonly(gameMT, false)
local oldNamecall = gameMT.__namecall
gameMT.__namecall = function(self, ...)
    local args = {...}
    if self.Name == "BuyUnlockEventFunction" and freeBuyToggle then
        args[3] = 0
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end

local oldIndex = gameMT.__index
gameMT.__index = function(self, key)
    if tostring(self) == "Money" and freeBuyToggle then
        print(self, key)
        return 9e9
    end
    return oldIndex(self, key)
end

setreadonly(gameMT, true)

local Library = loadstring(game:HttpGet(("https://raw.githubusercontent.com/AbstractPoo/Main/main/Lib.lua"),true))()

local UI = Library:Create{Title = "Sled Simulator"}

local Main = UI:Tab{Name = "Main"}
UI:Settings{
	Name = "UI"
}

Main:Label{
    Text = "Mini Gui for Sled Simulator by Abstract#8007\nInsert to toggle"
}

local codes = {"MollysBowl", "HaraldsGift", "Loading", "50kvisits", "shutdown", "10kvisits"}

Main:Button{
    Name = "Redeem codes (as of 20/05/21)",
    Callback = function()
        table.foreach(codes, function(_, code)
            game:GetService("ReplicatedStorage").SledReplicatedStorage.Events.RedeemCodeEventFunction:InvokeServer(code)
        end)
    end
}

Main:Toggle{
    Name = "Shop is free",
    Callback = function(state)
        freeBuyToggle = state
    end
}
