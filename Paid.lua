
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/VexEdge/Rizz/refs/heads/patch-2/Geckoo.Lib.Fr"))()


local hint = Instance.new("Hint", game.CoreGui)
hint.Text = "u beta tester <3 .gg/BERy46wv5a (OwO)"
local fullText = ""
local typingSpeed = 0.3 -- Adjust the speed of typing (in seconds)

-- Typing effect
for i = 1, #fullText do
    hint.Text = string.sub(fullText, 1, i)
    wait(typingSpeed)
end

-- Wait for 5 seconds before disappearing
wait(5)

-- Remove the hint
hint:Destroy()



local PepsisWorld = library:CreateWindow({
    Name = "Geckoo ",
    Credit= "False"
})



local GeneralTab = PepsisWorld:CreateTab({
    Name = "Client"
})

local ClientSided = GeneralTab:CreateSection({
    Name = "Esp"
})


local ClientSided = GeneralTab:CreateSection({
    Name = "Esp"
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LOCAL_PLAYER = Players.LocalPlayer

local DEFAULT_MAX_DISTANCE = 600 -- Default: 600 meters
local espMaxDistance = DEFAULT_MAX_DISTANCE
local chamsMaxDistance = DEFAULT_MAX_DISTANCE

-- Variables to track toggle states
local espEnabled = false
local chamsEnabled = false
local fillColor = Color3.fromRGB(194, 218, 184) -- Default fill color for Chams

-- Table to track players with ESP
local trackedPlayers = {}

-- Function to create ESP for a player
local function createESP(player)
    if not espEnabled or trackedPlayers[player] then return end

    local espElements = {
        espBox = Drawing.new("Square"),
        nameLabel = Drawing.new("Text"),
        distanceLabel = Drawing.new("Text"),
        connection = nil
    }

    -- ESP Box Settings
    espElements.espBox.Thickness = 2
    espElements.espBox.Color = Color3.new(1, 0, 0) -- Red box
    espElements.espBox.Filled = false
    espElements.espBox.Visible = false

    -- Name Label Settings
    espElements.nameLabel.Size = 16
    espElements.nameLabel.Center = true
    espElements.nameLabel.Outline = true
    espElements.nameLabel.Color = Color3.new(1, 1, 1) -- White text
    espElements.nameLabel.Visible = false

    -- Distance Label Settings
    espElements.distanceLabel.Size = 14
    espElements.distanceLabel.Center = true
    espElements.distanceLabel.Outline = true
    espElements.distanceLabel.Color = Color3.new(1, 1, 1) -- White text
    espElements.distanceLabel.Visible = false

    -- Function to update ESP elements
    local function updateESP()
        if not espEnabled or not player.Character then
            for _, element in pairs(espElements) do
                if typeof(element) ~= "RBXScriptConnection" then
                    element.Visible = false
                end
            end
            return
        end

        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local distanceMeters = (LOCAL_PLAYER.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude / 3.28
            if distanceMeters <= espMaxDistance then
                local rootScreenPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if rootOnScreen then
                    espElements.espBox.Position = Vector2.new(rootScreenPos.X - 5, rootScreenPos.Y - 5)
                    espElements.espBox.Size = Vector2.new(10, 10)
                    espElements.espBox.Visible = true
                    espElements.nameLabel.Position = Vector2.new(rootScreenPos.X, rootScreenPos.Y - 20)
                    espElements.nameLabel.Text = player.Name
                    espElements.nameLabel.Visible = true
                    espElements.distanceLabel.Position = Vector2.new(rootScreenPos.X, rootScreenPos.Y + 10)
                    espElements.distanceLabel.Text = string.format("%.1f meters", distanceMeters)
                    espElements.distanceLabel.Visible = true
                else
                    -- Hide ESP elements if not on screen
                    for _, element in pairs(espElements) do
                        if typeof(element) ~= "RBXScriptConnection" then
                            element.Visible = false
                        end
                    end
                end
            else
                -- Destroy ESP elements if out of range
                if espElements.connection then
                    espElements.connection:Disconnect()
                end
                for _, element in pairs(espElements) do
                    if typeof(element) ~= "RBXScriptConnection" then
                        element:Remove()
                    end
                end
                trackedPlayers[player] = nil
            end
        end
    end

    -- Start updating ESP
    espElements.connection = RunService.RenderStepped:Connect(updateESP)
    trackedPlayers[player] = espElements
end

-- Toggle ESP
ClientSided:AddToggle({
    Name = "Toggle ESP",
    Flag = "ESP_Toggle",
    Keybind = 1,
    Callback = function(state)
        espEnabled = state
        if not espEnabled then
            for _, espData in pairs(trackedPlayers) do
                if espData.connection then
                    espData.connection:Disconnect()
                end
                for _, element in pairs(espData) do
                    if typeof(element) ~= "RBXScriptConnection" then
                        element:Remove()
                    end
                end
            end
            trackedPlayers = {}
        else
            for _, player in ipairs(Players:GetPlayers()) do
                createESP(player)
            end
        end
    end
})

-- ESP Range Slider
ClientSided:AddSlider({
    Name = "ESP Range",
    Min = 50,
    Max = 2000,
    Value = 50,
    Callback = function(value)
        espMaxDistance = value
    end
})

-- Function to apply Chams
local function ApplyHighlight(player)
    if not chamsEnabled then return end
    local character = player.Character or player.CharacterAdded:Wait()
    if character and (LOCAL_PLAYER.Character.HumanoidRootPart.Position - character:GetPivot().Position).Magnitude / 3.28 <= chamsMaxDistance then
        local highlighter = Instance.new("Highlight", character)
        highlighter.FillColor = fillColor
    end
end


local ClientSided = GeneralTab:CreateSection({
    Name = "Chams",
})

-- Toggle Chams
ClientSided:AddToggle({
    Name = "Toggle Chams",
    Flag = "Chams_Toggle",
    Keybind = 2,
    Callback = function(state)
        chamsEnabled = state
        for _, player in ipairs(Players:GetPlayers()) do
            if chamsEnabled then
                ApplyHighlight(player)
            else
                if player.Character then
                    for _, highlight in pairs(player.Character:GetChildren()) do
                        if highlight:IsA("Highlight") then
                            highlight:Destroy()
                        end
                    end
                end
            end
        end
    end
})

-- Chams Range Slider
ClientSided:AddSlider({
    Name = "Chams Range",
    Min = 50,
    Max = 2000,
    Value = 50,
    Callback = function(value)
        chamsMaxDistance = value
    end
})

-- Set Chams Color
ClientSided:AddColorpicker({
    Name = "Chams Fill Color",
    Value = fillColor,
    Flag = "Chams_Fill_Color",
    Callback = function(newColor)
        fillColor = newColor
        for _, player in ipairs(Players:GetPlayers()) do
            ApplyHighlight(player)
        end
    end
})



local ClientSided = GeneralTab:CreateSection({
    Name = "In Viewer",
    Side = "Right"
})

-- Create GUI
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Fully dark background
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Default to hidden

-- Create Labels
local labels = {}
for i = 1, 4 do
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 5, 0, 5 + (i - 1) * 30)
    label.BackgroundTransparency = 1 -- Remove background color
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Text = "Label " .. i
    labels[i] = label
end

-- Create Line
local line = Instance.new("Frame", frame)
line.Size = UDim2.new(1, -10, 0, 2)
line.Position = UDim2.new(0, 5, 0, 35)
line.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Start with purple

-- Gradient Effect
local gradient = Instance.new("UIGradient", line)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)), -- Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) -- White
}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false -- Default to hidden
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 2
fovCircle.NumSides = 30
fovCircle.Radius = 100

