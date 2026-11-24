
-- KING CRIMSON - DELETE TIME
-- ServerScriptService > KingCrimsonServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("KingCrimsonEvent")

if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "KingCrimsonEvent"
    remote.Parent = ReplicatedStorage
end

local active = {}

local function createEcho(character)
    local oldArchivable = character.Archivable
    character.Archivable = true

    local echo = character:Clone()
    character.Archivable = oldArchivable

    if not echo then
        return nil
    end

    echo.Name = "KingCrimsonEcho"

    for _, obj in ipairs(echo:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()

        elseif obj:IsA("BasePart") then
            obj.Anchored = true
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.Massless = true
            obj.Transparency = math.max(obj.Transparency, 0.3)
            obj.Material = Enum.Material.ForceField

        elseif obj:IsA("Humanoid") then
            obj.DisplayDistanceType =
                Enum.HumanoidDisplayDistanceType.None
            obj.HealthDisplayType =
                Enum.HumanoidHealthDisplayType.AlwaysOff
        end
    end

    echo.Parent = workspace
    return echo
end

local function endDeleteTime(player)
    local echo = active[player]

    if not echo then
        return
    end

    active[player] = nil

    if echo.Parent then
        echo:Destroy()
    end

    remote:FireAllClients("Show", player)
    remote:FireClient(player, "State", false)
end

remote.OnServerEvent:Connect(function(player, action)
    if action == "Delete" then
        if active[player] then
            return
        end

        local character = player.Character
        if not character then
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 or not root then
            return
        end

        local echo = createEcho(character)
        if not echo then
            return
        end

        active[player] = echo

        -- Ẩn nhân vật thật đối với những người chơi khác
        remote:FireAllClients("Hide", player)

        -- Xác nhận trạng thái cho người kích hoạt
        remote:FireClient(player, "State", true)

    elseif action == "Back" then
        if active[player] then
            endDeleteTime(player)
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if active[player] then
            endDeleteTime(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if active[player] then
        active[player]:Destroy()
        active[player] = nil
    end
end)
