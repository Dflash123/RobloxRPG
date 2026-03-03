--[[
    ItemData.luau
    아이템 기본 정의 테이블
    인스턴스별 RandomOptions는 드롭 시 DropGenerator에서 생성
--]]

local ItemData = {}

-- 등급별 랜덤 옵션 개수
ItemData.OptionCountByRarity = {
    Common    = 0,
    Rare      = 1,
    Epic      = 2,
    Legendary = 3,
    Mythic    = 4,
}

-- 랜덤 옵션 수치 범위 (등급별)
ItemData.OptionValueRange = {
    Common    = { min = 0,   max = 0   },
    Rare      = { min = 5,   max = 15  },
    Epic      = { min = 10,  max = 30  },
    Legendary = { min = 20,  max = 50  },
    Mythic    = { min = 35,  max = 80  },
}

-- ==========================================
-- 무기 (Weapon)
-- ==========================================

ItemData["WoodenSword"] = {
    DisplayName   = "나무 검",
    Type          = "Weapon",
    Rarity        = "Common",
    SetID         = nil,
    BaseStats     = { AttackPower = 20 },
    AllowedRoles  = nil,  -- nil = 모두 착용 가능
    RequiredLevel = 1,
    Description   = "초보 모험가를 위한 기본 무기",
}

ItemData["IronSword"] = {
    DisplayName   = "철 검",
    Type          = "Weapon",
    Rarity        = "Rare",
    SetID         = nil,
    BaseStats     = { AttackPower = 60, CritRate = 0.03 },
    AllowedRoles  = nil,
    RequiredLevel = 5,
    Description   = "단단한 철로 만들어진 신뢰할 수 있는 검",
}

ItemData["AncientBlade"] = {
    DisplayName   = "고대의 검",
    Type          = "Weapon",
    Rarity        = "Epic",
    SetID         = "AncientSet",
    BaseStats     = { AttackPower = 150, CritRate = 0.05 },
    AllowedRoles  = { "DPS" },
    RequiredLevel = 20,
    Description   = "고대 문명의 기술로 제련된 전설의 무기",
}

ItemData["ForestGuardianStaff"] = {
    DisplayName   = "숲의 수호자 지팡이",
    Type          = "Weapon",
    Rarity        = "Legendary",
    SetID         = "ForestSet",
    BaseStats     = { HealPower = 200, AttackPower = 40 },
    AllowedRoles  = { "Healer" },
    RequiredLevel = 30,
    Description   = "숲의 정령으로부터 축복받은 신성한 지팡이",
}

-- ==========================================
-- 방어구 (Armor)
-- ==========================================

ItemData["LeatherArmor"] = {
    DisplayName   = "가죽 갑옷",
    Type          = "Armor",
    Rarity        = "Common",
    SetID         = nil,
    BaseStats     = { Defense = 15, MaxHP = 50 },
    AllowedRoles  = nil,
    RequiredLevel = 1,
    Description   = "가벼운 가죽으로 만들어진 기본 방어구",
}

ItemData["ChainMail"] = {
    DisplayName   = "사슬 갑옷",
    Type          = "Armor",
    Rarity        = "Rare",
    SetID         = nil,
    BaseStats     = { Defense = 45, MaxHP = 150 },
    AllowedRoles  = { "Tank" },
    RequiredLevel = 5,
    Description   = "단단한 사슬로 엮어 만든 방어구",
}

ItemData["AncientPlate"] = {
    DisplayName   = "고대의 판금 갑옷",
    Type          = "Armor",
    Rarity        = "Epic",
    SetID         = "AncientSet",
    BaseStats     = { Defense = 120, MaxHP = 500 },
    AllowedRoles  = { "Tank" },
    RequiredLevel = 20,
    Description   = "고대 기술로 제련된 최고급 판금 갑옷",
}

-- ==========================================
-- 장신구 (Accessory)
-- ==========================================

ItemData["ForestRing"] = {
    DisplayName   = "숲의 반지",
    Type          = "Accessory",
    Rarity        = "Rare",
    SetID         = "ForestSet",
    BaseStats     = { MaxHP = 80, Defense = 10 },
    AllowedRoles  = nil,
    RequiredLevel = 5,
    Description   = "숲의 기운이 깃든 초록빛 반지",
}

ItemData["BerserkerAmulet"] = {
    DisplayName   = "광전사의 부적",
    Type          = "Accessory",
    Rarity        = "Epic",
    SetID         = nil,
    BaseStats     = { AttackPower = 50, CritRate = 0.08, CritDamage = 0.3 },
    AllowedRoles  = { "DPS" },
    RequiredLevel = 15,
    Description   = "전투의 열기를 불러일으키는 붉은 부적",
}

-- ==========================================
-- 세트 정의
-- ==========================================

ItemData.Sets = {
    ["AncientSet"] = {
        DisplayName = "고대의 세트",
        Items = { "AncientBlade", "AncientPlate" },
        Bonuses = {
            [2] = { AttackPower = 50, Description = "2세트: 공격력 +50" },
        },
    },
    ["ForestSet"] = {
        DisplayName = "숲의 세트",
        Items = { "ForestGuardianStaff", "ForestRing" },
        Bonuses = {
            [2] = { HealPower = 60, MaxHP = 200, Description = "2세트: 치유력 +60, 최대 HP +200" },
        },
    },
}

-- ==========================================
-- 유틸리티 함수
-- ==========================================

function ItemData.Get(itemId: string)
    local data = ItemData[itemId]
    assert(data and type(data) == "table" and data.Type,
        string.format("[ItemData] 존재하지 않는 아이템: %s", itemId))
    return data
end

function ItemData.GetSetBonus(setId: string, count: number)
    local setData = ItemData.Sets[setId]
    if not setData then return nil end
    return setData.Bonuses[count]
end

return ItemData
