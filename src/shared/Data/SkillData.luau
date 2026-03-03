--[[
    SkillData.luau
    스킬 정의 데이터 테이블
    새 스킬 추가: 이 파일에만 추가
--]]

local SkillData = {}

-- ==========================================
-- 워리어 스킬
-- ==========================================

SkillData["ShieldBash"] = {
    DisplayName     = "방패 강타",
    Type            = "Active",
    Cooldown        = 8,
    MPCost          = 20,
    Multiplier      = 1.2,
    Effect          = "Stun",
    EffectDuration  = 2,
    AggroMultiplier = 3.0,
    Range           = 5,
    Description     = "방패로 강타해 2초간 기절시킨다",
}

SkillData["Taunt"] = {
    DisplayName     = "도발",
    Type            = "Active",
    Cooldown        = 12,
    MPCost          = 15,
    Multiplier      = 0,
    Effect          = "Taunt",
    EffectDuration  = 5,
    AggroMultiplier = 10.0,
    Range           = 30,
    Description     = "주변 적의 어그로를 강제로 집중시킨다",
}

SkillData["IronWall"] = {
    DisplayName     = "철벽 방어",
    Type            = "Active",
    Cooldown        = 20,
    MPCost          = 30,
    Multiplier      = 0,
    Effect          = "DefenseUp",
    EffectDuration  = 8,
    EffectValue     = 0.5,  -- 방어력 50% 증가
    AggroMultiplier = 1.0,
    Range           = 0,    -- Self
    Description     = "8초간 방어력을 50% 증가시킨다",
}

SkillData["Provoke"] = {
    DisplayName     = "격분 유도",
    Type            = "Active",
    Cooldown        = 6,
    MPCost          = 10,
    Multiplier      = 0.8,
    Effect          = "Taunt",
    EffectDuration  = 3,
    AggroMultiplier = 5.0,
    Range           = 20,
    Description     = "대상을 자극해 어그로를 높이고 공격한다",
}

-- ==========================================
-- 버서커 스킬
-- ==========================================

SkillData["FuryStrike"] = {
    DisplayName     = "분노의 일격",
    Type            = "Active",
    Cooldown        = 4,
    MPCost          = 15,
    Multiplier      = 2.5,
    Effect          = nil,
    AggroMultiplier = 1.0,
    Range           = 5,
    Description     = "강력한 일격으로 큰 피해를 입힌다",
}

SkillData["BloodRage"] = {
    DisplayName     = "피의 분노",
    Type            = "Active",
    Cooldown        = 15,
    MPCost          = 25,
    Multiplier      = 0,
    Effect          = "AttackUp",
    EffectDuration  = 10,
    EffectValue     = 0.5,  -- 공격력 50% 증가
    AggroMultiplier = 1.0,
    Range           = 0,
    Description     = "10초간 공격력이 50% 증가한다 (대신 방어력 감소)",
}

SkillData["Cleave"] = {
    DisplayName     = "대검 휩쓸기",
    Type            = "Active",
    Cooldown        = 8,
    MPCost          = 20,
    Multiplier      = 1.5,
    Effect          = nil,
    AOE             = true,
    AOERadius       = 8,
    AggroMultiplier = 1.2,
    Range           = 8,
    Description     = "전방의 모든 적에게 피해를 입힌다",
}

SkillData["BerserkMode"] = {
    DisplayName     = "광전사 모드",
    Type            = "Active",
    Cooldown        = 60,
    MPCost          = 50,
    Multiplier      = 0,
    Effect          = "Berserk",
    EffectDuration  = 15,
    EffectValue     = 1.0,  -- 공격력 2배, 방어력 0
    AggroMultiplier = 2.0,
    Range           = 0,
    Description     = "15초간 공격력 2배, 방어력 무시 상태가 된다",
}

-- ==========================================
-- 프리스트 스킬
-- ==========================================

SkillData["HolyHeal"] = {
    DisplayName     = "신성 치유",
    Type            = "Active",
    Cooldown        = 3,
    MPCost          = 20,
    Multiplier      = 1.5,  -- HealPower 기준
    IsHeal          = true,
    AggroMultiplier = 0.5,
    Range           = 30,
    Description     = "대상 한 명을 치유한다",
}

SkillData["GroupHeal"] = {
    DisplayName     = "범위 치유",
    Type            = "Active",
    Cooldown        = 12,
    MPCost          = 40,
    Multiplier      = 0.8,  -- HealPower 기준 (범위이므로 낮음)
    IsHeal          = true,
    AOE             = true,
    AOERadius       = 20,
    TargetSelf      = true,
    AggroMultiplier = 0.3,
    Range           = 0,
    Description     = "주변 파티원 전체를 치유한다",
}

SkillData["Resurrection"] = {
    DisplayName     = "부활",
    Type            = "Active",
    Cooldown        = 120,
    MPCost          = 80,
    Multiplier      = 0,
    Effect          = "Revive",
    EffectValue     = 0.3,  -- 최대 HP의 30%로 부활
    AggroMultiplier = 1.0,
    Range           = 15,
    Description     = "사망한 파티원을 HP 30%로 부활시킨다",
}

SkillData["DivineShield"] = {
    DisplayName     = "신성 보호막",
    Type            = "Active",
    Cooldown        = 25,
    MPCost          = 35,
    Multiplier      = 0,
    Effect          = "Shield",
    EffectDuration  = 6,
    EffectValue     = 0.2,  -- 최대 HP의 20% 보호막
    AggroMultiplier = 0.8,
    Range           = 30,
    Description     = "대상에게 최대 HP의 20%에 해당하는 보호막을 부여한다",
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function SkillData.Get(skillId: string)
    local data = SkillData[skillId]
    assert(data, string.format("[SkillData] 존재하지 않는 스킬: %s", skillId))
    return data
end

return SkillData
