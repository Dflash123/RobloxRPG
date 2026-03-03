# 클래스 시스템 (Class System)

## 구조 계층

```
Role (역할) - 전투 책임 정의
└── Specialization (전문화) - 플레이 스타일 변형
    └── Concept (컨셉) - 테마/세계관 확장
```

## 기본 역할 (Base Roles)

### Tank (탱커)
- **목표**: 파티를 위해 피해를 흡수하고 몬스터의 어그로를 관리
- **주 스탯**: MaxHP, Defense, Aggro
- **역할 메카닉**: 보스의 특정 공격을 막거나 유도
- **예시 스킬**: 방패 차단, 도발, 방어 자세

### DPS (딜러)
- **목표**: 최대한 빠르게 적을 처치
- **주 스탯**: AttackPower, CritRate, CritDamage
- **역할 메카닉**: DPS 체크 패턴 담당
- **예시 스킬**: 강타, 연속 공격, 폭발 스킬

### Healer (힐러)
- **목표**: 파티원의 HP를 유지하고 버프 지원
- **주 스탯**: HealPower, MP, CooldownReduction
- **역할 메카닉**: 특정 디버프 제거, 부활
- **예시 스킬**: 단일 힐, 범위 힐, 부활, 보호막

## 기본 클래스 정의

### 워리어 (Warrior) — Tank
```lua
ClassData["Warrior"] = {
    Role = "Tank",
    Specialization = "Shield Guardian",
    Concept = "Iron Vanguard",
    BaseStats = {
        MaxHP      = 1000,
        Defense    = 80,
        AttackPower = 50,
        HealPower  = 0,
        Speed      = 14,
    },
    Skills = { "ShieldBash", "Taunt", "IronWall", "Provoke" }
}
```

### 버서커 (Berserker) — DPS
```lua
ClassData["Berserker"] = {
    Role = "DPS",
    Specialization = "Rage Striker",
    Concept = "Chaos Blade",
    BaseStats = {
        MaxHP       = 600,
        Defense     = 30,
        AttackPower = 150,
        HealPower   = 0,
        Speed       = 18,
    },
    Skills = { "FuryStrike", "BloodRage", "Cleave", "BerserkMode" }
}
```

### 프리스트 (Priest) — Healer
```lua
ClassData["Priest"] = {
    Role = "Healer",
    Specialization = "Holy Restoration",
    Concept = "Sacred Light",
    BaseStats = {
        MaxHP       = 500,
        Defense     = 20,
        AttackPower = 30,
        HealPower   = 120,
        Speed       = 15,
    },
    Skills = { "HolyHeal", "GroupHeal", "Resurrection", "DivineshIeld" }
}
```

## 스킬 구조

```lua
SkillData["ShieldBash"] = {
    Name         = "Shield Bash",
    Type         = "Active",
    Cooldown     = 8,           -- 초
    Multiplier   = 1.2,         -- AttackPower 배율
    Effect       = "Stun",      -- 상태이상
    EffectDuration = 2,
    AggroMultiplier = 3.0,      -- 어그로 배율
    Description  = "방패로 강타해 2초간 기절"
}
```

## 확장 규칙

> **중요**: 새 클래스 추가 시 `ClassData.lua`와 `SkillData.lua`만 수정합니다.
> `ClassService.lua` 코어 로직은 절대 수정하지 않습니다.

새 클래스 추가 체크리스트:
- [ ] ClassData에 클래스 정의 추가
- [ ] SkillData에 해당 스킬 추가
- [ ] 역할(Role)은 반드시 기존 역할 중 하나를 사용
- [ ] 스킬 타입은 기존 타입 중 하나를 사용 (Active/Passive/Toggle)

## 향후 추가 예정 역할

| 역할 | 설명 |
|------|------|
| Support | 버프/디버프 특화 지원 |
| Buffer | 파티 전체 강화 |
| Summoner | 소환수를 통한 전투 |
