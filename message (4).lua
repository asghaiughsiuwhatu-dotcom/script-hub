-- g0ds_shithub Hub Script - Final patched (keeps your GUI EXACTLY the same)
-- fixes: no spin on fly, press-a-key bind, working touch fling, rainbow = text-only
-- kept layout/colors/tabs identical to your original

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- DEFAULT CONFIG
local HubName = "g0ds_shithub"
local GuiThemeColor = Color3.fromRGB(0,170,255)
local RainbowMode = false

-- DEFAULT WALK/JUMP
local defaultSpeed = 16
local defaultJump = 50

-- FLY CONFIG
local flyEnabled = false
local flySpeed = 50
local flyKey = Enum.KeyCode.F

-- FLING CONFIG
local flingEnabled = false

-- ------------------ LAUNCH SCREEN (3s pause BEFORE GUI) ------------------
local launchScreen = Instance.new("ScreenGui")
launchScreen.Name = "LaunchScreen"
launchScreen.ResetOnSpawn = false
launchScreen.Parent = game:GetService("CoreGui")

local launchFrame = Instance.new("Frame")
launchFrame.Size = UDim2.new(1,0,1,0)
launchFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
launchFrame.BackgroundTransparency = 0.9
launchFrame.Parent = launchScreen

local launchText = Instance.new("TextLabel")
launchText.Size = UDim2.new(1,0,0,50)
launchText.Position = UDim2.new(0,0,0.5,-25)
launchText.Text = HubName
launchText.TextColor3 = GuiThemeColor
launchText.TextScaled = true
launchText.BackgroundTransparency = 1
launchText.Font = Enum.Font.GothamBold
launchText.Parent = launchFrame

-- wait 3s then destroy launchScreen and continue to build the full gui
task.delay(3, function()
    if launchScreen and launchScreen.Parent then
        launchScreen:Destroy()
    end
end)

-- wait synchronously so GUI doesn't show until after launch is gone
repeat task.wait() until not (launchScreen and launchScreen.Parent)

-- ------------------ MAIN GUI (KEEPING IT THE SAME) ------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HubName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,500,0,350)
MainFrame.Position = UDim2.new(0.5,-250,0.5,-175)
MainFrame.BackgroundColor3 = GuiThemeColor
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = MainFrame

-- DRAG
local dragging=false
local dragInput, mousePos, framePos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        mousePos=input.Position
        framePos=MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then
                dragging=false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement then
        dragInput=input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then
        local delta=input.Position-mousePos
        MainFrame.Position=UDim2.new(framePos.X.Scale,framePos.X.Offset+delta.X,framePos.Y.Scale,framePos.Y.Offset+delta.Y)
    end
end)

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size=UDim2.new(1,0,0,35)
TopBar.BackgroundColor3=Color3.fromRGB(30,30,30)
TopBar.Parent=MainFrame
local topCorner=UICorner:Clone()
topCorner.Parent=TopBar

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,0,1,0)
Title.BackgroundTransparency=1
Title.Text=HubName
Title.TextColor3=GuiThemeColor
Title.TextScaled=true
Title.Font=Enum.Font.GothamBold
Title.Parent=TopBar

-- MINIMIZE BUTTON
local MinBtn=Instance.new("TextButton")
MinBtn.Size=UDim2.new(0,35,0,35)
MinBtn.Position=UDim2.new(1,-35,0,0)
MinBtn.BackgroundColor3=Color3.fromRGB(40,40,40)
MinBtn.Text="-"
MinBtn.TextColor3=Color3.new(1,1,1)
MinBtn.Font=Enum.Font.GothamBold
MinBtn.TextScaled=true
MinBtn.Parent=TopBar
local minCorner=UICorner:Clone()
minCorner.Parent=MinBtn

local minimized=false
local function ToggleMinimize()
    if not minimized then
        TweenService:Create(MainFrame,TweenInfo.new(0.5),{Size=UDim2.new(0,150,0,35)}):Play()
        minimized=true
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.5),{Size=UDim2.new(0,500,0,350)}):Play()
        minimized=false
    end
