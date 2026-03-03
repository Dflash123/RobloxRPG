--[[
    DropGenerator.luau
    아이템 드롭 및 랜덤 옵션 생성 모듈
    서버에서만 호출 — 결과를 클라이언트로 전달
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemData  = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("ItemData"))

local DropGenerator = {}

-- 랜덤 옵션 타입 목록 (Weapon/Armor/Accessory 공통)
local OPTION_TYPES = {
    "AttackPower",
    "Defense",
    "MaxHP",
    "CritRate",
    "CritDamage",
    "CooldownReduction",
    "HealPower",
    "Speed",
}

-- 옵션 타입별 수치 소수점 여부
local OPTION_IS_PERCENT = {
    CritRate           = true,
    CritDamage         = true,
    CooldownReduction  = true,
}

--[[
    드롭 테이블에서 아이템 하나 선택 (가중치 기반)
    @param dropTable  { { ItemId: string, Weight: number } }
    @return string | nil  선택된 ItemId
--]]
function DropGenerator.RollDrop(dropTable: { { ItemId: string, Weight: number } }): string?
    if not dropTable or #dropTable == 0 then return nil end

    local totalWeight = 0
    for _, entry in ipairs(dropTable) do
        totalWeight += entry.Weight
    end

    local roll = math.random() * totalWeight
    local accumulated = 0
    for _, entry in ipairs(dropTable) do
        accumulated += entry.Weight
        if roll <= accumulated then
            return entry.ItemId
        end
    end

    return dropTable[#dropTable].ItemId
end

--[[
    아이템 인스턴스 생성 (드롭 시 서버에서 호출)
    @param itemId   string
    @return table   Item 인스턴스 (Types.Item 형태)
--]]
function DropGenerator.CreateItemInstance(itemId: string)
    local baseData = ItemData.Get(itemId)
    local rarity   = baseData.Rarity

    -- 랜덤 옵션 생성
    local optionCount  = ItemData.OptionCountByRarity[rarity] or 0
    local randomOptions = DropGenerator.GenerateRandomOptions(rarity, optionCount)

    return {
        InstanceId    = DropGenerator.GenerateId(),
        ItemId        = itemId,
        Name          = baseData.DisplayName,
        Type          = baseData.Type,
        Rarity        = rarity,
        Enhancement   = 0,
        BaseStats     = baseData.BaseStats,
        RandomOptions = randomOptions,
        SetID         = baseData.SetID,
    }
end

--[[
    랜덤 옵션 생성
    @param rarity  string
    @param count   number
    @return { { Type: string, Value: number } }
--]]
function DropGenerator.GenerateRandomOptions(rarity: string, count: number)
    if count <= 0 then return {} end

    local range   = ItemData.OptionValueRange[rarity]
    local options = {}
    local used    = {}

    for _ = 1, count do
        -- 중복 옵션 방지
        local optionType
        local attempts = 0
        repeat
            optionType = OPTION_TYPES[math.random(1, #OPTION_TYPES)]
            attempts += 1
        until not used[optionType] or attempts > 20

        used[optionType] = true

        -- 수치 계산
        local value
        if OPTION_IS_PERCENT[optionType] then
            -- % 계산 (0.01 단위)
            value = math.random(range.min, range.max) * 0.01
            value = math.floor(value * 100) / 100  -- 소수 2자리
        else
            value = math.random(range.min, range.max)
        end

        table.insert(options, { Type = optionType, Value = value })
    end

    return options
end

--[[
    강화 스탯 보너스 계산
    @param baseStats  { [string]: number }
    @param enhancement  number  (+0 ~ +15)
    @param rarity  string
    @return { [string]: number }
--]]
function DropGenerator.CalculateEnhancementBonus(
    baseStats: { [string]: number },
    enhancement: number,
    rarity: string
): { [string]: number }

    if enhancement <= 0 then return {} end

    -- 등급별 강화 보너스 배율 (강화 수치당 기본 스탯의 x%)
    local bonusRatePerStep = {
        Common    = 0.05,
        Rare      = 0.07,
        Epic      = 0.09,
        Legendary = 0.11,
        Mythic    = 0.14,
    }
    local rate = bonusRatePerStep[rarity] or 0.05

    local bonus = {}
    for stat, baseValue in pairs(baseStats) do
        bonus[stat] = math.floor(baseValue * rate * enhancement)
    end
    return bonus
end

--[[
    고유 아이템 인스턴스 ID 생성
--]]
function DropGenerator.GenerateId(): string
    return string.format("%d_%d", os.time(), math.random(10000, 99999))
end

return DropGenerator
