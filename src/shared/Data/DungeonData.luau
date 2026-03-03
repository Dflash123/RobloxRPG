--[[
    DungeonData.luau
    던전 정의 데이터 테이블
    새 던전 추가: 이 파일에만 항목 추가
--]]

local DungeonData = {}

-- 난이도별 스탯 배율
DungeonData.DifficultyScale = {
    Normal  = { StatMultiplier = 1.0, RewardMultiplier = 1.0 },
    Hard    = { StatMultiplier = 1.5, RewardMultiplier = 2.0 },
    Extreme = { StatMultiplier = 2.5, RewardMultiplier = 3.5 },
    Mythic  = { StatMultiplier = 4.0, RewardMultiplier = 6.0 },
}

-- 일일 입장 제한
DungeonData.DailyLimit = {
    Normal  = math.huge,  -- 무제한
    Hard    = 10,
    Extreme = 5,
    Mythic  = 3,
}

-- ==========================================
-- 던전 정의
-- ==========================================

DungeonData["ForestOfBeginning"] = {
    DisplayName      = "시작의 숲",
    Description      = "신규 모험가를 위한 입문 던전. 숲의 수호자가 잠들어 있다.",
    RecommendedLevel = 1,
    MinLevel         = 1,
    MaxPartySize     = 4,
    BossId           = "ForestGuardian",
    TimeLimit        = 600,  -- 10분

    -- 웨이브 구성
    Waves = {
        {
            WaveNumber  = 1,
            Enemies     = {
                { EnemyId = "Slime",       Count = 5, SpawnDelay = 0  },
            },
        },
        {
            WaveNumber  = 2,
            Enemies     = {
                { EnemyId = "Slime",       Count = 3, SpawnDelay = 0  },
                { EnemyId = "GoblinArcher",Count = 2, SpawnDelay = 3  },
            },
        },
        {
            WaveNumber  = 3,
            Enemies     = {
                { EnemyId = "GoblinArcher",Count = 3, SpawnDelay = 0  },
                { EnemyId = "OrcWarrior",  Count = 2, SpawnDelay = 5  },
            },
        },
    },

    -- 난이도별 보상 테이블
    Rewards = {
        Normal  = {
            ExpReward  = 500,
            DropTable  = "Forest_Normal",
        },
        Hard    = {
            ExpReward  = 1200,
            DropTable  = "Forest_Hard",
        },
        Extreme = {
            ExpReward  = 2500,
            DropTable  = "Forest_Extreme",
        },
        Mythic  = {
            ExpReward  = 5000,
            DropTable  = "Forest_Mythic",
        },
    },

    -- 드롭 테이블 정의
    DropTables = {
        ["Forest_Normal"] = {
            { ItemId = "WoodenSword",   Weight = 40, },
            { ItemId = "LeatherArmor",  Weight = 40, },
            { ItemId = "ForestRing",    Weight = 15, },
            { ItemId = "IronSword",     Weight = 5,  },
        },
        ["Forest_Hard"] = {
            { ItemId = "IronSword",     Weight = 40, },
            { ItemId = "ChainMail",     Weight = 35, },
            { ItemId = "ForestRing",    Weight = 20, },
            { ItemId = "AncientBlade",  Weight = 5,  },
        },
        ["Forest_Extreme"] = {
            { ItemId = "ChainMail",     Weight = 30, },
            { ItemId = "AncientBlade",  Weight = 30, },
            { ItemId = "AncientPlate",  Weight = 25, },
            { ItemId = "BerserkerAmulet", Weight = 15, },
        },
        ["Forest_Mythic"] = {
            { ItemId = "AncientBlade",        Weight = 25, },
            { ItemId = "AncientPlate",        Weight = 25, },
            { ItemId = "ForestGuardianStaff", Weight = 30, },
            { ItemId = "BerserkerAmulet",     Weight = 20, },
        },
    },
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function DungeonData.Get(dungeonId: string)
    local data = DungeonData[dungeonId]
    assert(data and type(data) == "table" and data.BossId,
        string.format("[DungeonData] 존재하지 않는 던전: %s", dungeonId))
    return data
end

function DungeonData.GetDropTable(dungeonId: string, difficulty: string)
    local dungeon = DungeonData.Get(dungeonId)
    local tableKey = dungeon.Rewards[difficulty].DropTable
    return dungeon.DropTables[tableKey]
end

function DungeonData.GetAll(): { [string]: any }
    local result = {}
    for id, data in DungeonData do
        if type(data) == "table" and data.BossId then
            result[id] = data
        end
    end
    return result
end

return DungeonData