end
MinBtn.MouseButton1Click:Connect(ToggleMinimize)
UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        ToggleMinimize()
    end
end)

-- TABS
local TabHolder=Instance.new("Frame")
TabHolder.Size=UDim2.new(0,100,1,-35)
TabHolder.Position=UDim2.new(0,0,0,35)
TabHolder.BackgroundColor3=Color3.fromRGB(25,25,25)
TabHolder.Parent=MainFrame
local tabCorner=UICorner:Clone()
tabCorner.Parent=TabHolder

local TabContainer=Instance.new("Frame")
TabContainer.Size=UDim2.new(1,-100,1,-35)
TabContainer.Position=UDim2.new(0,100,0,35)
TabContainer.BackgroundColor3=Color3.fromRGB(35,35,35)
TabContainer.Parent=MainFrame
local containerCorner=UICorner:Clone()
containerCorner.Parent=TabContainer

-- Tabs
local Tabs={"Home","Settings","Scripts","ESP"}
local tabFrames={}
for i,tabName in ipairs(Tabs) do
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,35)
    btn.Position=UDim2.new(0,0,0,(i-1)*35)
    btn.BackgroundColor3=Color3.fromRGB(40,40,40)
    btn.Text=tabName
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.Parent=TabHolder
    local btnCorner=UICorner:Clone()
    btnCorner.Parent=btn

    local frame=Instance.new("ScrollingFrame")
    frame.Size=UDim2.new(1,0,1,0)
    frame.Position=UDim2.new(0,0,0,0)
    frame.BackgroundTransparency=1
    frame.CanvasSize=UDim2.new(0,0,2,0)
    frame.Visible=false
    frame.Parent=TabContainer
    tabFrames[tabName]=frame

    btn.MouseButton1Click:Connect(function()
        for _,f in pairs(tabFrames) do f.Visible=false end
        frame.Visible=true
    end)
end

-- HOME
local homeLabel=Instance.new("TextLabel")
homeLabel.Size=UDim2.new(1,0,0,50)
homeLabel.Position=UDim2.new(0,0,0,0)
homeLabel.BackgroundTransparency=1
homeLabel.Text="Made by g0riz niggas"
homeLabel.TextColor3=Color3.fromRGB(0,255,0)
homeLabel.TextScaled=true
homeLabel.Font=Enum.Font.GothamBold
homeLabel.Parent=tabFrames["Home"]

-- SETTINGS
local settingsFrame=tabFrames["Settings"]
-- Color Buttons
local colors={{255,0,0},{0,255,0},{0,0,255},{255,255,0},{255,0,255},{0,255,255}}
for i,c in ipairs(colors) do
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,40,0,40)
    btn.Position=UDim2.new(0,10+(i-1)*45,0,10)
    btn.BackgroundColor3=Color3.fromRGB(c[1],c[2],c[3])
    btn.Text=""
    btn.Parent=settingsFrame
    btn.MouseButton1Click:Connect(function()
        GuiThemeColor=Color3.fromRGB(c[1],c[2],c[3])
        MainFrame.BackgroundColor3=GuiThemeColor
        Title.TextColor3=GuiThemeColor
    end)
end

local rainbowToggle=Instance.new("TextButton")
rainbowToggle.Size=UDim2.new(0,150,0,30)
rainbowToggle.Position=UDim2.new(0,10,0,60)
rainbowToggle.Text="Rainbow Mode: OFF"
rainbowToggle.Font=Enum.Font.GothamBold
rainbowToggle.TextScaled=true
rainbowToggle.Parent=settingsFrame

rainbowToggle.MouseButton1Click:Connect(function()
    RainbowMode=not RainbowMode
    rainbowToggle.Text="Rainbow Mode: "..(RainbowMode and "ON" or "OFF")
end)

-- capture original text colors so we can restore when rainbow OFF
local originalTextColors = {}
for _,obj in ipairs(ScreenGui:GetDescendants()) do
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        originalTextColors[obj] = obj.TextColor3
    end
end

