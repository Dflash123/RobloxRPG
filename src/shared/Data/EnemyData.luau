--[[
    EnemyData.luau
    일반 몬스터 정의 데이터 테이블
--]]

local EnemyData = {}

-- ==========================================
-- 숲 지역 몬스터
-- ==========================================

EnemyData["Slime"] = {
    DisplayName    = "슬라임",
    BaseHP         = 80,
    BaseAtk        = 10,
    BaseDef        = 5,
    MoveSpeed      = 8,
    AggroRange     = 20,
    AttackRange    = 4,
    AttackCooldown = 2.0,
    Patterns       = { "BasicAttack" },
    ExpReward      = 10,
    DropChance     = 0.3,
    Description    = "물렁물렁한 젤리 같은 몬스터. 독을 품고 있다",
}

EnemyData["GoblinArcher"] = {
    DisplayName    = "고블린 궁수",
    BaseHP         = 120,
    BaseAtk        = 25,
    BaseDef        = 8,
    MoveSpeed      = 12,
    AggroRange     = 40,
    AttackRange    = 30,  -- 원거리
    AttackCooldown = 2.5,
    Patterns       = { "BasicAttack", "QuickShot" },
    ExpReward      = 20,
    DropChance     = 0.4,
    Description    = "활을 들고 원거리에서 공격하는 교활한 고블린",
}

EnemyData["OrcWarrior"] = {
    DisplayName    = "오크 전사",
    BaseHP         = 350,
    BaseAtk        = 45,
    BaseDef        = 20,
    MoveSpeed      = 10,
    AggroRange     = 25,
    AttackRange    = 5,
    AttackCooldown = 2.0,
    Patterns       = { "BasicAttack", "ChargeAttack" },
    ExpReward      = 40,
    DropChance     = 0.5,
    Description    = "강인한 체력과 힘을 가진 오크 전사",
}

EnemyData["ForestWolf"] = {
    DisplayName    = "숲의 늑대",
    BaseHP         = 200,
    BaseAtk        = 35,
    BaseDef        = 12,
    MoveSpeed      = 20,  -- 빠름
    AggroRange     = 35,
    AttackRange    = 5,
    AttackCooldown = 1.5,
    Patterns       = { "BasicAttack", "Pounce" },
    ExpReward      = 30,
    DropChance     = 0.45,
    Description    = "숲 속을 빠르게 누비는 사나운 늑대",
}

-- ==========================================
-- 몬스터 패턴 정의
-- ==========================================

EnemyData.Patterns = {
    ["BasicAttack"] = {
        Multiplier = 1.0,
        Range = nil,  -- 기본 AttackRange 사용
    },
    ["QuickShot"] = {
        Multiplier = 0.8,
        ExtraAttacks = 2,
        Cooldown = 5,
    },
    ["ChargeAttack"] = {
        Multiplier = 2.0,
        Cooldown = 10,
        Effect = "Knockback",
    },
    ["Pounce"] = {
        Multiplier = 1.5,
        Cooldown = 8,
        Effect = "Stun",
        EffectDuration = 1,
    },
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function EnemyData.Get(enemyId: string)
    local data = EnemyData[enemyId]
    assert(data and type(data) == "table" and data.BaseHP,
        string.format("[EnemyData] 존재하지 않는 적: %s", enemyId))
    return data
end

function EnemyData.ScaleStats(enemyId: string, multiplier: number): { [string]: number }
    local base = EnemyData.Get(enemyId)
    return {
        MaxHP   = math.floor(base.BaseHP  * multiplier),
        Atk     = math.floor(base.BaseAtk * multiplier),
        Def     = math.floor(base.BaseDef * multiplier),
    }
end

return EnemyData
