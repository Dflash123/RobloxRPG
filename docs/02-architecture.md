# 아키텍처 설계 (Architecture)

## 전체 구조

```
┌─────────────────────────────────────┐
│         Roblox Server               │
│  ServerScriptService                │
│  ├── DungeonService                 │
│  ├── PartyService                   │
│  ├── CombatService                  │
│  ├── ClassService                   │
│  ├── ItemService                    │
│  └── ProgressionService             │
└─────────────────┬───────────────────┘
                  │ RemoteEvents
┌─────────────────┴───────────────────┐
│       ReplicatedStorage             │
│  ├── Data/                          │
│  │   ├── ClassData.lua              │
│  │   ├── SkillData.lua              │
│  │   ├── ItemData.lua               │
│  │   ├── DungeonData.lua            │
│  │   └── EnemyData.lua              │
│  ├── Shared/                        │
│  └── RemoteEvents/                  │
└─────────────────┬───────────────────┘
                  │
┌─────────────────┴───────────────────┐
│         Roblox Client               │
│  StarterPlayer/StarterPlayerScripts │
│  └── ClientController               │
└─────────────────────────────────────┘
```

## 서비스 책임 정의

### DungeonService
- 파티 요청 시 인스턴스 공간 생성
- 몬스터 스폰 및 웨이브 관리
- 던전 클리어 감지 및 보상 트리거
- 인스턴스 메모리 정리

### PartyService
- 파티 생성/초대/수락/거절
- 파티 역할 구성 관리
- 파티 해산 처리

### CombatService
- 피해량 서버 계산 (핵 방지)
- 스킬 쿨다운 서버 검증
- 어그로 테이블 관리
- 상태이상 적용/해제

### ClassService
- ClassData 로드 및 제공
- 스킬 발동 조건 검증
- 클래스 스탯 계산

### ItemService
- 드롭 아이템 서버 생성
- 랜덤 옵션 부여
- 인벤토리 관리
- 장비 착용/해제 스탯 반영

### ProgressionService
- 경험치 누적 및 레벨업 처리
- 기본 스탯 계산
- DataStore 저장/로드

## 설계 원칙

### 서버 권위 (Server-Authoritative)
모든 게임 로직 결과는 서버에서 계산되고 검증됩니다.
클라이언트는 오직 입력과 UI 표시만 담당합니다.

```
클라이언트: "스킬 사용 요청" → 서버
서버: 검증 → 계산 → 적용 → 결과 브로드캐스트
클라이언트: 결과 수신 → UI 업데이트
```

### 데이터 기반 (Data-Driven)
게임플레이 수치는 코드가 아닌 Data 모듈 테이블에 정의합니다.

```lua
-- 잘못된 방식 (하드코딩)
local damage = 150
local cooldown = 5

-- 올바른 방식 (데이터 참조)
local skillData = SkillData.Get(skillId)
local damage = skillData.BaseDamage
local cooldown = skillData.Cooldown
```

### 모듈 독립성
각 서비스는 다른 서비스에 직접 의존하지 않고 이벤트/인터페이스를 통해 통신합니다.

## 데이터 흐름 예시: 전투

```
1. 클라이언트: UseSkill(skillId, targetId) → RemoteEvent
2. CombatService: 요청 수신
3. CombatService: ClassService.ValidateCooldown(player, skillId)
4. CombatService: 데미지 계산 (SkillData + PlayerStats)
5. CombatService: EnemyData 적에 피해 적용
6. CombatService: 결과 → RemoteEvent → 클라이언트 동기화
```