local trickSpammerEnabled = false

ClientSided:AddToggle({
    Name = "Toggle",
    Flag = "INV_VIEW",
    Keybind = 1,
    Callback = function(state)
        trickSpammerEnabled = state
        frame.Visible = state
        fovCircle.Visible = state
    end
})

-- Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if not trickSpammerEnabled then return end
    
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
    
    -- Search for player data in ReplicatedStorage
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local playersFolder = replicatedStorage:FindFirstChild("Players")
    if not playersFolder then
        labels[1].Text = "No Players Folder"
        for i = 2, 4 do
            labels[i].Text = ""
        end
        return
    end

    -- Find closest player's inventory
    local closestPlayer, minDistance = nil, math.huge
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = otherPlayer.Character.HumanoidRootPart
            local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - fovCircle.Position).Magnitude
            if distance < fovCircle.Radius and distance < minDistance then
                closestPlayer = otherPlayer
                minDistance = distance
            end
        end
    end

    if closestPlayer then
        labels[1].Text = "PlayerName: " .. closestPlayer.Name
        local playerData = playersFolder:FindFirstChild(closestPlayer.Name)
        if playerData and playerData:FindFirstChild("Inventory") then
            local inventory = playerData.Inventory
            local items = {}
            for _, item in pairs(inventory:GetChildren()) do
                if item:IsA("StringValue") then
                    table.insert(items, item.Name)
                end
            end
            labels[2].Text = "Slot 1: " .. (items[1] or "None")
            labels[3].Text = "Slot 2: " .. (items[2] or "None")
            labels[4].Text = "Slot 3: " .. (items[3] or "None")
        else
            labels[2].Text, labels[3].Text, labels[4].Text = "No Inventory", "", ""
        end
    else
        labels[1].Text = "No player nearby"
        labels[2].Text, labels[3].Text, labels[4].Text = "", "", ""
    end
