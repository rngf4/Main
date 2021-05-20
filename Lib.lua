--services and useful shit
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local DefaultColours = {
	Main = Color3.fromRGB(35, 35, 40),
	MainHover = Color3.fromRGB(50, 50, 55),
	Notifications = Color3.fromRGB(40, 45, 50),
	MainText = Color3.fromRGB(255, 255, 255),
	AccentText = Color3.fromRGB(255, 255, 255),
	Icons = Color3.fromRGB(255, 255, 255),
	Function = Color3.fromRGB(45, 45, 50),
	FunctionHover = Color3.fromRGB(55, 55, 60),
	FunctionClick = Color3.fromRGB(60, 60, 65),
	ToggleSliderFalse = Color3.fromRGB(70, 70, 75),
	ToggleSliderTrue = Color3.fromRGB(72, 125, 200),
	ToggleFalse = Color3.fromRGB(75, 75, 80),
	ToggleTrue = Color3.fromRGB(90, 155, 250),
	SliderBar = Color3.fromRGB(70, 70, 75),
	Sliding = Color3.fromRGB(90, 155, 250),
	DropdownMain = Color3.fromRGB(35, 35, 40),
	DropdownOption = Color3.fromRGB(90, 155, 250),
	BindContainer = Color3.fromRGB(70, 70, 75),
	BindText = Color3.fromRGB(255, 255, 255)
}

local Objects = {}

local Colours = setmetatable({},  {
	__newindex = function(_, Key, Value)
		DefaultColours[Key] = Value
        for _, ThemeTable in next, Objects do
			local Theme = ThemeTable[1]
			local Attribute = ThemeTable[2]
			local Object = ThemeTable[3]
			if Theme == Key then
				TS:Create(Object, TweenInfo.new(0.35), {[Attribute] = Value}):Play()
			end
		end
	end,
})

local TS = game:GetService("TweenService")
local function Object(Type, Properties)
	if not Type or not Properties.Parent then print("Usage: Object(Type <String>, Properties <Table>)"); return end
	local LocalObject = Instance.new(Type)
	pcall(function()
		LocalObject.BorderSizePixel = 0
		LocalObject.AutoButtonColor = false
	end)
	local Theme = nil
	if Properties.Theme then
		Theme = Properties.Theme
		LocalObject[Theme[2]] = DefaultColours[Theme[1]]
		table.insert(Theme, LocalObject)
		table.insert(Objects, Theme)
	end
	local Success, Error = pcall(function()
        for Property, Value in next, Properties do
			if Property ~= "Theme" then
				LocalObject[Property] = Value
			end
		end
	end)
	if not Success then warn(Error) end
	local Methods = {}

	function Methods:Object(Type, Properties)
		Properties.Parent = LocalObject
		return Object(Type, Properties)
	end

	function Methods:Round(Radius)
		Radius = Radius or 6
		return Methods:Object("UICorner", {
			CornerRadius = UDim.new(0, Radius)
		})
	end
	
	function Methods:Tween(Data, Info)
		Info = Info or TweenInfo.new(0.25)
		local Tween = TS:Create(LocalObject, Info, Data)	
		Tween:Play()
		return Tween
	end

	return setmetatable(Methods, {
		__index = function(_, Value)
			if Value == "Theme" then return Theme end
			return LocalObject[Value]
		end,
		__call = function()
			return LocalObject
		end,
		__newindex = function(_, Property, Value)
			if Property == "Theme" then
				Theme[1] = Value
				return
			end
			LocalObject[Property] = Value
		end,
	})
end

local Notifications = {}

local function BeingNotified()
	if #Notifications > 0 then
		return true
	end
	return false
end

local Library = {Count = 0, Binding = false}

