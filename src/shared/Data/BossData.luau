--[[
    BossData.luau
    보스 정의 및 패턴 데이터 테이블
    새 보스 추가: 이 파일에만 항목 추가
--]]

local BossData = {}

-- ==========================================
-- 보스 패턴 정의
-- ==========================================

BossData.Patterns = {

    ["BasicSlash"] = {
        DisplayName  = "기본 베기",
        Multiplier   = 1.2,
        Cooldown     = 3,
        AOE          = false,
        RequiresRole = nil,
        TimeLimit    = nil,
        DPSCheck     = nil,
        OnFail       = nil,
    },

    ["RootedStomp"] = {
        DisplayName  = "지면 강타",
        Multiplier   = 1.8,
        Cooldown     = 8,
        AOE          = true,
        AOERadius    = 15,
        RequiresRole = nil,
        Effect       = "Slow",
        EffectDuration = 3,
        OnFail       = nil,
    },

    ["VineWhip"] = {
        DisplayName  = "덩굴 채찍",
        Multiplier   = 1.5,
        Cooldown     = 6,
        AOE          = false,
        Effect       = "Stun",
        EffectDuration = 2,
        RequiresRole = nil,
        OnFail       = nil,
    },

    ["TankBuster"] = {
        DisplayName  = "탱크 버스터",
        Multiplier   = 5.0,
        Cooldown     = 0,  -- 패턴 트리거로만 발동
        AOE          = false,
        RequiresRole = "Tank",  -- 탱커가 정면에 없으면 전체 피해
        TimeLimit    = nil,
        DPSCheck     = nil,
        OnFail       = "GroupDamage",
        OnFailValue  = 0.8,  -- 최대 HP의 80% 피해
        Description  = "탱커가 정면에서 받아야 함. 실패 시 파티 전체 80% 피해",
    },

    ["DPSRace"] = {
        DisplayName  = "DPS 체크",
        Multiplier   = 0,
        Cooldown     = 0,
        AOE          = false,
        RequiresRole = nil,
        TimeLimit    = 15,
        DPSCheck     = 80000,
        OnFail       = "Wipe",
        Description  = "방어막 발동. 15초 내 8만 딜 미달 시 파티 전멸",
    },

    ["HealerCheck"] = {
        DisplayName  = "힐러 체크",
        Multiplier   = 0,
        Cooldown     = 0,
        AOE          = false,
        RequiresRole = "Healer",
        TimeLimit    = 8,
        DPSCheck     = nil,
        OnFail       = "Wipe",
        Description  = "생명 흡수 발동. 8초 내 힐러가 해제 미처리 시 전멸",
    },

    ["Enrage"] = {
        DisplayName  = "분노 상태",
        Multiplier   = 2.0,  -- 공격력 2배
        Cooldown     = 0,
        IsPassiveBuff = true,
        RequiresRole = nil,
        OnFail       = nil,
    },

    ["DeathBlow"] = {
        DisplayName  = "사망의 일격",
        Multiplier   = 99,  -- 즉사기
        Cooldown     = 0,
        AOE          = true,
        AOERadius    = 100,
        RequiresRole = nil,
        TimeLimit    = nil,
        OnFail       = "Wipe",
        Description  = "Mythic 전용. 특정 조건 달성 실패 시 발동",
    },
}

-- ==========================================
-- 보스 정의
-- ==========================================

BossData["ForestGuardian"] = {
    DisplayName = "숲의 수호자",
    Description = "수백 년간 숲을 지켜온 고대 정령. 외부 침입자를 용납하지 않는다",
    BaseHP      = 50000,
    BaseAtk     = 200,
    BaseDef     = 80,

    -- 난이도별 스탯 배율
    Scale = {
        Normal  = 1.0,
        Hard    = 1.5,
        Extreme = 2.5,
        Mythic  = 4.0,
    },

    -- 페이즈 정의 (HPThreshold: 해당 HP% 이하 시 전환)
    Phases = {
        {
            PhaseName    = "Phase1",
            HPThreshold  = 1.0,
            Patterns     = { "BasicSlash", "RootedStomp" },
            ActiveDiffs  = { "Normal", "Hard", "Extreme", "Mythic" },
        },
        {
            PhaseName    = "Phase2",
            HPThreshold  = 0.7,
            Patterns     = { "BasicSlash", "RootedStomp", "VineWhip" },
            ActiveDiffs  = { "Hard", "Extreme", "Mythic" },
        },
        {
            PhaseName    = "Phase3",
            HPThreshold  = 0.4,
            Patterns     = { "Enrage", "VineWhip", "TankBuster", "DPSRace" },
            ActiveDiffs  = { "Extreme", "Mythic" },
        },
        {
            PhaseName    = "Phase4",
            HPThreshold  = 0.15,
            Patterns     = { "Enrage", "HealerCheck", "DeathBlow" },
            ActiveDiffs  = { "Mythic" },
        },
    },

    ExpReward = 2000,
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function BossData.Get(bossId: string)
    local data = BossData[bossId]
    assert(data and type(data) == "table" and data.BaseHP,
        string.format("[BossData] 존재하지 않는 보스: %s", bossId))
    return data
end

function BossData.GetPattern(patternName: string)
    local data = BossData.Patterns[patternName]
    assert(data, string.format("[BossData] 존재하지 않는 패턴: %s", patternName))
    return data
end

function BossData.GetScaledHP(bossId: string, difficulty: string): number
    local boss = BossData.Get(bossId)
    return math.floor(boss.BaseHP * boss.Scale[difficulty])
end

function BossData.GetActivePhases(bossId: string, difficulty: string): { any }
    local boss = BossData.Get(bossId)
    local activePhases = {}
    for _, phase in ipairs(boss.Phases) do
        for _, diff in ipairs(phase.ActiveDiffs) do
            if diff == difficulty then
                table.insert(activePhases, phase)
                break
            end
        end
    end
    return activePhases
end

return BossData