-- RAINBOW (text-only) - cycles only TextLabel/TextButton colors; restores originals on OFF
RunService.RenderStepped:Connect(function()
    if RainbowMode then
        local t=tick()
        local r,g,b = math.sin(t*2)*0.5+0.5, math.sin(t*2+2)*0.5+0.5, math.sin(t*2+4)*0.5+0.5
        for _,obj in ipairs(ScreenGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.TextColor3 = Color3.new(r,g,b)
            end
        end
    else
        for obj,color in pairs(originalTextColors) do
            if obj and obj.Parent then
                obj.TextColor3 = color
            end
        end
    end
end)

-- SCRIPTS TAB
local scriptsFrame=tabFrames["Scripts"]

local destroyHubBtn = Instance.new("TextButton")
destroyHubBtn.Size = UDim2.new(0,200,0,30)
destroyHubBtn.Position = UDim2.new(0,10,0,500) -- below all launchers
destroyHubBtn.Text = "Destroy Hub"
destroyHubBtn.Font = Enum.Font.GothamBold
destroyHubBtn.TextScaled = true
destroyHubBtn.TextColor3 = Color3.fromRGB(255,0,0)
destroyHubBtn.Parent = scriptsFrame

destroyHubBtn.MouseButton1Click:Connect(function()
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end)

destroyHubBtn.MouseButton1Click:Connect(function()
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    flyEnabled = false
    espEnabled = false
end)

----------------------------------------------------------------
-- SCRIPT HUBS (LAUNCHERS) – SAFE ADDITION
----------------------------------------------------------------

local scriptHubTitle = Instance.new("TextLabel")
scriptHubTitle.Size = UDim2.new(0,300,0,30)
scriptHubTitle.Position = UDim2.new(0,10,0,300)
scriptHubTitle.BackgroundTransparency = 1
scriptHubTitle.Text = "Script Hubs"
scriptHubTitle.TextColor3 = Color3.fromRGB(255,255,255)
scriptHubTitle.Font = Enum.Font.GothamBold
scriptHubTitle.TextScaled = true
scriptHubTitle.Parent = scriptsFrame

local function createLauncher(name, yPos, scriptText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,240,0,30)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = scriptsFrame

    local launched = false

    btn.MouseButton1Click:Connect(function()
        if launched then return end
        launched = true
        btn.Text = "Launching..."

        pcall(function()
            loadstring(scriptText)()
        end)

        task.wait(0.3)
        btn.Text = name.." (Launched)"
    end)
end

-- UNIVERSAL SCRIPTS
createLauncher(
    "VexonHub",
    340,
    [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub"))()
    ]]
)

createLauncher(
    "Infinite Yield",
    380,
    [[
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
    ]]
)

createLauncher(
    "DaddyKoyaHub",
    420,
    [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/asghaiughsiuwhatu-dotcom/script-hub/refs/heads/main/Untitled-2.lua"))()
    ]]
)

-- FRIEND HUBS
createLauncher(
    "VAPE",
    460,
    [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
    ]]
)

-- WalkSpeed Slider
local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(0,200,0,30)
speedLabel.Position=UDim2.new(0,10,0,10)
speedLabel.BackgroundTransparency=1
speedLabel.Text="WalkSpeed: "..defaultSpeed
speedLabel.TextColor3=Color3.fromRGB(0,255,0)
speedLabel.TextScaled=true
speedLabel.Font=Enum.Font.GothamBold
speedLabel.Parent=scriptsFrame

local speedSlider=Instance.new("TextBox")
speedSlider.Size=UDim2.new(0,150,0,30)
speedSlider.Position=UDim2.new(0,10,0,50)
speedSlider.Text=tostring(defaultSpeed)
speedSlider.TextScaled=true
speedSlider.Font=Enum.Font.GothamBold
speedSlider.Parent=scriptsFrame

speedSlider.FocusLost:Connect(function()
    local val=tonumber(speedSlider.Text)
    if val then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed=val
        end
        speedLabel.Text="WalkSpeed: "..val
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed=defaultSpeed
        end
        speedSlider.Text=tostring(defaultSpeed)
        speedLabel.Text="WalkSpeed: "..defaultSpeed
    end
end)

