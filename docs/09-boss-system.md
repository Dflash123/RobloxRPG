# 보스 시스템 (Boss System)

## 보스 데이터 구조

```lua
BossData["ForestGuardian"] = {
    Name     = "숲의 수호자",
    BaseHP   = 50000,
    BaseAtk  = 200,
    BaseDef  = 100,
    Scale    = {            -- 난이도별 배율
        Normal  = 1.0,
        Hard    = 1.5,
        Extreme = 2.5,
        Mythic  = 4.0,
    },
    Phases = {
        Phase1 = { HPThreshold=1.0,  Patterns={"BasicSlash","RootedStomp"} },
        Phase2 = { HPThreshold=0.7,  Patterns={"BasicSlash","RootedStomp","VineWhip"} },
        Phase3 = { HPThreshold=0.4,  Patterns={"Enrage","VineWhip","TankBuster"} },
        Phase4 = { HPThreshold=0.15, Patterns={"Enrage","DeathBlow","HealerCheck"} },
    }
}
```

## 보스 패턴 구조

```lua
BossPattern["TankBuster"] = {
    Name         = "탱크 버스터",
    TriggerHP    = 0.4,
    Action       = "TankBuster",
    RequiresRole = "Tank",           -- 탱커 필수
    TimeLimit    = nil,
    DPSCheck     = nil,
    Description  = "탱커가 정면에서 받지 않으면 파티 전체 80% HP 피해",
    Damage       = { Type="Percentage", Value=0.8 },   -- 최대 HP의 80%
    OnFail       = "GroupDamage",    -- 탱커 미처리 시 전체 피해
}

BossPattern["DPSRace"] = {
    Name         = "DPS 체크",
    TriggerHP    = 0.5,
    Action       = "Shield",
    RequiresRole = nil,
    TimeLimit    = 15,               -- 15초 제한
    DPSCheck     = 80000,            -- 15초 내 8만 딜
    Description  = "방어막을 15초 내 파괴하지 못하면 파티 전멸",
    OnFail       = "Wipe",
}

BossPattern["HealerCheck"] = {
    Name         = "힐러 체크",
    TriggerHP    = 0.15,
    Action       = "LifeDrain",
    RequiresRole = "Healer",
    TimeLimit    = 8,                -- 8초 내 힐러가 해제
    DPSCheck     = nil,
    Description  = "8초 내 힐러가 디버프를 제거하지 않으면 파티 전멸",
    OnFail       = "Wipe",
}
```

## 페이즈 전환 시스템

```lua
-- BossService 내부 로직
function BossService.CheckPhaseTransition(boss)
    local hpPercent = boss.CurrentHP / boss.MaxHP

    for phaseName, phaseData in pairs(boss.Phases) do
        if hpPercent <= phaseData.HPThreshold
            and boss.CurrentPhase ~= phaseName then
            BossService.TransitionToPhase(boss, phaseName)
            break
        end
    end
end
```

## 패턴 실행 흐름

```
1. 보스 HP 체크 → 페이즈 전환 트리거
2. 패턴 선택 (해당 페이즈 패턴 목록에서 순서/랜덤)
3. RequiresRole 확인 → 파티에 해당 역할 존재 여부 체크
4. TimeLimit이 있는 패턴: 타이머 시작
5. 플레이어 응답 대기
6. 성공: 보스 계속 진행 / 실패: OnFail 실행
```

## 난이도별 패턴 활성화

| 패턴 | Normal | Hard | Extreme | Mythic |
|------|--------|------|---------|--------|
| BasicSlash | ✅ | ✅ | ✅ | ✅ |
| RootedStomp | ✅ | ✅ | ✅ | ✅ |
| VineWhip | ❌ | ✅ | ✅ | ✅ |
| TankBuster | ❌ | ❌ | ✅ | ✅ |
| DPSRace | ❌ | ❌ | ✅ | ✅ |
| HealerCheck | ❌ | ❌ | ❌ | ✅ |
| DeathBlow | ❌ | ❌ | ❌ | ✅ |
| Enrage | ❌ | ❌ | ✅ | ✅ (강화) |

## 보스 추가 가이드

새 보스 추가 시 `BossData.lua`와 `BossPattern.lua`만 수정합니다.
BossService 코어 로직은 수정하지 않습니다.

체크리스트:
- [ ] BossData에 보스 정의 추가
- [ ] 보스 전용 패턴 BossPattern에 추가
- [ ] Phases에 HP 임계값 및 패턴 목록 정의
- [ ] DungeonData에서 보스 ID 참조
- [ ] 난이도별 Scale 배율 설정
