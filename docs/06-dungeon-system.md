# 던전 시스템 (Dungeon System)

## 인스턴스 개념

각 파티는 **전용 인스턴스 공간**에서 던전을 플레이합니다.
다른 파티와 같은 공간을 공유하지 않아 방해 없이 플레이 가능합니다.

## 던전 데이터 구조

```lua
DungeonData["ForestOfBeginning"] = {
    Name        = "시작의 숲",
    Description = "신규 모험가를 위한 입문 던전",
    RecommendedLevel = 1,
    Floors      = 3,
    BossId      = "ForestGuardian",
    Waves = {
        { EnemyId="Slime",    Count=5, SpawnDelay=0  },
        { EnemyId="GoblinArcher", Count=3, SpawnDelay=5  },
        { EnemyId="OrcWarrior",   Count=2, SpawnDelay=10 },
    },
    Rewards = {
        Normal  = { ExpMultiplier=1.0, DropTable="Forest_Normal"  },
        Hard    = { ExpMultiplier=2.0, DropTable="Forest_Hard"    },
        Extreme = { ExpMultiplier=3.5, DropTable="Forest_Extreme" },
        Mythic  = { ExpMultiplier=6.0, DropTable="Forest_Mythic"  },
    }
}
```

## 난이도 시스템

| 난이도 | 스탯 배율 | 보상 배율 | 해금 조건 | 특수 메카닉 |
|--------|-----------|-----------|-----------|-------------|
| Normal | 1.0x | 1.0x | 기본 | 없음 |
| Hard | 1.5x | 2.0x | Normal 클리어 | HP 전환 패턴 |
| Extreme | 2.5x | 3.5x | Hard 클리어 | 역할 메카닉 + DPS 체크 |
| Mythic | 4.0x | 6.0x | Extreme 클리어 | 전체 + 변형 패턴 |

## 던전 생명주기

```
[1. Instance 생성]
DungeonService.CreateInstance() 호출
→ 파티 전용 월드 공간 할당
→ 던전 맵 로드
→ 파티원 텔레포트

[2. 던전 실행]
→ 웨이브 1 몬스터 스폰
→ 전투 진행
→ 웨이브 클리어 시 다음 웨이브

[3. 보스 등장]
→ 모든 일반 몬스터 처치 후 보스 스폰
→ BossService.StartBossFight() 호출
→ 페이즈 관리

[4. 보스 처치 / 실패]
→ 성공: 보상 계산 → 아이템 드롭 → 경험치 분배
→ 실패: 파티원 부활 없이 전원 사망 시 던전 실패

[5. Instance 정리]
→ 파티원 로비로 귀환
→ 인스턴스 메모리 해제
→ 쿨다운 적용
```

## 적 데이터 구조

```lua
EnemyData["OrcWarrior"] = {
    Name        = "오크 전사",
    BaseHP      = 500,
    BaseAtk     = 40,
    BaseDef     = 20,
    MoveSpeed   = 12,
    AggroRange  = 30,
    AttackRange = 5,
    AttackCooldown = 2,
    Patterns    = { "BasicAttack", "ChargeAttack" },
    DropTable   = "Orc_Common",
    ExpReward   = 50
}
```

## 드롭 테이블

```lua
DropTable["Forest_Normal"] = {
    { ItemId="WoodSword",    Weight=50, MinCount=1, MaxCount=1 },
    { ItemId="LeatherArmor", Weight=30, MinCount=1, MaxCount=1 },
    { ItemId="ForestRing",   Weight=15, MinCount=1, MaxCount=1 },
    { ItemId="AncientBlade", Weight=5,  MinCount=1, MaxCount=1 },
}
```

Weight가 높을수록 드롭 확률이 높습니다.

## 던전 재도전 제한

| 난이도 | 일일 입장 제한 | 쿨다운 |
|--------|---------------|--------|
| Normal | 무제한 | 없음 |
| Hard | 10회/일 | 없음 |
| Extreme | 5회/일 | 없음 |
| Mythic | 3회/일 | 없음 |
