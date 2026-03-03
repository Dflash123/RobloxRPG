# 성장 시스템 (Progression System)

## 레벨 시스템

### 경험치 테이블 공식
```
필요 경험치(Lv) = BasExp × (Level ^ ExpExponent)

기본값:
  BaseExp     = 100
  ExpExponent = 1.8
```

| 레벨 | 필요 경험치 | 누적 경험치 |
|------|-------------|-------------|
| 1 | 100 | 100 |
| 5 | 1,150 | 3,620 |
| 10 | 6,310 | 27,880 |
| 20 | 45,250 | 285,100 |
| 50 | 1,148,700 | 12,450,000 |

### 레벨업 보상
- 기본 스탯 증가 (클래스별 증가량 다름)
- 특정 레벨 달성 시 스킬 슬롯 해금 (10, 20, 30레벨)

## 스탯 성장

### 레벨당 스탯 증가 (예시: 워리어)
```lua
LevelStatGrowth["Warrior"] = {
    MaxHP       = 50,   -- 레벨당 HP +50
    Defense     = 3,    -- 레벨당 방어력 +3
    AttackPower = 2,    -- 레벨당 공격력 +2
}
```

### 최종 스탯 계산
```
최종 스탯 = 클래스 기본 스탯
          + (레벨 × 레벨당 증가량)
          + 장비 합산 스탯
          + 강화 추가 스탯
          + 랜덤 옵션 스탯
```

## 장비 강화 시스템

### 강화 단계
```
+0 → +1 → +2 → ... → +10 → +11 → +12 → +13 → +14 → +15
                      │
                 +10부터 실패 리스크 발생
```

### 강화 확률

| 강화 단계 | 성공률 | 실패 시 |
|-----------|--------|---------|
| +1 ~ +5 | 100% | — |
| +6 ~ +9 | 80% | 강화 수치 유지 |
| +10 ~ +12 | 60% | 강화 수치 -1 |
| +13 ~ +14 | 30% | 강화 수치 -2 |
| +15 | 15% | 강화 수치 -3 |

### 강화 스탯 증가율
```lua
EnhancementBonus[rarity][step] = {
    -- 예: Rare 장비 +5
    ["Rare"][5] = { AttackPower = 25, Defense = 15 }
}
```

## 랜덤 옵션 시스템

### 옵션 타입 목록
```lua
RandomOptionTypes = {
    "AttackPower",      -- 공격력 증가
    "Defense",          -- 방어력 증가
    "MaxHP",            -- 최대 HP 증가
    "CritRate",         -- 크리티컬 확률 증가
    "CritDamage",       -- 크리티컬 피해 증가
    "CooldownReduction",-- 쿨다운 감소
    "HealPower",        -- 치유력 증가
    "MoveSpeed",        -- 이동속도 증가
}
```

### 랜덤 옵션 개수 (등급별)
| 등급 | 옵션 수 |
|------|---------|
| Common | 0 |
| Rare | 1 |
| Epic | 2 |
| Legendary | 3 |
| Mythic | 4 |

## 세이브 데이터 구조

```lua
PlayerSaveData = {
    Level           = 1,
    Experience      = 0,
    ClassId         = "Warrior",
    EquippedItems   = { Head=nil, Body=nil, Legs=nil, Weapon=nil, Acc=nil },
    Inventory       = [],
    DungeonProgress = { Normal={}, Hard={}, Extreme={}, Mythic={} },
    DailyLimits     = { lastReset="", counts={} }
}
```

DataStore 키: `Player_{userId}_SaveData`