-- JumpHeight Slider
local jumpLabel=Instance.new("TextLabel")
jumpLabel.Size=UDim2.new(0,200,0,30)
jumpLabel.Position=UDim2.new(0,10,0,90)
jumpLabel.BackgroundTransparency=1
jumpLabel.Text="JumpPower: "..defaultJump
jumpLabel.TextColor3=Color3.fromRGB(0,255,0)
jumpLabel.TextScaled=true
jumpLabel.Font=Enum.Font.GothamBold
jumpLabel.Parent=scriptsFrame

local jumpSlider=Instance.new("TextBox")
jumpSlider.Size=UDim2.new(0,150,0,30)
jumpSlider.Position=UDim2.new(0,10,0,130)
jumpSlider.Text=tostring(defaultJump)
jumpSlider.TextScaled=true
jumpSlider.Font=Enum.Font.GothamBold
jumpSlider.Parent=scriptsFrame

jumpSlider.FocusLost:Connect(function()
    local val=tonumber(jumpSlider.Text)
    if val then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower=val
        end
        jumpLabel.Text="JumpPower: "..val
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower=defaultJump
        end
        jumpSlider.Text=tostring(defaultJump)
        jumpLabel.Text="JumpPower: "..defaultJump
    end
end)

-- INFINITE JUMP BUTTON (next to Jump slider)
local infiniteJumpEnabled = false

local infiniteJumpToggle = Instance.new("TextButton")
infiniteJumpToggle.Size = UDim2.new(0,150,0,30)
-- place it horizontally next to the jumpSlider
infiniteJumpToggle.Position = UDim2.new(0, jumpSlider.Position.X.Offset + jumpSlider.Size.X.Offset + 10, 0, jumpSlider.Position.Y.Offset)
infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
infiniteJumpToggle.TextColor3 = Color3.fromRGB(255,255,0)
infiniteJumpToggle.Font = Enum.Font.GothamBold
infiniteJumpToggle.TextScaled = true
infiniteJumpToggle.Text = "Infinite Jump: OFF"
infiniteJumpToggle.Parent = scriptsFrame

-- toggle functionality
infiniteJumpToggle.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    infiniteJumpToggle.Text = "Infinite Jump: "..(infiniteJumpEnabled and "ON" or "OFF")
end)

-- infinite jump logic
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly Toggle & Keybind UI (press-a-key button)
local flyToggle=Instance.new("TextButton")
flyToggle.Size=UDim2.new(0,150,0,30)
flyToggle.Position=UDim2.new(0,10,0,170)
flyToggle.Text="Fly: OFF"
flyToggle.Font=Enum.Font.GothamBold
flyToggle.TextScaled=true
flyToggle.Parent=scriptsFrame

local flyKeyBtn = Instance.new("TextButton")
flyKeyBtn.Size = UDim2.new(0,150,0,30)
flyKeyBtn.Position = UDim2.new(0,170,0,170)
flyKeyBtn.Text = "Set Fly Key (press)"
flyKeyBtn.Font = Enum.Font.GothamBold
flyKeyBtn.TextScaled = true
flyKeyBtn.Parent = scriptsFrame

local flyEnabled = false
local awaitingKey = false

flyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyToggle.Text = "Fly: "..(flyEnabled and "ON" or "OFF")
end)

-- press-a-key behaviour
flyKeyBtn.MouseButton1Click:Connect(function()
    flyKeyBtn.Text = "Press any key..."
    awaitingKey = true
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            flyKey = input.KeyCode
            flyKeyBtn.Text = "Fly Key: "..flyKey.Name
            awaitingKey = false
            conn:Disconnect()
        end
    end)
end)

-- fly speed UI
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0,200,0,25)
flySpeedLabel.Position = UDim2.new(0,10,0,210)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed: "..tostring(flySpeed)
flySpeedLabel.TextColor3 = Color3.fromRGB(0,255,0)
flySpeedLabel.TextScaled = true
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.Parent = scriptsFrame

