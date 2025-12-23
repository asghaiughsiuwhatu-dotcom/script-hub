local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()  

local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Window = Starlight:CreateWindow({
    Name = "Script hud (by koya)",
    Subtitle = "v1.0",
    Icon = 123456789,

    LoadingSettings = {
        Title = "My Script Hub",
        Subtitle = "Welcome to My Script Hub",
    },

    FileSettings = {
        ConfigFolder = "Script hud"
    },
})
-- tabs sections (im dumb for putting it here)
local TabSection = Window:CreateTabSection("Script hub section")

local Builtinw = Window:CreateTabSection("Bulit in features")
-- these are tabs
local Tab = TabSection:CreateTab({
    Name = "Scripts",
    Columns = 2,
}, "INDEX")

local builtin = Builtinw:CreateTab({
    Name = "Built in features",
    Columns = 2,
}, "INDEX")

local Sliders1 = builtin:CreateGroupbox({
    Name = "Sliders",
    Column = 1,
}, "INDEX")

local Toggles = builtin:CreateGroupbox({
    Name = "Toggles",
    Column = 2,
}, "INDEX")

local Universal = Tab:CreateGroupbox({
    Name = "Universal scripts",
    Column = 1,
}, "INDEX")

local Tsb = Tab:CreateGroupbox({
    Name = "Strongest battle grounds",
    Column = 2,
}, "INDEX")

local Dialog = Window:PromptDialog({
    Name = "Header",
    Content = "Description",
    Type = 1,
    Actions = { 
        Primary = {
            Name = "This is a script hub ok?",
            Icon = NebulaIcons:GetIcon("check", "Material"),
            Callback = function()

            end
        }, 
        {
            Name = "Sybau twin ik",
            Callback = function()

            end
        },
    }
})


local Button = Universal:CreateButton({
    Name = "Vape v4",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        local url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"
        loadstring(game:HttpGet(url))()
    end,
}, "INDEX")


local Notifications = Starlight:Notification({
    Title = "Notification",
    Icon = NebulaIcons:GetIcon('sparkle', 'Material'),
    Content = "Thank you for using my hub :3",
}, "INDEX")


local Button = Universal:CreateButton({
    Name = "Infinte yield",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        local url = "Https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
        loadstring(game:HttpGet(url))()
    end,
}, "INDEX")

local Button = Tsb:CreateButton({
    Name = "Vexon (best)",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        local url = "https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub"
        loadstring(game:HttpGet(url))()
    end,
}, "INDEX")

local Button = Tsb:CreateButton({
    Name = "Tam hub",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        local url = "https://raw.githubusercontent.com/tamarixr/tamhub/main/bettertamhub.lua"
        loadstring(game:HttpGet(url))()
    end,
}, "INDEX")

local sliding = Sliders1:CreateSlider({
    Name = "Walkspeed",
    Icon = NebulaIcons:GetIcon('chart-no-axes-column-increasing', 'Lucide'),
    Range = {16, 250},
    Increment = 1,
    Callback = (function()
        local player = game.Players.LocalPlayer
        local currentWalkSpeed = 16

        -- Continuously apply walkspeed to humanoid if exists
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                if humanoid.WalkSpeed ~= currentWalkSpeed then
                    humanoid.WalkSpeed = currentWalkSpeed
                end
            end
        end)

        return function(Value)
            currentWalkSpeed = Value
        end
    end)(),
}, "INDEX")

local Button = Toggles:CreateButton({
    Name = "InfiniteJump",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        local player = game.Players.LocalPlayer
        local inputService = game:GetService("UserInputService")
        local character = player.Character
        local humanoid
        local infJumpEnabled = true
        local infJumpConnection

        -- Function to update humanoid reference on respawn
        local function updateCharacter(char)
            character = char
            humanoid = character:WaitForChild("Humanoid")
        end

        -- Initial character setup
        if player.Character then
            updateCharacter(player.Character)
        end
        player.CharacterAdded:Connect(updateCharacter)

        -- Input handling
        infJumpConnection = inputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if not infJumpEnabled then return end
            if input.KeyCode == Enum.KeyCode.Space and humanoid then
                humanoid:ChangeState("Jumping")
            end
        end)
    end,
}, "INDEX")

local gravitySlider = Sliders1:CreateSlider({
    Name = "Gravity",
    Icon = NebulaIcons:GetIcon('arrow-down', 'Lucide'),
    Range = {0, 196.2},  -- Roblox default gravity is 196.2
    Increment = 1,
    Callback = (function()
        local currentGravity = 196.2  -- default Roblox gravity

        -- Continuously apply gravity
        game:GetService("RunService").RenderStepped:Connect(function()
            if workspace.Gravity ~= currentGravity then
                workspace.Gravity = currentGravity
            end
        end)

        return function(Value)
            currentGravity = Value
        end
    end)(),
}, "INDEX")

local hipHeightSlider = Sliders1:CreateSlider({
    Name = "HipHeight",
    Icon = NebulaIcons:GetIcon('arrows-vertical', 'Lucide'),
    Range = {2, 10},  -- default Humanoid HipHeight is usually around 2
    Increment = 0.1,
    Callback = (function()
        local player = game.Players.LocalPlayer
        local currentHipHeight = 2  -- default value

        -- Continuously apply HipHeight if humanoid exists
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                if humanoid.HipHeight ~= currentHipHeight then
                    humanoid.HipHeight = currentHipHeight
                end
            end
        end)

        return function(Value)
            currentHipHeight = Value
        end
    end)(),
}, "INDEX")



