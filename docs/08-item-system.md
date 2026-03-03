# 아이템 시스템 (Item System)

## 등급 체계

```
Common (회색)
   ↓ 기본 스탯만 존재
Rare (파랑)
   ↓ + 랜덤 옵션 1개
Epic (보라)
   ↓ + 랜덤 옵션 2개
Legendary (주황)
   ↓ + 랜덤 옵션 3개, 세트 아이템 가능
Mythic (빨강)
      + 랜덤 옵션 4개, 특수 외형, 세트 아이템
```

## 아이템 구조

```lua
Item = {
    InstanceId    = "uuid",           -- 아이템 인스턴스 고유 ID
    ItemId        = "AncientBlade",   -- 아이템 종류 ID (ItemData 참조)
    Name          = "고대의 검",
    Type          = "Weapon",         -- Weapon / Armor / Accessory
    Rarity        = "Epic",
    Enhancement   = 0,                -- 강화 수치 (+0 ~ +15)
    BaseStats     = {
        AttackPower = 150,
        CritRate    = 5,
    },
    RandomOptions = {
        { Type="CritDamage", Value=12.5 },
        { Type="AttackPower", Value=30  },
    },
    SetID         = "AncientSet",     -- nil이면 세트 아이템 아님
}
```

## 아이템 데이터 (ItemData)

아이템의 **기본 정보와 베이스 스탯**을 정의합니다.
인스턴스별 랜덤 옵션은 드롭 시 서버에서 생성됩니다.

```lua
ItemData["AncientBlade"] = {
    Name     = "고대의 검",
    Type     = "Weapon",
    Rarity   = "Epic",
    SetID    = "AncientSet",
    BaseStats = {
        AttackPower = 150,
        CritRate    = 5,
    },
    AllowedRoles = { "DPS" },    -- 착용 가능 역할 (nil = 모두)
    RequiredLevel = 20,
}
```

## 랜덤 옵션 생성

```lua
-- ItemService.GenerateRandomOptions(rarity)
function GenerateRandomOptions(rarity)
    local count = OptionCountByRarity[rarity]  -- 등급별 개수
    local options = {}
    local usedTypes = {}

    for i = 1, count do
        local optionType = PickRandomOptionType(usedTypes)  -- 중복 방지
        local value = CalculateOptionValue(optionType, rarity)
        table.insert(options, { Type=optionType, Value=value })
        usedTypes[optionType] = true
    end

    return options
end
```

## 세트 아이템

```lua
SetData["AncientSet"] = {
    Name  = "고대의 세트",
    Items = { "AncientBlade", "AncientArmor", "AncientRing" },
    Bonuses = {
        [2] = { AttackPower=50, Description="2세트: 공격력 +50" },
        [3] = { AttackPower=100, CritDamage=20, Description="3세트: 공격력 +100, 치명타 피해 +20%" },
    }
}
```

장착된 세트 아이템 수에 따라 보너스 자동 적용.

## 장비 타입별 기본 스탯

| 타입 | 가능한 기본 스탯 |
|------|----------------|
| Weapon | AttackPower, CritRate, CritDamage, HealPower |
| Armor | Defense, MaxHP, CooldownReduction |
| Accessory | 모든 스탯 (낮은 수치) |

## 아이템 관련 서비스 메서드

```lua
ItemService.CreateDrop(itemId, rarity)     -- 드롭 아이템 생성
ItemService.EquipItem(player, instanceId)  -- 장비 착용
ItemService.UnequipItem(player, slot)      -- 장비 해제
ItemService.EnhanceItem(player, instanceId, material)  -- 강화
ItemService.GetSetBonus(player)            -- 현재 세트 효과 계산
```
