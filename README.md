# Notifications.lua

__Get the notifications module__

```lua
local notifications = loadstring("https://raw.githubusercontent.com/AbstractPoo/Main/main/Notifications.lua")
```

__Create a notification__

|Option|Type|Description|
|-|-|-|
|Title|String|Title of the notification|
|Description|String|Description of the notification|
|Icon|String/Integer|Icon of the notification|
|Accept.Text|String|Text of the accept button|
|Accept.Callback|Function|Callback function for when the button is clicked|
|Dismiss.Text|String|Text of the dismiss button|
|Dismiss.Callback|Function|Callback function for when the button is clicked|
|Length|Integer|Duration of the notification|

```lua
notifications:notify{
    Title = "Title", 
    Description = "Description",
    Icon = 6031071053, -- icon id (string or integer)
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
> Please note that none of these kwargs are required