function Library:Create(LibraryOptions)
	
	LibraryOptions = LibraryOptions or {}
	LibraryOptions.Size = LibraryOptions.Size or UDim2.fromOffset(550, 400)
	LibraryOptions.Title = LibraryOptions.Title or "Abstract UI"
	local DraggingLocked = LibraryOptions.DragLock or LibraryOptions.Lock or false
	local DragSpeed = LibraryOptions.DragSpeed or LibraryOptions.Speed or 0.1
	local UIToggleState = true
	local UIToggleKey = Enum.KeyCode.Insert
	
	local Gui = Object("ScreenGui", {
		Parent = (RS:IsStudio() and game.Players.LocalPlayer.PlayerGui) or game.CoreGui,
		Name = "UILibrary"
	})

	local MainFrame = Gui:Object("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = LibraryOptions.Size,
		ClipsDescendants = true,
		Theme = {"Main", "BackgroundColor3"}
	})
	MainFrame:Round()
	
	do
		local Down = false
		MainFrame.MouseButton1Down:connect(function()
			Down = true
			local Vector = Vector2.new(Mouse.X - MainFrame.AbsolutePosition.X, Mouse.Y - MainFrame.AbsolutePosition.Y)
			while Down and RS.RenderStepped:wait() do
				if DraggingLocked then
					local FrameX, FrameY = math.clamp(Mouse.X - Vector.X, 0, Gui.AbsoluteSize.X - MainFrame.AbsoluteSize.X), math.clamp(Mouse.Y - Vector.Y, 0, Gui.AbsoluteSize.Y - MainFrame.AbsoluteSize.Y)
					MainFrame:Tween({Position = UDim2.fromOffset(FrameX + (MainFrame.Size.X.Offset * MainFrame.AnchorPoint.X), FrameY + (MainFrame.Size.Y.Offset * MainFrame.AnchorPoint.Y))}, TweenInfo.new(DragSpeed))
				else
					MainFrame:Tween({Position = UDim2.fromOffset(Mouse.X - Vector.X + (MainFrame.Size.X.Offset * MainFrame.AnchorPoint.X), Mouse.Y - Vector.Y + (MainFrame.Size.Y.Offset * MainFrame.AnchorPoint.Y))}, TweenInfo.new(DragSpeed))
				end	
			end
		end)
		
		UIS.InputEnded:connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Down = false
			end
		end)
	end
	
	local BlurFrame = MainFrame:Object("Frame", {
		BackgroundColor3 = Color3.fromRGB(),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Size = UDim2.fromScale(1, 1),
		Name = "BlurFrame"
	})
	BlurFrame:Round()
	
	local NotificationsUILayout = BlurFrame:Object("UIListLayout", {
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom
	})
	
	local NotificationsUIPadding = BlurFrame:Object("UIPadding", {
		PaddingBottom = UDim.new(0, 18)
	})
	
	local function Blur(State)
		if State then
			BlurFrame:Tween{BackgroundTransparency = 0.75}
		else
			BlurFrame:Tween{BackgroundTransparency = 1}
		end
	end

	local TopBar = MainFrame:Object("Frame", { -- contains ui name and tab name
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 0, 0, 45)
	})
	
	local Title = TopBar:Object("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromScale(1, 1),
		Theme = {"MainText", "TextColor3"},
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 30,
		Text = LibraryOptions.Title
	})
	
	local BottomBarContainer = MainFrame:Object("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1
	})
	
	local Effect = BottomBarContainer:Object("Frame", {
		Size = UDim2.fromScale(1, 1),
		Theme = {"Main", "BackgroundColor3"},
		ZIndex = 3
	})
	Effect:Round()
	
	local BottomBar = BottomBarContainer:Object("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})
	
	local BottomBarLayout = BottomBar:Object("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left
	})
	
	local BottomBarPadding = BottomBar:Object("UIPadding", {})
	
	local TransparencyGradient = Effect:Object("UIGradient", {
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.075, 0),
			NumberSequenceKeypoint.new(0.3, 1),
			NumberSequenceKeypoint.new(0.7, 1),
			NumberSequenceKeypoint.new(0.925, 0),
			NumberSequenceKeypoint.new(1, 0)
		}
	})

	local LeftBar = MainFrame:Object("TextButton", { -- contains navigate left button
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 50, 1, 0),
		Text = ""
	})
	
	local LeftClickContainer = LeftBar:Object("Frame", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Theme = {"Main", "BackgroundColor3"},
		Visible = false
	})
	LeftClickContainer:Round(100)

	local LeftClickImage = LeftClickContainer:Object("ImageLabel", {
		Image = "http://www.roblox.com/asset/?id=5844057859",
		Rotation = 90,
		Theme = {"Icons", "ImageColor3"},
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	})
	LeftClickImage:Round(100)

	local RightBar = MainFrame:Object("TextButton", { -- contains navigate right button
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 50, 1, 0),
		Text = ""
	})
	
	local RightClickContainer = RightBar:Object("Frame", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Theme = {"Main", "BackgroundColor3"}
	})
	RightClickContainer:Round(100)
	
	local RightClickImage = RightClickContainer:Object("ImageLabel", {
		Image = "http://www.roblox.com/asset/?id=5844057859",
		Rotation = -90,
		Theme = {"Icons", "ImageColor3"},
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})
	RightClickImage:Round(100)
	
	local FunctionsFrameContainer = MainFrame:Object("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, TopBar.AbsoluteSize.Y),
		Size = UDim2.new(1, -100, 1, - TopBar.AbsoluteSize.Y - BottomBar.AbsoluteSize.Y),
		ClipsDescendants = true
	})
	
	local FunctionsFrameContainerUIListLayout = FunctionsFrameContainer:Object("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal
	})
	
	local FunctionsFrameContainerUIPadding = FunctionsFrameContainer:Object("UIPadding", {})
	
	LeftBar.MouseEnter:connect(function()
		if BeingNotified() then return end
		LeftClickContainer:Tween{BackgroundColor3 = DefaultColours.MainHover}
	end)
	
	LeftBar.MouseLeave:connect(function()
		if BeingNotified() then return end
		LeftClickContainer:Tween{BackgroundColor3 = DefaultColours.Main}
	end)
	
	LeftBar.MouseButton1Down:connect(function()
		if BeingNotified() then return end
		LeftClickContainer:Tween({Position = UDim2.new(0.5, -3, 0.5, 0)}, TweenInfo.new(0.1))
	end)
	
	LeftBar.MouseButton1Up:connect(function()
		if BeingNotified() then return end
		LeftClickContainer:Tween({Position = UDim2.new(0.5, 0, 0.5, 0)}, TweenInfo.new(0.1))
	end)
	
	RightBar.MouseEnter:connect(function()
		if BeingNotified() then return end
		RightClickContainer:Tween{BackgroundColor3 = DefaultColours.MainHover}
	end)

	RightBar.MouseLeave:connect(function()
		if BeingNotified() then return end
		RightClickContainer:Tween{BackgroundColor3 = DefaultColours.Main}
	end)
	
	RightBar.MouseButton1Down:connect(function()
		if BeingNotified() then return end
		RightClickContainer:Tween({Position = UDim2.new(0.5, 3, 0.5, 0)}, TweenInfo.new(0.1))
	end)
	
	RightBar.MouseButton1Up:connect(function()
		if BeingNotified() then return end
		RightClickContainer:Tween({Position = UDim2.fromScale(0.5, 0.5)}, TweenInfo.new(0.1))
	end)
	
	local Tabs = {}
	local CurrentTab
	local Count = 0
	local BottomNavObjects = {}

	local function GetBottomX()
		local LocalCount = 0
        for Index, Object in next, BottomNavObjects do
			local LocalObject = Object[1]
			local ObjectCount = Object[2]
			if ObjectCount < Count then
				LocalCount = LocalObject.AbsoluteSize.X + 10
			elseif ObjectCount == Count then
				LocalCount = (LocalObject.AbsoluteSize.X / 2)
                for _, Object in next, BottomNavObjects do
					if Object[1] ~= LocalObject then
						Object[1]:Tween{TextTransparency = 0.4}
					end
				end
				LocalObject:Tween{TextTransparency = 0}
			end
		end
		return LocalCount - 10
	end
	
	LeftBar.MouseButton1Click:connect(function()
		if BeingNotified() then return end
		if Count ~= 0 then
			Count = Count - 1
			if Count == 0 then
				LeftClickContainer.Visible = false
				RightClickContainer.Visible = true
			else
				LeftClickContainer.Visible = true
				RightClickContainer.Visible = true
			end			
			FunctionsFrameContainerUIPadding:Tween{PaddingLeft = UDim.new(-Count, 0)}
		end
		BottomBarPadding:Tween{PaddingLeft = UDim.new(0, (BottomBarContainer.AbsoluteSize.X / 2) - GetBottomX())}
	end)
	
	RightBar.MouseButton1Click:connect(function()
		if BeingNotified() then return end
		if Count ~= #Tabs - 1 then
			Count = Count + 1
			if Count == #Tabs - 1 then
				RightClickContainer.Visible = false
				LeftClickContainer.Visible = true
			else
				RightClickContainer.Visible = true
				LeftClickContainer.Visible = true
			end	
			FunctionsFrameContainerUIPadding:Tween{PaddingLeft = UDim.new(-Count, 0)}
		end
		BottomBarPadding:Tween{PaddingLeft = UDim.new(0, (BottomBarContainer.AbsoluteSize.X / 2) - GetBottomX())}
	end)
	
	local TabsLibrary = {}
	
	UIS.InputBegan:connect(function(Key)
		if Key.KeyCode == UIToggleKey and not Library.Binding then
			TabsLibrary:Toggle()
		end
	end)
	
	function TabsLibrary:DragLock(State)
		DraggingLocked = State
	end
	
	function TabsLibrary:DragSpeed(Value)
		DragSpeed = Value
	end
	
	function TabsLibrary:Tab(TabOptions)
		TabOptions = TabOptions or {}
		TabOptions.Name = TabOptions.Name or "Tab"
		local LocalCount = Library.Count
		Library.Count = Library.Count + 1
		local TabFrame = FunctionsFrameContainer:Object("Frame", {
			Size = UDim2.new(0, FunctionsFrameContainer.AbsoluteSize.X, 1, 0),
			BackgroundTransparency = 1
		})
		
		local TabTitle = TabFrame:Object("TextLabel", {
			Size = UDim2.new(1, 0, 0, 15),
			Position = UDim2.fromScale(0.5),
			AnchorPoint = Vector2.new(0.5),
			Text = TabOptions.Name,
			Theme = {"AccentText", "TextColor3"},
			Font = Enum.Font.SourceSans,
			TextSize = 20,
			BackgroundTransparency = 1,
			TextTransparency = 0.2
		})
		
		local BottomBarNavigation = BottomBar:Object("TextButton", {
			Text = TabOptions.Name,
			BackgroundTransparency = 1,
			Theme = {"AccentText", "TextColor3"},
			TextTransparency = (LocalCount == 0 and 0) or 0.4,
			Font = Enum.Font.SourceSans,
			TextSize = 20
		})
		BottomBarNavigation.Size = UDim2.new(0, BottomBarNavigation.TextBounds.X, 1, 0)
		
		if LocalCount == 0 then
			BottomBarPadding.PaddingLeft = UDim.new(0, (BottomBarContainer.AbsoluteSize.X / 2) - (BottomBarNavigation.AbsoluteSize.X / 2))
		end
		
		BottomBarNavigation.MouseButton1Click:connect(function()
			FunctionsFrameContainerUIPadding:Tween{PaddingLeft = UDim.new(-LocalCount, 0)}
            for _, Object in next, BottomNavObjects do
				if Object[1] ~= BottomBarNavigation then
					Object[1]:Tween{TextTransparency = 0.4}
				end
			end
			BottomBarNavigation:Tween{TextTransparency = 0}
			Count = LocalCount
			BottomBarPadding:Tween{PaddingLeft = UDim.new(0, (BottomBarContainer.AbsoluteSize.X / 2) - GetBottomX())}
			if Count == 0 then
				LeftClickContainer.Visible = false
				RightClickContainer.Visible = true
			elseif Count == #Tabs - 1 then
				RightClickContainer.Visible = false
				LeftClickContainer.Visible = true
			else
				RightClickContainer.Visible = true
				LeftClickContainer.Visible = true
			end	
		end)
		
		local FunctionsFrame = TabFrame:Object("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -25),
			Position = UDim2.fromOffset(0, 25)
		})
		
		local FunctionsListLayout = FunctionsFrame:Object("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		})
		
		CurrentTab = (LocalCount == 0 and FunctionsFrame) or CurrentTab		
		table.insert(Tabs, FunctionsFrame)
		table.insert(BottomNavObjects, {BottomBarNavigation, LocalCount})
		
		local function AddBaseTweens(Container)
			local Hovered = false
			Container.MouseEnter:connect(function()
				if BeingNotified() then return end
				Hovered = true
				Container:Tween{BackgroundColor3 = DefaultColours.FunctionHover}
			end)

			Container.MouseLeave:connect(function()
				if BeingNotified() then return end
				Hovered = false
				Container:Tween{BackgroundColor3 = DefaultColours.Function}
			end)

			Container.MouseButton1Down:connect(function()
				if BeingNotified() then return end
				Container:Tween{BackgroundColor3 = DefaultColours.FunctionClick}
				UIS.InputEnded:connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Container:Tween{BackgroundColor3 = (Hovered and DefaultColours.FunctionHover) or DefaultColours.Function}
					end
				end)
			end)
		end
		
		local FunctionsLibrary = {}
		
		function FunctionsLibrary:Label(LabelOptions)
			local Text = LabelOptions.Name or LabelOptions.Text or "Label text"
			local LabelContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"FunctionHover", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 10000)
			})
			LabelContainer:Round()
			
			local LabelOutline = LabelContainer:Object("Frame", {
				Size = UDim2.new(1, -4, 1, -4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Theme = {"Main", "BackgroundColor3"}
			})
			LabelOutline:Round(4)
			
			local LabelText = LabelOutline:Object("TextLabel", {
				Text = Text,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -6, 1, -4),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true
			})
			
			LabelContainer.Size = UDim2.new(1, 0, 0, LabelText.TextBounds.Y + 8)
			
			LabelContainer.MouseEnter:connect(function()
				if BeingNotified() then return end
				LabelContainer:Tween{BackgroundColor3 = DefaultColours.FunctionClick}
			end)

			LabelContainer.MouseLeave:connect(function()
				if BeingNotified() then return end
				LabelContainer:Tween{BackgroundColor3 = DefaultColours.FunctionHover}
			end)
		end
		
		function FunctionsLibrary:Button(ButtonOptions)
			ButtonOptions = ButtonOptions or {}
			ButtonOptions.Name = ButtonOptions.Name or "Button"
			ButtonOptions.Callback = ButtonOptions.Callback or function() end
			
			local ButtonContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"Function", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 35)
			})
			ButtonContainer:Round()
			
			local ButtonName = ButtonContainer:Object("TextLabel", {
				Text = ButtonOptions.Name,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -8, 1, 0),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			AddBaseTweens(ButtonContainer)
			ButtonContainer.MouseButton1Click:connect(function()
				if BeingNotified() then return end
				local Success, Error = pcall(ButtonOptions.Callback)
				if not Success then
					TabsLibrary:Notify{Text = Error}
					warn(Error)
				end
			end)	
			
			--[[local Description = ButtonContainer:Object("TextLabel", {
				Text = ButtonOptions.Description,
				BackgroundTransparency = 1,
				Theme = {"AccentText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 16,
				Size = UDim2.new(1, -8, 0.5),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, -1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.2
			})]]	
		end
		
		function FunctionsLibrary:Toggle(ToggleOptions)
			ToggleOptions = ToggleOptions or {}
			ToggleOptions.Name = ToggleOptions.Name or "Toggle"
			local State = ToggleOptions.State or false
			ToggleOptions.Callback = ToggleOptions.Callback or function() end
			
			local ToggleContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"Function", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 35)
			})
			ToggleContainer:Round()
			
			local ToggleName = ToggleContainer:Object("TextLabel", {
				Text = ToggleOptions.Name,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -8, 1, 0),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local SlidingContainer = ToggleContainer:Object("Frame", {
				Theme = (State and {"ToggleSliderTrue", "BackgroundColor3"}) or {"ToggleSliderFalse", "BackgroundColor3"},
				Size = UDim2.fromOffset(26, 13),
				Position = UDim2.new(1, -15, 0.5),
				AnchorPoint = Vector2.new(1, 0.5)
			})
			SlidingContainer:Round(100)
			
			local Slider = SlidingContainer:Object("Frame", {
				Size = UDim2.fromOffset(19, 19),
				Position = (State and UDim2.fromScale(1, 0.5)) or UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Theme = (State and {"ToggleTrue", "BackgroundColor3"}) or {"ToggleFalse", "BackgroundColor3"}
			})
			Slider:Round(100)
			
			ToggleContainer.MouseButton1Click:connect(function()
				if BeingNotified() then return end
				State = not State
				SlidingContainer.Theme = (State and "ToggleSliderTrue") or "ToggleSliderFalse"
				Slider.Theme = (State and "ToggleTrue") or "ToggleFalse"
				local Success, Error = pcall(ToggleOptions.Callback, State)
				if not Success then
					TabsLibrary:Notify{Text = Error}
					warn(Error)
				end
				Slider:Tween{Position = (
					State and UDim2.fromScale(1, 0.5)) or UDim2.fromScale(0, 0.5),
					BackgroundColor3 = (State and DefaultColours.ToggleTrue) or DefaultColours.ToggleFalse
				}
				SlidingContainer:Tween{BackgroundColor3 = (State and DefaultColours.ToggleSliderTrue) or DefaultColours.ToggleSliderFalse}
			end)
			
			AddBaseTweens(ToggleContainer)
		end
		
		function FunctionsLibrary:Slider(SliderOptions)
			SliderOptions = SliderOptions or {}
			SliderOptions.Name = SliderOptions.Name or "Slider"
			local Min = SliderOptions.Min or SliderOptions.Minimum or 0
			local Max = SliderOptions.Max or SliderOptions.Maximum or 100
			local Default = SliderOptions.Default or Min
			SliderOptions.Callback = SliderOptions.Callback or function() end
			
			local SliderContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"Function", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 50)
			})
			SliderContainer:Round()

			local SliderName = SliderContainer:Object("TextLabel", {
				Text = SliderOptions.Name,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -8, 0, 35),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local SliderBar = SliderContainer:Object("Frame", {
				Size = UDim2.new(1, -30, 0, 5),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -11),
				Theme = {"SliderBar", "BackgroundColor3"}
			})
			SliderBar:Round(100)
			
			local Sliding = SliderBar:Object("Frame", {
				Size = UDim2.fromOffset(11, 11),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale((Default - Min) / Max, 0.5),
				Theme = {"Sliding", "BackgroundColor3"},
				ZIndex = 3
			})
			Sliding:Round(100)
			
			local Effect = Sliding:Object("Frame", {
				Size = UDim2.fromOffset(11, 11),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Transparency = 0.5,
				Theme = {"Sliding", "BackgroundColor3"},
				ZIndex = 2
			})
			Effect:Round(100)
			
			local ValueIndicator = SliderContainer:Object("TextLabel", {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Right,
				Theme = {"AccentText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 16,
				TextTransparency = 0.2,
				Position = UDim2.new(1, -8),
				AnchorPoint = Vector2.new(1, 0),
				Text = Default .. "/" .. Max
			})
			
			local Down = false
			local Hovered = false
			
			SliderContainer.MouseEnter:connect(function()
				if BeingNotified() then return end
				Hovered = true
				Effect:Tween({Size = UDim2.fromOffset(17, 17)}, TweenInfo.new(0.1))
			end)
			
			SliderContainer.MouseLeave:connect(function()
				if BeingNotified() then return end
				Hovered = false
				if Down then return end
				Effect:Tween({Size = UDim2.fromOffset(11, 11)}, TweenInfo.new(0.1))
			end)
			
			UIS.InputEnded:connect(function(Input)
				if BeingNotified() then return end
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Down = false
					if Hovered then return end
					Effect:Tween({Size = UDim2.fromOffset(11, 11)}, TweenInfo.new(0.1))
				end
			end)

			SliderContainer.MouseButton1Down:connect(function()
				if BeingNotified() then return end
				Down = true
				while RS.RenderStepped:wait() and Down do
					local Percentage = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / (SliderBar.AbsoluteSize.X), 0, 1)
					local Value = ((Max - Min ) * Percentage) + Min
					Value = math.floor(Value)
					ValueIndicator.Text = Value .. "/" .. Max
					Sliding:Tween({Position = UDim2.fromScale(Percentage, 0.5)}, TweenInfo.new(0.05))
					local Success, Error = pcall(SliderOptions.Callback, Value)
					if not Success then warn(Error) end
				end
			end)
			
			AddBaseTweens(SliderContainer)
		end
		
		function FunctionsLibrary:Dropdown(DropdownOptions)
			DropdownOptions = DropdownOptions or {}
			DropdownOptions.Name = DropdownOptions.Name or "Dropdown"
			DropdownOptions.Options = DropdownOptions.Options or {}
			DropdownOptions.Callback = DropdownOptions.Callback or function() end
			
			local DropdownContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"Function", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 35)
			})
			DropdownContainer:Round()

			local DropdownName = DropdownContainer:Object("TextLabel", {
				Text = DropdownOptions.Name,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -8, 0, 35),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local DropdownFrame = DropdownContainer:Object("Frame", {
				Size = UDim2.new(1, -30, 1, -35),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -5),
				ClipsDescendants = true,
				Theme = {"DropdownMain", "BackgroundColor3"}
			})
			DropdownFrame:Round()
			
			local ScrollingFrame = DropdownFrame:Object("Frame", {
				Transparency = 1,
				Size = UDim2.fromScale(1, 1)
			})
			
			local DropdownLayout = ScrollingFrame:Object("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 1),
				SortOrder = Enum.SortOrder.LayoutOrder
			})	
			
			local DropdownPadding = ScrollingFrame:Object("UIPadding", {
				PaddingTop = UDim.new(0, 4)
			})
			
			local function SetTextValue(Value)
				DropdownName.Text = DropdownOptions.Name .. " \\ " .. tostring(Value)
			end
			
			local function CalculateHeight()
				local Options = #DropdownOptions.Options
				local Max = 4
				--if Options <= Max then
				return (Options * 22) + 4
				--else
				--	return (Max * 20) + 14, true
				--end
			end
			
			local DropState = false
			local function Toggle()
				if DropState then
					local Height, Max = CalculateHeight()
					DropdownContainer:Tween{Size = UDim2.new(1, 0, 0, Height + 35)}
				else
					DropdownContainer:Tween{Size = UDim2.new(1, 0, 0, 35)}
				end
			end
			
			local function CreateOption(Name)
				
				local ButtonContainer = ScrollingFrame:Object("TextButton", {
					Text = "",
					Theme = {"DropdownOption", "BackgroundColor3"},
					Size = UDim2.new(1, -8, 0, 18),
					BackgroundTransparency = 1
				})
				
				ButtonContainer:Round(5)

				local ButtonName = ButtonContainer:Object("TextLabel", {
					Text = tostring(Name),
					BackgroundTransparency = 1,
					Theme = {"AccentText", "TextColor3"},
					Font = Enum.Font.SourceSansSemibold,
					TextSize = 15,
					Size = UDim2.new(1, -8, 1, 0),
					AnchorPoint = Vector2.new(1),
					Position = UDim2.new(1),
					TextTransparency = 0.2,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				ButtonContainer.MouseEnter:connect(function()
					ButtonContainer:Tween{BackgroundTransparency = 0}
				end)
				
				ButtonContainer.MouseLeave:connect(function()
					ButtonContainer:Tween{BackgroundTransparency = 1}
				end)
				
				ButtonContainer.MouseButton1Click:connect(function()
					SetTextValue(Name)
					DropState = false
					Toggle()
					local Success, Error = pcall(DropdownOptions.Callback, Name)
					if not Success then warn(Error) end
				end)
			end
			
            for Index, Name in next, DropdownOptions.Options do
				if Index > 1 then
					ScrollingFrame:Object("Frame", {
						Size = UDim2.new(1, -16, 0, 2),
						Theme = {"Function", "BackgroundColor3"}
					})
				end
				CreateOption(Name)
			end
			
			DropdownContainer.MouseButton1Click:connect(function()
				DropState = not DropState
				Toggle()
			end)
			
			AddBaseTweens(DropdownContainer)
		end
		
		function FunctionsLibrary:Bind(BindOptions)
			BindOptions = BindOptions or {}
			BindOptions.Name = BindOptions.Name or "Bind"
			BindOptions.Mouse = BindOptions.Mouse or true
			local BindKey = BindOptions.Default or nil
			BindOptions.KeyChange = BindOptions.KeyChange or function() end
			BindOptions.Callback = BindOptions.Callback or function() end

			local BindContainer = FunctionsFrame:Object("TextButton", {
				Text = "",
				Theme = {"Function", "BackgroundColor3"},
				Size = UDim2.new(1, 0, 0, 35)
			})
			BindContainer:Round()

			local BindName = BindContainer:Object("TextLabel", {
				Text = BindOptions.Name,
				BackgroundTransparency = 1,
				Theme = {"MainText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Size = UDim2.new(1, -8, 1, 0),
				AnchorPoint = Vector2.new(1),
				Position = UDim2.new(1),
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local BindLabelContainer = BindContainer:Object("Frame", {
				Theme = {"BindContainer", "BackgroundColor3"},
				Size = UDim2.new(0, 50, 1, -16),
				Position = UDim2.new(1, -8, 0.5),
				AnchorPoint = Vector2.new(1, 0.5)
			})
			BindLabelContainer:Round(4)
			
			local BindLabel = BindLabelContainer:Object("TextLabel", {
				Theme = {"BindText", "TextColor3"},
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 16,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.4),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				Text = BindKey.Name or "..."
			})
			
			local Banned = {
				Enter = true,
				Return = true,
				Tab = true,
				Unknown = true,
				MouseMovement = true
			}
			
			local Short = {
				LeftControl = "LCtrl",
				RightControl = "RCtrl",
				LeftShift = "LShift",
				RightShift = "RShift",
				MouseButton1 = "Mouse1",
				MouseButton2 = "Mouse2",
				MouseButton3 = "Mouse3",
				CapsLock = "Caps",
				PageUp = "Pg Up",
				PageDown = "Pg Dn"
			}
			
			local Accepting = false
			local Hovered = false
			BindContainer.MouseButton1Click:connect(function()
				Accepting = true
				Library.Binding = true
				BindLabel.Text = "..."
				local Key = UIS.InputBegan:wait()
				local KeyName = (Key.UserInputType == Enum.UserInputType.Keyboard and Key.KeyCode.Name) or Key.UserInputType.Name
				if Short[KeyName] then
					KeyName = Short[KeyName]
				end
				if not Banned[KeyName] then
					BindKey = Key.KeyCode
					BindLabel.Text = KeyName
					local Success, Error = pcall(BindOptions.KeyChange, Key)
					if not Success then warn(Error) end
				else
					BindLabel.Text = BindKey.Name
				end
				UIS.InputEnded:wait()
				Accepting = false
				Library.Binding = false
			end)
			
			UIS.InputBegan:connect(function(Input)
				if Input.KeyCode == BindKey and ((not Accepting and not Hovered) or (not Accepting and Hovered))  then
					local Success, Error = pcall(BindOptions.Callback)
					if not Success then warn(Error) end
				end
			end)
			
			BindContainer.MouseEnter:connect(function()
				if BeingNotified() then return end
				Hovered = true
				BindContainer:Tween{BackgroundColor3 = DefaultColours.FunctionHover}
			end)

			BindContainer.MouseLeave:connect(function()
				if BeingNotified() then return end
				Hovered = false
				BindContainer:Tween{BackgroundColor3 = DefaultColours.Function}
			end)

			BindContainer.MouseButton1Down:connect(function()
				if BeingNotified() then return end
				BindContainer:Tween{BackgroundColor3 = DefaultColours.FunctionClick}
				UIS.InputEnded:connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						BindContainer:Tween{BackgroundColor3 = (Hovered and DefaultColours.FunctionHover) or DefaultColours.Function}
					end
				end)
			end)
		end
		
		return FunctionsLibrary
	end	
	
	function TabsLibrary:Notify(NotifyOptions)
		spawn(function()
			NotifyOptions = NotifyOptions or {}
			NotifyOptions.Text = NotifyOptions.Text or "Warning!"
			NotifyOptions.Length = NotifyOptions.Length or 5
			Blur(true)
			local Notify = BlurFrame:Object("TextButton", {
				Text = "",
				Size = UDim2.new(1, -140, 0, 35),
				BackgroundColor3 = Color3.fromRGB(102, 196, 235),
				BackgroundTransparency = 1,
				ZIndex = 6
			})
			Notify:Round()
			
			local NotifyIcon = Notify:Object("ImageLabel", {
				Image = "http://www.roblox.com/asset/?id=6519746941",
				Size = UDim2.new(0, 27, 0, 27),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 4, 0.5, 0),
				ZIndex = 7,
				ImageColor3 = DefaultColours.Notifications
			})
			
			local NotifyText = Notify:Object("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = Color3.fromRGB(45, 50, 55),
				ZIndex = 8,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Text = NotifyOptions.Text,
				TextSize = 16,
				Size = UDim2.new(1, -42, 0.5, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 1
			})
			
			local Removed = false
			
			local function Remove()
				Notify:Tween{BackgroundTransparency = 1}
				NotifyIcon:Tween{ImageTransparency = 1}
				NotifyText:Tween{TextTransparency = 1}

				wait(0.25)

				for Index, Notification in next, Notifications do
					if Notification == Notify then
						table.remove(Notifications, Index)
					end
				end
				if #Notifications == 0 then
					Blur(false)
				end
				Notify():Destroy()
				Removed = true
			end
			
			Notify.MouseButton1Click:connect(function()
				Remove()
			end)
			
			table.insert(Notifications, Notify)
			
			--fading in
			Notify:Tween{BackgroundTransparency = 0}
			NotifyIcon:Tween{ImageTransparency = 0}
			NotifyText:Tween{TextTransparency = 0}
			wait(NotifyOptions.Length)
			
			if not Removed then Remove() end
		end)
	end
	
	function TabsLibrary:Settings(SettingsOptions)
		SettingsOptions = SettingsOptions or {}
		local Name = SettingsOptions.Name or "UI Settings"
		if SettingsOptions.LockDrag == nil then
			SettingsOptions.LockDrag = true
		end
		if SettingsOptions.DragSpeed == nil then
			SettingsOptions.DragSpeed = true
		end
		if SettingsOptions.LightMode == nil then
			SettingsOptions.LightMode = true
		end
		if SettingsOptions.Toggle == nil then
			SettingsOptions.Toggle = true
		end
		local SettingsTab = TabsLibrary:Tab{Name = Name}
		
		if SettingsOptions.LightMode then
			SettingsTab:Toggle{
				Name = "Light mode",
				Callback = function(State)
					if State then
						Colours.Main = Color3.fromRGB(255, 255, 255)
						Colours.MainHover = Color3.fromRGB(240, 240, 240)
						Colours.Notifications = Color3.fromRGB(40, 45, 50)
						Colours.MainText = Color3.fromRGB(40, 40, 40)
						Colours.AccentText = Color3.fromRGB(40, 40, 40)
						Colours.Function = Color3.fromRGB(220, 220, 220)
						Colours.FunctionHover = Color3.fromRGB(210, 210, 210)
						Colours.FunctionClick = Color3.fromRGB(200, 200, 200)
						Colours.Icons = Color3.fromRGB()
						Colours.BindText = Color3.fromRGB(210, 210, 210)
					else
						Colours.Main = Color3.fromRGB(35, 35, 40)
						Colours.MainHover = Color3.fromRGB(50, 50, 55)
						Colours.Notifications = Color3.fromRGB(40, 45, 50)
						Colours.MainText = Color3.fromRGB(255, 255, 255)
						Colours.AccentText = Color3.fromRGB(255, 255, 255)
						Colours.Function = Color3.fromRGB(45, 45, 50)
						Colours.FunctionHover = Color3.fromRGB(55, 55, 60)
						Colours.FunctionClick = Color3.fromRGB(60, 60, 65)
						Colours.ToggleSliderFalse = Color3.fromRGB(70, 70, 75)
						Colours.ToggleSliderTrue = Color3.fromRGB(72, 125, 200)
						Colours.ToggleFalse = Color3.fromRGB(75, 75, 80)
						Colours.ToggleTrue = Color3.fromRGB(90, 155, 250)		
						Colours.Icons = Color3.fromRGB(255, 255, 255)
						Colours.BindText = Color3.fromRGB(255, 255, 255)
					end
				end,
			}
		end
		
		if SettingsOptions.LockDrag then
			SettingsTab:Toggle{
				Name = "Lock dragging",
				Callback = function(State)
					TabsLibrary:DragLock(State)
				end,
			}
		end
		
		if SettingsOptions.Toggle then
			SettingsTab:Bind{
				Name = "UI Toggle Key",
				Default = Enum.KeyCode.Insert,
				KeyChange = function(Key)
					UIToggleKey = Key.KeyCode
				end,
			}
		end
		
		if SettingsOptions.DragSpeed then
			SettingsTab:Slider{
				Name = "UI Drag Speed",
				Min = 0,
				Max = 25,
				Default = 10,
				Callback = function(Value)
					TabsLibrary:DragSpeed(Value / 100)
				end,
			}
		end
		return SettingsTab
	end
	
	function TabsLibrary:Toggle()
		spawn(function()
			UIToggleState = not UIToggleState
			if UIToggleState then
				MainFrame:Tween{Size = (UIToggleState and LibraryOptions.Size) or UDim2.new()}
				wait(0.25)
				LeftBar.Visible = true
				RightBar.Visible = true
				BlurFrame:Tween{BackgroundTransparency = (UIToggleState and 1) or 0}
			else
				BlurFrame:Tween{BackgroundTransparency = (UIToggleState and 1) or 0}
				wait(0.25)
				LeftBar.Visible = false
				RightBar.Visible = false
				MainFrame:Tween{Size = (UIToggleState and LibraryOptions.Size) or UDim2.new()}
			end
		end)
	end
	return TabsLibrary
end
return Library

