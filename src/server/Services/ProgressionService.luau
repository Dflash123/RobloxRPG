--[[
    ProgressionService.luau
    레벨/경험치/DataStore 저장 서비스
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local ProgressionService = Knit.CreateService {
    Name = "ProgressionService",
    Client = {
        LeveledUp        = Knit.CreateSignal(),
        ExperienceGained = Knit.CreateSignal(),
    },
}

-- 경험치 공식 상수
local BASE_EXP     = 100
local EXP_EXPONENT = 1.8
local MAX_LEVEL    = 100

-- DataStore
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

-- ==========================================
-- 경험치/레벨 계산
-- ==========================================

--[[
    레벨업에 필요한 경험치 계산
    공식: BASE_EXP × (Level ^ EXP_EXPONENT)
--]]
function ProgressionService:GetRequiredExp(level: number): number
    return math.floor(BASE_EXP * (level ^ EXP_EXPONENT))
end

--[[
    경험치 지급 및 레벨업 처리
--]]
function ProgressionService:AddExperience(player: Player, amount: number)
    local level  = player:GetAttribute("Level") or 1
    local exp    = (player:GetAttribute("Experience") or 0) + amount

    self.Client.ExperienceGained:Fire(player, { Amount = amount })

    -- 레벨업 루프 (한 번에 여러 레벨 오를 수 있음)
    while level < MAX_LEVEL do
        local required = self:GetRequiredExp(level)
        if exp < required then break end

        exp -= required
        level += 1

        self.Client.LeveledUp:Fire(player, { NewLevel = level })
        print(string.format("[ProgressionService] %s 레벨 업: %d", player.Name, level))

        -- ClassService에 레벨업 통보 → 스탯 갱신
        -- TODO: Knit.GetService("ClassService"):OnLevelUp(player, level)
    end

    player:SetAttribute("Level", level)
    player:SetAttribute("Experience", exp)

    -- 변경 사항 저장
    task.spawn(function()
        self:SavePlayerData(player)
    end)
end

-- ==========================================
-- DataStore 저장/로드
-- ==========================================

local DEFAULT_SAVE_DATA = {
    Level       = 1,
    Experience  = 0,
    ClassId     = nil,
    Inventory   = {},
    Equipped    = {},
}

function ProgressionService:LoadPlayerData(player: Player)
    local userId = tostring(player.UserId)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync("Player_" .. userId)
    end)

    if not success then
        warn(string.format("[ProgressionService] 데이터 로드 실패: %s — %s", player.Name, data))
        data = nil
    end

    -- 기본값 병합
    local saveData = data or {}
    for key, default in pairs(DEFAULT_SAVE_DATA) do
        if saveData[key] == nil then
            saveData[key] = default
        end
    end

    -- 플레이어 속성에 적용
    player:SetAttribute("Level",      saveData.Level)
    player:SetAttribute("Experience", saveData.Experience)
    player:SetAttribute("ClassId",    saveData.ClassId)

    return saveData
end

function ProgressionService:SavePlayerData(player: Player)
    local userId = tostring(player.UserId)
    local data = {
        Level       = player:GetAttribute("Level") or 1,
        Experience  = player:GetAttribute("Experience") or 0,
        ClassId     = player:GetAttribute("ClassId"),
        -- TODO: ItemService로부터 Inventory, Equipped 가져오기
        Inventory   = {},
        Equipped    = {},
    }

    local success, err = pcall(function()
        PlayerDataStore:SetAsync("Player_" .. userId, data)
    end)

    if not success then
        warn(string.format("[ProgressionService] 저장 실패: %s — %s", player.Name, err))
    end
end

-- ==========================================
-- 클라이언트 요청
-- ==========================================

function ProgressionService.Client:GetMyLevel(player: Player)
    return {
        Level      = player:GetAttribute("Level") or 1,
        Experience = player:GetAttribute("Experience") or 0,
        Required   = ProgressionService:GetRequiredExp(player:GetAttribute("Level") or 1),
    }
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function ProgressionService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        self:LoadPlayerData(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayerData(player)
    end)

    -- 서버 종료 시 전체 저장
    game:BindToClose(function()
        for _, player in ipairs(Players:GetPlayers()) do
            self:SavePlayerData(player)
        end
    end)
end

function ProgressionService:KnitStart()
    print("[ProgressionService] 시작됨")
end

return ProgressionService
