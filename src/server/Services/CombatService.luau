--[[
    CombatService.luau
    전투 계산 서비스 — 모든 피해/힐 계산은 이 서비스에서 처리
    서버 권위: 클라이언트 계산값 절대 신뢰 금지
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local DamageCalculator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DamageCalculator"))
local SkillData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SkillData"))

local CombatService = Knit.CreateService {
    Name = "CombatService",

    -- 클라이언트에 노출할 메서드/이벤트
    Client = {
        -- 클라이언트 → 서버: 스킬 사용 요청
        SkillUsed = Knit.CreateSignal(),
        -- 서버 → 클라이언트: 전투 결과 알림
        CombatResult = Knit.CreateSignal(),
    },
}

-- 쿨다운 추적 테이블: [player][skillId] = lastUsedTime
local CooldownTracker: { [Player]: { [string]: number } } = {}

-- 어그로 테이블: [instanceId][enemyId][player] = aggroValue
local AggroTable: { [string]: { [string]: { [Player]: number } } } = {}

-- ==========================================
-- 내부 헬퍼
-- ==========================================

local function getPlayerStats(player: Player): { [string]: number }
    -- TODO: ProgressionService와 연동하여 실제 스탯 반환
    return {
        AttackPower = player:GetAttribute("AttackPower") or 50,
        Defense     = player:GetAttribute("Defense") or 10,
        HealPower   = player:GetAttribute("HealPower") or 0,
        CritRate    = player:GetAttribute("CritRate") or 0.05,
        CritDamage  = player:GetAttribute("CritDamage") or 1.5,
        MaxHP       = player:GetAttribute("MaxHP") or 500,
    }
end

local function isOnCooldown(player: Player, skillId: string, cooldown: number): boolean
    local tracker = CooldownTracker[player]
    if not tracker then return false end
    local lastUsed = tracker[skillId] or 0
    return (os.clock() - lastUsed) < cooldown
end

local function recordCooldown(player: Player, skillId: string)
    if not CooldownTracker[player] then
        CooldownTracker[player] = {}
    end
    CooldownTracker[player][skillId] = os.clock()
end

-- ==========================================
-- 공개 메서드
-- ==========================================

--[[
    플레이어가 스킬 사용 요청 처리 (클라이언트 요청 → 서버 검증 → 실행)
    @param player  요청한 플레이어
    @param skillId 사용할 스킬 ID
    @param targetId 타겟 (플레이어 또는 NPC UserId/instanceId)
--]]
function CombatService:UseSkill(player: Player, skillId: string, targetId: string)
    -- 1. 스킬 존재 여부 검증
    local skill = SkillData[skillId]
    if not skill then
        warn(string.format("[CombatService] 유효하지 않은 스킬: %s (Player: %s)", skillId, player.Name))
        return
    end

    -- 2. 쿨다운 검증
    if isOnCooldown(player, skillId, skill.Cooldown) then
        return  -- 쿨다운 중 — 조용히 무시 (클라이언트 버그/핵 방지)
    end

    -- 3. 스탯 가져오기
    local stats = getPlayerStats(player)

    -- 4. 데미지/힐 계산
    local result
    if skill.IsHeal then
        local healAmount = DamageCalculator.CalculateHeal({
            HealPower      = stats.HealPower,
            SkillMultiplier = skill.Multiplier,
        })
        result = { IsHeal = true, Amount = healAmount, TargetId = targetId }
    else
        local dmgResult = DamageCalculator.Calculate({
            AttackPower     = stats.AttackPower,
            SkillMultiplier = skill.Multiplier,
            Defense         = 10,  -- TODO: 타겟의 방어력 가져오기
            CritRate        = stats.CritRate,
            CritDamage      = stats.CritDamage,
        })
        result = {
            IsHeal   = false,
            Damage   = dmgResult.Damage,
            IsCrit   = dmgResult.IsCrit,
            TargetId = targetId,
            SkillId  = skillId,
        }

        -- 어그로 누적
        self:AddAggro(player, targetId, dmgResult.Damage * (skill.AggroMultiplier or 1.0))
    end

    -- 5. 쿨다운 기록
    recordCooldown(player, skillId)

    -- 6. 결과 브로드캐스트
    self.Client.CombatResult:Fire(player, result)

    return result
end

--[[
    어그로 추가
--]]
function CombatService:AddAggro(player: Player, enemyId: string, amount: number)
    local instanceId = player:GetAttribute("CurrentInstanceId") or "default"
    if not AggroTable[instanceId] then AggroTable[instanceId] = {} end
    if not AggroTable[instanceId][enemyId] then AggroTable[instanceId][enemyId] = {} end
    local current = AggroTable[instanceId][enemyId][player] or 0
    AggroTable[instanceId][enemyId][player] = current + amount
end

--[[
    어그로 최고값 플레이어 반환 (적 타겟팅용)
--]]
function CombatService:GetHighestAggroPlayer(instanceId: string, enemyId: string): Player?
    local table_ = AggroTable[instanceId]
    if not table_ then return nil end
    local enemyAggro = table_[enemyId]
    if not enemyAggro then return nil end

    local maxAggro = 0
    local target: Player? = nil
    for player, aggro in pairs(enemyAggro) do
        if aggro > maxAggro then
            maxAggro = aggro
            target = player
        end
    end
    return target
end

--[[
    플레이어 퇴장 시 쿨다운/어그로 정리
--]]
function CombatService:CleanupPlayer(player: Player)
    CooldownTracker[player] = nil
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function CombatService:KnitInit()
    -- 클라이언트 요청 처리 연결
    self.Client.SkillUsed:Connect(function(player, skillId, targetId)
        self:UseSkill(player, skillId, targetId)
    end)

    game:GetService("Players").PlayerRemoving:Connect(function(player)
        self:CleanupPlayer(player)
    end)
end

function CombatService:KnitStart()
    print("[CombatService] 시작됨")
end

return CombatService