end)









-- Add "Sigma" tab with hydration and hunger sliders
local SigmaTab = PepsisWorld:CreateTab({
    Name = "Aimbot"
})

local SigmaSection = SigmaTab:CreateSection({
    Name = "Aimbot (locks onto nearest)"
})

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local Aiming = false
local LockKey = Enum.KeyCode.E  -- Default key to toggle aiming
local LockPart = "HumanoidRootPart"  -- Default part to lock onto
local toggleTrickSpammer = false  -- Toggle for Aimbot feature
local LockDistance = 0.15  -- Default lock distance
local FOVSize = 100  -- Default FOV Circle Size

-- Function to create and update FOV circle
local RunService = game:GetService("RunService")
local Drawing = Drawing or {} -- Ensure Drawing API exists

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0) -- Red color
FOVCircle.Thickness = 2
FOVCircle.Radius = FOVSize
FOVCircle.Filled = false
FOVCircle.Visible = false  -- Start hidden

RunService.RenderStepped:Connect(function()
    if toggleTrickSpammer then
        FOVCircle.Visible = true
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Radius = FOVSize
    else
        FOVCircle.Visible = false
    end
end)

-- Function to check if a player is inside the FOV circle
local function IsInsideFOV(target)
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToViewportPoint(target.Position)
    if not onScreen then return false end

    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
    local distance = (mousePos - targetPos).Magnitude

    return distance <= FOVSize
end

-- Function to aim lock at selected body part (Head or Torso) and within distance range
function AimLock()
    if not toggleTrickSpammer then return end  -- Exit if toggle is OFF

    local target
    local lastMagnitude = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character.PrimaryPart then
            local charPos = v.Character[LockPart].Position
            local mousePos = mouse.Hit.p
            local distance = (charPos - mousePos).Magnitude

            if distance < lastMagnitude and distance <= LockDistance and IsInsideFOV(v.Character[LockPart]) then
                lastMagnitude = distance
                target = v
            end
        end
    end

    if target and target.Character and target.Character[LockPart] then
        local charPos = target.Character[LockPart].Position
        local cam = workspace.CurrentCamera
        local pos = cam.CFrame.Position
        workspace.CurrentCamera.CFrame = CFrame.new(pos, charPos) -- Update camera orientation
    end
end

local UserInputService = game:GetService("UserInputService")

-- Toggle aiming with the set keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and toggleTrickSpammer then
        if input.KeyCode == LockKey then
            Aiming = not Aiming  -- Toggle aiming state
        end
    end
end)

-- Toggle Aimbot Feature
SigmaSection:AddToggle({
    Name = "Enable Aimbot",
    Flag = "Aimbot_Toggle",
    Keybind = 1,
    Callback = function(value)
        toggleTrickSpammer = value
        if toggleTrickSpammer then
            print("Aimbot Enabled!")
        else
            print("Aimbot Disabled!")
            Aiming = false  -- Ensure aimbot stops when disabled
        end
    end
})

-- Slider to adjust the distance required to lock onto the target
SigmaSection:AddSlider({
    Name = "Lock Distance",
    Flag = "Aimbot_LockDistance",
    Value = LockDistance,
    Precise = 2,
    Min = 0,
    Max = 500,
    Callback = function(value)
        LockDistance = value
    end
})

-- Slider to adjust FOV circle size
SigmaSection:AddSlider({
    Name = "FOV Size",
    Flag = "Aimbot_FOVSize",
    Value = FOVSize,
    Precise = 1,
    Min = 50,
    Max = 500,
    Callback = function(value)
        FOVSize = value
    end
})

-- Run AimLock only when aimbot is enabled
game:GetService("RunService").RenderStepped:Connect(function()
    if Aiming and toggleTrickSpammer then
        AimLock()
    end
end)




local GeneralTab = PepsisWorld:CreateTab({
    Name = "Random"
})

local ClientSettings = GeneralTab:CreateSection({
    Name = "Client Settings"
})