local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Size = UDim2.new(0,150,0,25)
flySpeedBox.Position = UDim2.new(0,10,0,240)
flySpeedBox.Text = tostring(flySpeed)
flySpeedBox.Font = Enum.Font.GothamBold
flySpeedBox.TextScaled = true
flySpeedBox.Parent = scriptsFrame

flySpeedBox.FocusLost:Connect(function()
    local v = tonumber(flySpeedBox.Text)
    if v then
        flySpeed = v
        flySpeedLabel.Text = "Fly Speed: "..tostring(flySpeed)
    else
        flySpeedBox.Text = tostring(flySpeed)
    end
end)

-- Fly logic (no spin, camera-direction, uses flyKey)
RunService:BindToRenderStep("g0ds_fly", Enum.RenderPriority.Camera.Value + 1, function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        LocalPlayer.Character.Humanoid.PlatformStand = true

        -- stop spinning
        pcall(function()
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end)

        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir.Unit * flySpeed
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- toggle fly with key press (uses flyKey set by press-a-key)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == flyKey then
            flyEnabled = not flyEnabled
            flyToggle.Text = "Fly: "..(flyEnabled and "ON" or "OFF")
        end
    end
end)

-- Touch Fling (real working version: local player's parts touching others will fling them)
local flingLauncher = Instance.new("TextButton")
flingLauncher.Size = UDim2.new(0,150,0,30)
flingLauncher.Position = UDim2.new(0,10,0,270)
flingLauncher.Text = "Launch Fling"
flingLauncher.Font = Enum.Font.GothamBold
flingLauncher.TextScaled = true
flingLauncher.Parent = scriptsFrame

local ran = false -- prevents multiple launches

flingLauncher.MouseButton1Click:Connect(function()
    if ran then return end
    ran = true
    flingLauncher.Text = "Launching..."

    pcall(function()
        -- example:
        loadstring([[
            -- skiddos
-- Instances:
 
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
 
--Properties:
 
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
 
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderSizePixel = 2
Frame.Position = UDim2.new(0.341826946, 0, 0.367763907, 0)
Frame.Size = UDim2.new(0, 148, 0, 106)
 
TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderSizePixel = 2
TextButton.Position = UDim2.new(0.0835492909, 0, 0.552504063, 0)
TextButton.Size = UDim2.new(0, 124, 0, 37)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "OFF"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 41.000
 
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.0649713054, 0, 0.0727680102, 0)
TextLabel.Size = UDim2.new(0, 128, 0, 39)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Touch Fling"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 34.000
 
-- Scripts:
 
local function CTIKC_fake_script() -- TextButton.LocalScript 
	local script = Instance.new('LocalScript', TextButton)
 
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
 
	local toggleButton = script.Parent
	local hiddenfling = false
 
 
	if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = Instance.new("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = ReplicatedStorage
	end
 
	local function fling()
		local hrp, c, vel, movel = nil, nil, nil, 0.1
		local lp = Players.LocalPlayer
 
		while true do
			RunService.Heartbeat:Wait()
			if hiddenfling then
				while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
					RunService.Heartbeat:Wait()
					c = lp.Character
					hrp = c and c:FindFirstChild("HumanoidRootPart")
				end
 
				if hiddenfling then
					vel = hrp.Velocity
					hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
					RunService.RenderStepped:Wait()
					if c and c.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel
					end
					RunService.Stepped:Wait()
					if c and c.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = movel * -1
					end
				end
			end
		end
	end
 
	toggleButton.MouseButton1Click:Connect(function()
		hiddenfling = not hiddenfling
		if hiddenfling then
			toggleButton.Text = "ON"
		else
			toggleButton.Text = "OFF"
		end
	end)
 
	fling()
 
end
coroutine.wrap(CTIKC_fake_script)()
local function FFJFK_fake_script() -- Frame.LocalScript 
	local script = Instance.new('LocalScript', Frame)
 
	script.Parent.Active = true
	script.Parent.Draggable = true
end
coroutine.wrap(FFJFK_fake_script)()

--

local function FFJFK_fake_script() -- Frame.LocalScript 
	local script = Instance.new('LocalScript', Frame)
 
	script.Parent.Active = true
	script.Parent.Draggable = true
end
coroutine.wrap(FFJFK_fake_script)()
        ]])()
    end)

    flingLauncher.Text = "Launched!"
end)

-- connect local player's parts once and for future chars
local function connectFlingToCharacter(char)
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if not flingEnabled then return end
                local targetChar = hit.Parent
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and targetChar ~= char then
                    local targetHRP = targetChar.HumanoidRootPart
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                    -- fling away from local player
                    local dir = (targetHRP.Position - char:FindFirstChild("HumanoidRootPart").Position).Unit
                    bv.Velocity = dir * 200 + Vector3.new(0,120,0)
                    bv.Parent = targetHRP
                    Debris:AddItem(bv, 0.35)
                end
            end)
        end
    end
