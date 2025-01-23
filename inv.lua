local success, err = pcall(function()
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()

    -- Create GUI elements
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVGui"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Create circular UI container
    local fovCircleFrame = Instance.new("Frame")
    fovCircleFrame.Size = UDim2.new(0, 150, 0, 150)  -- Size of the circular UI
    fovCircleFrame.Position = UDim2.new(0.75, 0, 0.05, 0)  -- Positioned at the top-right
    fovCircleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fovCircleFrame.BackgroundTransparency = 0.5
    fovCircleFrame.BorderSizePixel = 0
    fovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircleFrame.Parent = screenGui

    -- Make the frame circular
    local fovCircleMask = Instance.new("UICorner")
    fovCircleMask.CornerRadius = UDim.new(0.5, 0)  -- This makes the frame a circle
    fovCircleMask.Parent = fovCircleFrame

    -- Create labels inside the circle
    local textLabels = {}

    -- Label 1: Player's Name
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    playerNameLabel.Position = UDim2.new(0, 0, 0, 0)
    playerNameLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerNameLabel.TextSize = 10  -- Smaller text size
    playerNameLabel.Text = "Player: " .. player.Name  -- Displaying player's name
    playerNameLabel.TextStrokeTransparency = 1  -- Removing text outline
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    playerNameLabel.TextYAlignment = Enum.TextYAlignment.Center
    playerNameLabel.Parent = fovCircleFrame
    table.insert(textLabels, playerNameLabel)

    -- Labels 2-4: Items from the player's inventory
    for i = 2, 4 do
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 0.25, 0)
        textLabel.Position = UDim2.new(0, 0, (i - 1) * 0.25, 0)
        textLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextSize = 10  -- Smaller text size
        textLabel.Text = "Item " .. (i - 1)  -- Placeholder for item labels
        textLabel.TextStrokeTransparency = 1  -- Removing text outline
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Parent = fovCircleFrame
        table.insert(textLabels, textLabel)
    end

    -- Create FOV Circle (for actual detection)
    local fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, 150, 0, 150)  -- Made the FOV circle smaller
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.BackgroundTransparency = 0.5
    fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = screenGui

    local function updateFOVCircle()
        fovCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    end

    -- Detect players inside the FOV circle
    local function isPlayerInFOV(targetPlayer)
        local character = targetPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                local distance = ((Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude)
                return distance <= fovCircle.AbsoluteSize.X / 2
            end
        end
        return false
    end

    -- Update text labels with player inventory
    local function updateTextLabels(targetPlayer)
        local inventory = ReplicatedStorage:FindFirstChild("Players")
        if inventory and inventory:FindFirstChild(targetPlayer.Name) then
            local playerInventory = inventory[targetPlayer.Name]:FindFirstChild("Inventory")
            if playerInventory then
                local stringValues = playerInventory:GetChildren()
                for i = 2, 4 do  -- Update labels 2-4 with items
                    if stringValues[i - 1] and stringValues[i - 1]:IsA("StringValue") then
                        textLabels[i].Text = stringValues[i - 1].Name .. " - " .. stringValues[i - 1].Value
                    else
                        textLabels[i].Text = "[Empty]"
                    end
                end
            end
        end
    end

    -- Run updates
    mouse.Move:Connect(updateFOVCircle)
    RunService.RenderStepped:Connect(function()
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and isPlayerInFOV(otherPlayer) then
                textLabels[1].Text = "Player: " .. otherPlayer.Name  -- Update player's name
                updateTextLabels(otherPlayer)
                break
            end
        end
    end)
end)

if not success then
    warn("Error executing script: " .. tostring(err))
end
