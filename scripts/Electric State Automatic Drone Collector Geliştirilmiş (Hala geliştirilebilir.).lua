local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local dronesFolder = Workspace:WaitForChild("Drones")
local buildingsFolder = Workspace:WaitForChild("Buildings")

-- **Toggle Mekanizması**
_G.AutoDrone = not _G.AutoDrone

-- **Öncelikli Oyuncular Listesi**
local priorityPlayers = {"Player1", "Player2", "Player3"} -- Öncelikli oyuncuların isimlerini buraya ekleyin.

-- **Drone İstasyonu Bulma**
local function findScavengeStation()
    -- Yerel oyuncunun istasyonu varsa öncelikli olarak onu kullan
    local localPlayerStation = buildingsFolder:FindFirstChild(player.Name)
    if localPlayerStation and localPlayerStation:FindFirstChild("Scavenge Station") then
        return localPlayerStation:FindFirstChild("Scavenge Station")
    end

    -- Öncelikli oyuncuların istasyonlarını kontrol et
    for _, building in pairs(buildingsFolder:GetChildren()) do
        if table.find(priorityPlayers, building.Name) then
            local scavStation = building:FindFirstChild("Scavenge Station")
            if scavStation then
                return scavStation
            end
        end
    end

    -- Diğer istasyonları kontrol et
    for _, building in pairs(buildingsFolder:GetChildren()) do
        if building.Name ~= player.Name then
            local scavStation = building:FindFirstChild("Scavenge Station")
            if scavStation then
                return scavStation
            end
        end
    end

    return nil
end

-- **GUI Oluşturma**
local function createGUI()
    local screenGui = Instance.new("ScreenGui", player.PlayerGui)
    screenGui.Name = "AutoDroneGUI"

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Draggable = true
    frame.Active = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "Auto Drone System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20

    local droneCountLabel = Instance.new("TextLabel", frame)
    droneCountLabel.Size = UDim2.new(1, 0, 0.2, 0)
    droneCountLabel.Position = UDim2.new(0, 0, 0.2, 0)
    droneCountLabel.BackgroundTransparency = 1
    droneCountLabel.Text = "Drone Count: 0"
    droneCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    droneCountLabel.Font = Enum.Font.SourceSans
    droneCountLabel.TextSize = 16

    local cooldownLabel = Instance.new("TextLabel", frame)
    cooldownLabel.Size = UDim2.new(1, 0, 0.2, 0)
    cooldownLabel.Position = UDim2.new(0, 0, 0.4, 0)
    cooldownLabel.BackgroundTransparency = 1
    cooldownLabel.Text = "Cooldown: Ready"
    cooldownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    cooldownLabel.Font = Enum.Font.SourceSans
    cooldownLabel.TextSize = 16

    local toggleButton = Instance.new("TextButton", frame)
    toggleButton.Size = UDim2.new(0.5, 0, 0.2, 0)
    toggleButton.Position = UDim2.new(0.25, 0, 0.7, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.Text = "Stop"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 16

    toggleButton.MouseButton1Click:Connect(function()
        _G.AutoDrone = false
        screenGui:Destroy()
        print("AutoDrone Durduruldu!")
    end)

    return droneCountLabel, cooldownLabel
end

-- **Otomasyon Döngüsü**
if _G.AutoDrone then
    print("AutoDrone Başladı!")
    local droneCount = 0
    local droneCountLabel, cooldownLabel = createGUI()

    while _G.AutoDrone do
        local scavStation = findScavengeStation()
        if scavStation then
            local timerOnThing = player.PlayerGui.Client.Drone.Slots.Amt.Text
            if timerOnThing == "Ready" then
                droneCount += 1
                droneCountLabel.Text = "Drone Count: " .. droneCount

                -- Drone üretimi ve işlemleri
                local cFrameRn = player.Character.HumanoidRootPart.CFrame
                local controls = require(player.PlayerScripts.PlayerModule):GetControls()
                controls:Disable()

                -- Drone istasyonuna git
                local tween = TweenService:Create(player.Character.HumanoidRootPart, TweenInfo.new(2), {CFrame = scavStation.Union.CFrame})
                tween:Play()
                tween.Completed:Wait()

                -- Drone istasyonuna 10 birim yakınındayken drone'u ateşle
                local distance = (player.Character.HumanoidRootPart.Position - scavStation.Union.Position).Magnitude
                if distance <= 10 then
                    -- Drone istasyonuna etkileşim başlat
                    ReplicatedStorage.Events.InteractEvent:FireServer(scavStation)
                    task.wait(1)

                    -- Drone'u çalıştır
                    ReplicatedStorage.Events.MenuAcitonEvent:FireServer(1, scavStation) -- Buradaki "1" parametresi drone'u çalıştırmak için gerekli
                    task.wait(1)
                end

                -- Kutu işlemleri
                local targetPart = Workspace:FindFirstChild("DroneShipment"):FindFirstChild("MeshPart")
                if targetPart then
                    local drone = dronesFolder:FindFirstChild(player.Name)
                    if drone then
                        local hull = drone:FindFirstChild("Hull")
                        if hull then
                            -- Kutunun olduğu yere git
                            local CFrameEnd = targetPart.CFrame
                            local tween = TweenService:Create(hull, TweenInfo.new(2), {CFrame = CFrameEnd})
                            tween:Play()
                            tween.Completed:Wait()

                            -- Kutuyu al
                            task.wait(2)
                            ReplicatedStorage.Events.MenuAcitonEvent:FireServer(3) -- Kutuyu alma işlemi
                            task.wait(1)

                            -- Drone'u geri istasyona götür
                            hull.CFrame = scavStation.Union.CFrame
                            task.wait(1)

                            -- Kutuyu teslim et
                            ReplicatedStorage.Events.MenuAcitonEvent:FireServer(4) -- Kutuyu teslim etme işlemi
                            task.wait(1)

                            -- Drone istasyonuna etkileşim başlat
                            ReplicatedStorage.Events.InteractEvent:FireServer(scavStation)
                        end
                    end
                end

                controls:Enable()
            else
                cooldownLabel.Text = "Cooldown: " .. timerOnThing
            end
        else
            print("Scavenge Station bulunamadı!")
        end

        -- GUI'yi saniyede bir güncelle
        task.wait(1)
    end
else
    print("AutoDrone Durduruldu!")
end