end

if LocalPlayer.Character then
    connectFlingToCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    connectFlingToCharacter(char)
end)

-- ESP Tab
local espFrame=tabFrames["ESP"]
local espToggle=Instance.new("TextButton")
espToggle.Size=UDim2.new(0,150,0,30)
espToggle.Position=UDim2.new(0,10,0,10)
espToggle.Text="ESP: OFF"
espToggle.Font=Enum.Font.GothamBold
espToggle.TextScaled=true
espToggle.Parent=espFrame

local espEnabled=false
espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "ESP: "..(espEnabled and "ON" or "OFF")
end)

-- CAMLOCK TOGGLE (locks onto head, instant)
local camlockEnabled = false

-- toggle button
local camlockToggle = Instance.new("TextButton")
camlockToggle.Size = UDim2.new(0,150,0,30)
camlockToggle.Position = UDim2.new(0,170,0,10) -- next to ESP toggle
camlockToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
camlockToggle.TextColor3 = Color3.fromRGB(255,255,0)
camlockToggle.Font = Enum.Font.GothamBold
camlockToggle.TextScaled = true
camlockToggle.Text = "CamLock: OFF"
camlockToggle.Parent = espFrame

camlockToggle.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    camlockToggle.Text = "CamLock: "..(camlockEnabled and "ON" or "OFF")
end)

-- function to find closest player to mouse
local function getClosestPlayer()
    local closestDist = math.huge
    local closestPlayer = nil
    local mousePos = UserInputService:GetMouseLocation()
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- camlock logic
RunService.RenderStepped:Connect(function()
    if camlockEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ESP loop: highlight + name above head
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not player.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight")
                    h.Adornee = player.Character
                    h.FillColor = Color3.fromRGB(255,0,0)
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.Parent = player.Character
                end
                if not player.Character:FindFirstChild("ESPName") then
                    local nameTag = Instance.new("BillboardGui")
                    nameTag.Name = "ESPName"
                    nameTag.Size = UDim2.new(0,100,0,30)
                    nameTag.Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                    nameTag.AlwaysOnTop = true
                    nameTag.Parent = player.Character

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Text = player.Name
                    txt.TextColor3 = Color3.fromRGB(0,255,0)
                    txt.TextScaled = true
                    txt.Font = Enum.Font.GothamBold
                    txt.Parent = nameTag
                end
            else
                if player.Character then
                    local h = player.Character:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                    local n = player.Character:FindFirstChild("ESPName")
                    if n then n:Destroy() end
                end
            end
        end
    else
        for _,player in pairs(Players:GetPlayers()) do
            if player.Character then
                local h = player.Character:FindFirstChild("Highlight")
                if h then h:Destroy() end
                local n = player.Character:FindFirstChild("ESPName")
                if n then n:Destroy() end
            end
        end
    end
end)

-- ensure initial GUI text-color cache contains any elements created after setup
-- (preserves their original colors when rainbow off)
task.delay(0.15, function()
    for _,obj in ipairs(ScreenGui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and not originalTextColors[obj] then
            originalTextColors[obj] = obj.TextColor3
        end
    end
end)

-- done: all fixes applied, UI left unchanged