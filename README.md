# Notifications.lua

__Get the notifications module__

```lua
local notifications = loadstring("https://raw.githubusercontent.com/AbstractPoo/Main/main/Notifications.lua")
```

__Create a notification__

```lua
notifications:notify{
    Title = "Title", 
    Description = "Description",
    Icon = 6031071053, -- icon id (string or number)
    Accept = { -- settings for accept button
        Text = "Yes",
        Callback = function()
            print("Accepted")
        end
    },
    Dismiss = { --settings for dismiss button
        Text = "No",
        Callback = function()
            print("Dismissed")
        end
    },
    Length = 3 -- duration of notification
}
```