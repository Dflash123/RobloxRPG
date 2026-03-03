--[[
    DungeonService.luau
    인스턴스 던전 생성/관리/정리 서비스
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local DungeonData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("DungeonData"))
local EnemyData   = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("EnemyData"))

local DungeonService = Knit.CreateService {
    Name = "DungeonService",
    Client = {
        -- 서버 → 클라이언트: 던전 상태 변경 알림
        DungeonStateChanged = Knit.CreateSignal(),
        -- 서버 → 클라이언트: 웨이브 시작 알림
        WaveStarted = Knit.CreateSignal(),
        -- 서버 → 클라이언트: 보스 페이즈 전환
        BossPhaseChanged = Knit.CreateSignal(),
    },
}

-- 활성 인스턴스: [instanceId] = DungeonInstance
local ActiveInstances: { [string]: any } = {}
-- 파티 → 인스턴스 매핑
local PartyInstance: { [string]: string } = {}

-- ==========================================
-- 내부 헬퍼
-- ==========================================

local function generateInstanceId(): string
    return string.format("inst_%d_%d", os.time(), math.random(10000, 99999))
end

local function notifyPartyPlayers(instance: any, event: string, data: any)
    for _, player in ipairs(instance.Players) do
        DungeonService.Client.DungeonStateChanged:Fire(player, {
            Event      = event,
            InstanceId = instance.Id,
            Data       = data,
        })
    end
end

-- ==========================================
-- 던전 생명주기
-- ==========================================

--[[
    인스턴스 생성 (파티장이 던전 시작 시 호출)
--]]
function DungeonService:CreateInstance(params: {
    PartyId    : string,
    Players    : { Player },
    DungeonId  : string,
    Difficulty : string,
})
    local dungeonData = DungeonData.Get(params.DungeonId)
    local scale = DungeonData.DifficultyScale[params.Difficulty]

    local instanceId = generateInstanceId()
    local instance = {
        Id           = instanceId,
        PartyId      = params.PartyId,
        Players      = params.Players,
        DungeonId    = params.DungeonId,
        Difficulty   = params.Difficulty,
        Scale        = scale,
        StartTime    = os.time(),
        CurrentWave  = 0,
        IsActive     = true,
        AliveEnemies = {},
        BossActive   = false,
        CurrentPhase = nil,
    }

    ActiveInstances[instanceId] = instance
    PartyInstance[params.PartyId] = instanceId

    -- 플레이어에게 인스턴스 ID 태그
    for _, player in ipairs(params.Players) do
        player:SetAttribute("CurrentInstanceId", instanceId)
    end

    print(string.format("[DungeonService] 인스턴스 생성: %s (%s %s)",
        instanceId, params.DungeonId, params.Difficulty))

    -- 던전 실행 시작
    task.spawn(function()
        self:RunDungeon(instance, dungeonData)
    end)

    return instanceId
end

--[[
    던전 실행 루프 (웨이브 → 보스 → 보상)
--]]
function DungeonService:RunDungeon(instance: any, dungeonData: any)
    notifyPartyPlayers(instance, "DungeonStarted", {
        DungeonId  = instance.DungeonId,
        Difficulty = instance.Difficulty,
    })

    -- 웨이브 처리
    for _, wave in ipairs(dungeonData.Waves) do
        if not instance.IsActive then break end

        instance.CurrentWave = wave.WaveNumber
        notifyPartyPlayers(instance, "WaveStarted", { Wave = wave.WaveNumber })

        -- TODO: 실제 몬스터 스폰 구현 (Workspace에 NPC 배치)
        for _, enemyEntry in ipairs(wave.Enemies) do
            task.wait(enemyEntry.SpawnDelay)
            local scaledStats = EnemyData.ScaleStats(
                enemyEntry.EnemyId,
                instance.Scale.StatMultiplier
            )
            -- TODO: 스폰된 NPC를 instance.AliveEnemies에 추가
            print(string.format("[DungeonService] 스폰: %s ×%d (HP: %d)",
                enemyEntry.EnemyId, enemyEntry.Count, scaledStats.MaxHP))
        end

        -- 웨이브 클리어 대기 (현재는 3초 후 자동 클리어 - TODO: 실제 구현 필요)
        task.wait(3)
    end

    -- 보스 소환
    if instance.IsActive then
        self:SpawnBoss(instance, dungeonData)
    end
end

--[[
    보스 소환
--]]
function DungeonService:SpawnBoss(instance: any, dungeonData: any)
    instance.BossActive = true
    notifyPartyPlayers(instance, "BossSpawned", { BossId = dungeonData.BossId })
    print(string.format("[DungeonService] 보스 소환: %s", dungeonData.BossId))
    -- TODO: BossService와 연동하여 보스 패턴 실행
end

--[[
    던전 클리어 처리
--]]
function DungeonService:CompleteDungeon(instanceId: string, success: boolean)
    local instance = ActiveInstances[instanceId]
    if not instance then return end

    if success then
        notifyPartyPlayers(instance, "DungeonCleared", {})
        -- TODO: ItemService/ProgressionService 연동하여 보상 분배
        print(string.format("[DungeonService] 클리어: %s", instanceId))
    else
        notifyPartyPlayers(instance, "DungeonFailed", {})
        print(string.format("[DungeonService] 실패: %s", instanceId))
    end

    self:CleanupInstance(instanceId)
end

--[[
    인스턴스 정리
--]]
function DungeonService:CleanupInstance(instanceId: string)
    local instance = ActiveInstances[instanceId]
    if not instance then return end

    -- 플레이어 속성 초기화
    for _, player in ipairs(instance.Players) do
        player:SetAttribute("CurrentInstanceId", nil)
    end

    PartyInstance[instance.PartyId] = nil
    ActiveInstances[instanceId] = nil

    print(string.format("[DungeonService] 인스턴스 정리됨: %s", instanceId))
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function DungeonService:KnitInit()
    Players.PlayerRemoving:Connect(function(player)
        -- 플레이어 퇴장 시 소속 인스턴스에서 제거
        local instanceId = player:GetAttribute("CurrentInstanceId")
        if instanceId then
            local instance = ActiveInstances[instanceId]
            if instance then
                for i, p in ipairs(instance.Players) do
                    if p == player then
                        table.remove(instance.Players, i)
                        break
                    end
                end
                if #instance.Players == 0 then
                    self:CleanupInstance(instanceId)
                end
            end
        end
    end)
end

function DungeonService:KnitStart()
    print("[DungeonService] 시작됨")
end

return DungeonService
