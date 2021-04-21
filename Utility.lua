local Utility

function Import(importTable)
    table.foreach(importTable, function(funcName, func)
        getfenv().funcName = func
    end)
end

return Utility
