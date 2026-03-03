--[[
    ClassData.luau
    클래스 정의 데이터 테이블
    새 클래스 추가: 이 파일에 항목 추가만 하면 됨 (코어 서비스 수정 불필요)
--]]

local ClassData = {}

-- ==========================================
-- TANK 계열
-- ==========================================

ClassData["Warrior"] = {
    DisplayName  = "워리어",
    Role         = "Tank",
    Specialization = "Shield Guardian",
    Concept      = "Iron Vanguard",
    BaseStats = {
        MaxHP       = 1000,
        Defense     = 80,
        AttackPower = 50,
        HealPower   = 0,
        Speed       = 14,
        CritRate    = 0.05,
        CritDamage  = 1.5,
    },
    -- 레벨당 스탯 증가량
    StatGrowth = {
        MaxHP       = 50,
        Defense     = 3,
        AttackPower = 2,
        HealPower   = 0,
    },
    Skills       = { "ShieldBash", "Taunt", "IronWall", "Provoke" },
    Description  = "방패를 들고 파티를 보호하는 전방 수호자",
}

-- ==========================================
-- DPS 계열
-- ==========================================

ClassData["Berserker"] = {
    DisplayName  = "버서커",
    Role         = "DPS",
    Specialization = "Rage Striker",
    Concept      = "Chaos Blade",
    BaseStats = {
        MaxHP       = 600,
        Defense     = 30,
        AttackPower = 150,
        HealPower   = 0,
        Speed       = 18,
        CritRate    = 0.10,
        CritDamage  = 2.0,
    },
    StatGrowth = {
        MaxHP       = 25,
        Defense     = 1,
        AttackPower = 8,
        HealPower   = 0,
    },
    Skills       = { "FuryStrike", "BloodRage", "Cleave", "BerserkMode" },
    Description  = "분노를 에너지로 삼아 적을 파괴하는 광전사",
}

-- ==========================================
-- HEALER 계열
-- ==========================================

ClassData["Priest"] = {
    DisplayName  = "프리스트",
    Role         = "Healer",
    Specialization = "Holy Restoration",
    Concept      = "Sacred Light",
    BaseStats = {
        MaxHP       = 500,
        Defense     = 20,
        AttackPower = 30,
        HealPower   = 120,
        Speed       = 15,
        CritRate    = 0.05,
        CritDamage  = 1.5,
    },
    StatGrowth = {
        MaxHP       = 20,
        Defense     = 1,
        AttackPower = 1,
        HealPower   = 6,
    },
    Skills       = { "HolyHeal", "GroupHeal", "Resurrection", "DivineShield" },
    Description  = "신성한 힘으로 아군을 치유하고 보호하는 사제",
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function ClassData.Get(classId: string)
    local data = ClassData[classId]
    assert(data, string.format("[ClassData] 존재하지 않는 클래스: %s", classId))
    return data
end

function ClassData.GetAll(): { [string]: any }
    local result = {}
    for id, data in ClassData do
        if type(data) == "table" and data.Role then
            result[id] = data
        end
    end
    return result
end

function ClassData.GetByRole(role: string): { [string]: any }
    local result = {}
    for id, data in ClassData do
        if type(data) == "table" and data.Role == role then
            result[id] = data
        end
    end
    return result
end

return ClassData
