# 파티 시스템 (Party System)

## 파티 구조

```lua
Party = {
    Id      = "string",         -- 파티 고유 ID
    Leader  = Player,           -- 파티장
    Members = [Player],         -- 파티원 목록 (파티장 포함)
    Roles   = {                 -- 역할 구성
        Tank   = 1,
        DPS    = 2,
        Healer = 1,
    },
    MaxSize = 4,
    Status  = "Idle" | "InDungeon" | "Waiting"
}
```

## 파티 생성 흐름

```
1. 플레이어 A: 파티 생성 요청 → PartyService
2. PartyService: 파티 생성, A = 파티장
3. 플레이어 A: 플레이어 B에게 초대 발송
4. 플레이어 B: 초대 수락
5. PartyService: B를 파티에 추가, 역할 구성 업데이트
6. UI: 파티 현황 표시 (역할 아이콘, 이름, HP바)
```

## 규칙 및 제한

| 항목 | 규칙 |
|------|------|
| 최대 인원 | 4명 |
| 던전 시작 권한 | 파티장만 가능 |
| 파티 탈퇴 | 누구든 언제든 가능 (던전 중 제외) |
| 파티장 위임 | 파티장이 탈퇴 시 자동으로 다음 멤버에게 위임 |
| 솔로 던전 | 파티 없이 단독 입장 가능 (1인 파티) |

## UI 표시 정보

파티 HUD에 표시:
- 파티원 이름
- 현재 HP / 최대 HP
- 현재 MP / 최대 MP
- 역할 아이콘 (Tank/DPS/Healer)
- 현재 상태이상

## 역할 구성 권고

| 구성 | 추천도 | 비고 |
|------|--------|------|
| 1탱 1힐 2딜 | ★★★★★ | 표준 구성 |
| 1탱 2힐 1딜 | ★★★☆☆ | 생존 특화 |
| 2탱 1힐 1딜 | ★★★☆☆ | 하드 이상 |
| 4딜 | ★★☆☆☆ | 고난이도 비추천 |

> 역할 구성은 강제가 아닌 권고입니다. 단, Mythic 던전의 일부 패턴은 특정 역할이 없으면 클리어 불가입니다.

## 파티 인스턴스 연동

파티가 던전 입장 시 PartyService → DungeonService에 파티 정보 전달:

```lua
DungeonService.CreateInstance({
    PartyId  = party.Id,
    Members  = party.Members,
    Dungeon  = selectedDungeon,
    Difficulty = selectedDifficulty
})
```