ClientSettings:AddSlider({
    Name = "Fov",
    Min = 20,
    Max = 140,
    Default = 120,
    Callback = function(value)
        local player = game.Players.LocalPlayer -- Get the local player
        local playerFolder = game.ReplicatedStorage.Players:FindFirstChild(player.Name)

        if playerFolder then
            local settings = playerFolder:FindFirstChild("Settings")
            local gameplaySettings = settings and settings:FindFirstChild("GameplaySettings")

            if gameplaySettings then
                if gameplaySettings:GetAttribute("DefaultFOV") ~= nil then
                    gameplaySettings:SetAttribute("DefaultFOV", tostring(value)) -- Store as a string
                    print("Default FOV set to: " .. tostring(value))
                else
                    warn("Attribute 'DefaultFOV' does not exist in GameplaySettings for player " .. player.Name)
                end
            else
                warn("GameplaySettings folder not found inside Settings for player " .. player.Name)
            end
        else
            warn("Player folder not found in ReplicatedStorage for player " .. player.Name)
        end
    end
})


ClientSettings:AddToggle({
    Name = "SpinBot",
    Default = false, -- Toggle starts off
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if rootPart then
            _G.Rotating = enabled -- Enable or disable rotation based on toggle
            if enabled then
                task.spawn(function()
                    while _G.Rotating do
                        task.wait(0.03) -- Smooth rotation speed
                        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(_G.RotationSpeed or 10), 0)
                    end
                end)
            end
        else
            warn("HumanoidRootPart not found for player " .. player.Name)
        end
    end
})

ClientSettings:AddSlider({
    Name = "Spin Bot Speed",
    Min = 1,
    Max = 100,
    Default = 10,
    Callback = function(value)
        _G.RotationSpeed = value
    end
})

ClientSettings:AddToggle({
    Name = "Scroll Third Person ",
    Default = false,
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        local camera = game.Workspace.CurrentCamera

        if enabled then
            -- Force third-person
            player.CameraMode = Enum.CameraMode.Classic
            camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or camera.CameraSubject
            camera.CameraType = Enum.CameraType.Custom
            player.CameraMinZoomDistance = 5 -- Forces third-person
            player.CameraMaxZoomDistance = 15 -- Allows zooming out
        else
            -- Restore default (first-person mode)
            player.CameraMode = Enum.CameraMode.LockFirstPerson
            player.CameraMinZoomDistance = 0.5
            player.CameraMaxZoomDistance = 0.5 -- Locks zoom to first-person
        end
    end
})


local ClientSided = GeneralTab:CreateSection({
    Name = "Gui",
    Side = "Right"
})

ClientSided:AddButton({
    Name = "No effects",
    Callback = function()
        -- Remove specific blur and effects from Lighting
        local lighting = game:GetService("Lighting")
        
        -- Remove BlurEffects
        local waterBlur = lighting:FindFirstChild("WaterBlur")
        if waterBlur and waterBlur:IsA("BlurEffect") then
            waterBlur:Destroy()
            print("WaterBlur removed")
        end

        local inventoryBlur = lighting:FindFirstChild("InventoryBlur")
        if inventoryBlur and inventoryBlur:IsA("BlurEffect") then
            inventoryBlur:Destroy()
            print("InventoryBlur removed")
        end

        -- Remove HurtEffect (ColorCorrectionEffect)
        local hurtEffect = lighting:FindFirstChild("HurtEffect")
        if hurtEffect and hurtEffect:IsA("ColorCorrectionEffect") then
            hurtEffect:Destroy()
            print("HurtEffect removed")
        end
    end
})

ClientSided:AddButton({
    Name = "FullBright",
    Callback = function()
        local lighting = game:GetService("Lighting")

        -- Remove Skybox
        lighting.Sky = nil
        print("Skybox removed")

        -- Remove Fog
        lighting.FogEnd = math.huge
        lighting.FogStart = 0
        lighting.FogColor = Color3.new(1, 1, 1) -- White fog (effectively no fog)
        print("Fog removed")

        -- Make the game brighter by modifying Lighting properties
        lighting.Ambient = Color3.new(1, 1, 1)  -- Bright white ambient light
        lighting.Brightness = 2  -- Adjust brightness as needed
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)  -- Set outdoor ambient light
        print("Fullbright enabled")
    end
})


ClientSided:AddButton({
    Name = "Rejoin",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer

        -- Store the current game ID (the player's current place)
        local currentGameID = game.PlaceId
        local currentJobID = game.JobId

        -- Rejoin the same game
        game:GetService("TeleportService"):TeleportToPlaceInstance(currentGameID, currentJobID, player)
        
        print("Rejoining the same game...")
    end
})



game.StarterGui:SetCore("SendNotification", {
    Title = "Script loaded",
    Text = "recommended turning off leaning! :)",
    Button1 = "yeah.",
    Button2 = "really?!!?!?!?!?!?",
    Duration = math.huge
})
