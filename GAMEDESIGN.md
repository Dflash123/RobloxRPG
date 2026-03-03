# Instance Growth RPG — 게임 기획서

> **플랫폼**: Roblox
> **장르**: 인스턴스 던전 성장형 RPG
> **작성일**: 2026-03-03
> **버전**: v0.1.0

---

## 목차

1. [게임 개요](#1-게임-개요)
2. [핵심 게임플레이 루프](#2-핵심-게임플레이-루프)
3. [아키텍처 설계](#3-아키텍처-설계)
4. [클래스 시스템](#4-클래스-시스템)
5. [전투 시스템](#5-전투-시스템)
6. [파티 시스템](#6-파티-시스템)
7. [던전 시스템](#7-던전-시스템)
8. [성장 시스템](#8-성장-시스템)
9. [아이템 시스템](#9-아이템-시스템)
10. [보스 시스템](#10-보스-시스템)
11. [미래 확장 계획](#11-미래-확장-계획)

---

## 1. 게임 개요

### 1.1 컨셉 한 줄 요약

> 파티를 구성해 인스턴스 던전을 공략하고, 아이템을 파밍해 더 높은 난이도에 도전하는 성장형 RPG

### 1.2 핵심 가치

| 가치 | 설명 |
|------|------|
| **성장감** | 아이템·레벨 성장으로 체감되는 강함의 변화 |
| **역할 협력** | Tank/DPS/Healer의 역할 분담과 팀플레이 |
| **도전성** | Normal → Mythic까지 점층적 난이도 |
| **확장성** | 데이터 기반 설계로 컨텐츠 무한 추가 가능 |

### 1.3 타겟 유저

- Roblox RPG 장르를 즐기는 10~20대
- 던전 파밍 루프를 좋아하는 유저 (Dungeon Quest, 유사 장르 팬)
- 파티 플레이로 협력하고 싶은 유저

---

## 2. 핵심 게임플레이 루프

```
[캐릭터 생성 / 클래스 선택]
          ↓
[파티 결성 (1~4명)]
          ↓
[던전 입장 (난이도 선택)]
          ↓
[몬스터 처치 → 보스 클리어]
          ↓
[아이템 획득 / 경험치 획득]
          ↓
[장비 강화 / 레벨 업]
          ↓
[더 높은 난이도 도전]  ←────────────────┘
```

### 핵심 성장 사이클

```
던전 클리어 → 아이템 획득 → 장착/강화 → 전투력 증가 → 고난이도 도전
```

---

## 3. 아키텍처 설계

### 3.1 서버-클라이언트 구조

```
Roblox Server (ServerScriptService)
├── DungeonService    - 인스턴스 생성/관리/정리
├── PartyService      - 파티 생성/초대/해산
├── CombatService     - 전투 계산 (서버 권위)
├── ClassService      - 클래스 로직 관리
├── ItemService       - 아이템 생성/드롭/강화
└── ProgressionService - 레벨/경험치/스탯 관리

Roblox ReplicatedStorage
├── Data/
│   ├── ClassData     - 클래스 스탯/스킬 테이블
│   ├── SkillData     - 스킬 효과/쿨다운 테이블
│   ├── ItemData      - 아이템 기본 정보 테이블
│   ├── DungeonData   - 던전 레이아웃/몬스터 테이블
│   └── EnemyData     - 적 스탯/패턴 테이블
└── RemoteEvents/     - 클라이언트↔서버 통신

Roblox StarterPlayer (Client)
└── ClientController  - UI, 입력, 서버 요청
```

### 3.2 설계 원칙

| 원칙 | 이유 |
|------|------|
| **서버 권위 전투** | 핵/치트 방지, 공정성 보장 |
| **데이터 기반 설계** | 코드 수정 없이 컨텐츠 추가 가능 |
| **모듈식 서비스** | 각 서비스가 독립적으로 교체/확장 가능 |
| **하드코딩 금지** | 모든 수치는 Data 모듈에서 참조 |

---

## 4. 클래스 시스템

> 세부 내용: [docs/03-class-system.md](docs/03-class-system.md)

### 4.1 역할 구조

```
Role (역할)
├── Tank       - 피해 흡수, 어그로 관리
├── DPS        - 최대 딜량, 몬스터 처치
└── Healer     - 아군 치유, 버프 지원

Specialization (전문화)
└── 역할 내 다양한 플레이 스타일

Concept (컨셉)
└── 세계관/테마 확장 레이어 (예: 불꽃 기사, 성스러운 치유사)
```

### 4.2 기본 클래스 예시

| 클래스 | 역할 | 주 스탯 | 특징 |
|--------|------|---------|------|
| **워리어** | Tank | HP, Defense | 방패 차단, 어그로 생성 |
| **버서커** | DPS | AttackPower | 고딜, 저방어 |
| **프리스트** | Healer | HealPower | 범위 힐, 부활 |

### 4.3 확장 규칙

> **새 클래스는 반드시 ClassData 모듈에만 추가한다. 코어 서비스 로직 수정 불가.**

---

## 5. 전투 시스템

> 세부 내용: [docs/04-combat-system.md](docs/04-combat-system.md)

### 5.1 데미지 공식

```
최종 데미지 = (AttackPower × SkillMultiplier) - Defense
최소 데미지 = 1 (항상 최소 1 이상)
```

### 5.2 핵심 요구사항

- **서버 사이드 계산**: 모든 피해량은 서버에서 산출
- **어그로 시스템**: 탱커가 적의 타겟팅 우선순위 관리
- **쿨다운 검증**: 스킬 쿨다운은 서버에서 검증 (클라이언트 신뢰 불가)
- **역할 기반 보스 메카닉**: 보스 패턴이 특정 역할 요구 가능

### 5.3 전투 흐름

```
플레이어 스킬 입력 (Client)
        ↓
서버에 스킬 사용 요청 (RemoteEvent)
        ↓
CombatService: 쿨다운 검증 → 데미지 계산 → 적용
        ↓
결과 브로드캐스트 (클라이언트 동기화)
```

---

## 6. 파티 시스템

> 세부 내용: [docs/05-party-system.md](docs/05-party-system.md)

### 6.1 파티 구조

```lua
Party = {
    Leader  = Player,      -- 파티장 (던전 시작 권한)
    Members = [Player],    -- 최대 4명
    Roles   = {}           -- 역할 구성 표시
}
```

### 6.2 규칙

- 최대 파티원 수: **4명**
- 파티장만 던전 시작 가능
- 역할 구성(Tank/DPS/Healer 분포) 파티 UI에 표시
- 파티 기반으로 전용 인스턴스 생성

---

## 7. 던전 시스템

> 세부 내용: [docs/06-dungeon-system.md](docs/06-dungeon-system.md)

### 7.1 난이도 단계

| 난이도 | 스탯 배율 | 보상 배율 | 특수 메카닉 |
|--------|-----------|-----------|-------------|
| Normal | 1.0x | 1.0x | 없음 |
| Hard | 1.5x | 2.0x | 일부 활성화 |
| Extreme | 2.5x | 3.5x | 대부분 활성화 |
| Mythic | 4.0x | 6.0x | 전체 활성화 |

### 7.2 던전 생명주기

```
1. Instance 생성 (파티 전용 서버 공간)
2. 던전 실행 (몬스터 스폰, 웨이브 관리)
3. 보스 등장 및 처치
4. 보상 분배 (아이템, 경험치)
5. Instance 정리 (메모리 해제)
```

---

## 8. 성장 시스템

> 세부 내용: [docs/07-progression-system.md](docs/07-progression-system.md)

### 8.1 성장 루프

```
던전 클리어 → 경험치 → 레벨 업 → 기본 스탯 증가
           → 아이템  → 장착   → 전투력 증가
                     → 강화   → 추가 스탯
                     → 옵션   → 특화 빌드
```

### 8.2 시스템 목록

| 시스템 | 설명 |
|--------|------|
| **레벨 시스템** | 경험치 누적 → 레벨 업 → 기본 스탯 증가 |
| **장비 등급** | Common → Rare → Epic → Legendary → Mythic |
| **강화 시스템** | 장비 +1~+15 강화, 강화 실패 리스크 존재 |
| **랜덤 옵션** | 장비마다 랜덤 부가 스탯 부여 |
| **룬/탤런트** | 향후 확장 예정 |

---

## 9. 아이템 시스템

> 세부 내용: [docs/08-item-system.md](docs/08-item-system.md)

### 9.1 아이템 등급

```
Common (회색) → Rare (파랑) → Epic (보라) → Legendary (주황) → Mythic (빨강)
```

### 9.2 아이템 구조

```lua
Item = {
    Name        = "string",
    Type        = "Weapon" | "Armor" | "Accessory",
    Rarity      = "Common" | "Rare" | "Epic" | "Legendary" | "Mythic",
    BaseStats   = { AttackPower=0, Defense=0, HP=0, ... },
    RandomOptions = [ { Type="string", Value=number } ],
    SetID       = "string" | nil   -- 세트 아이템 여부
}
```

### 9.3 요구사항

- 랜덤 옵션 생성 모듈 (아이템 드롭 시 서버에서 생성)
- 세트 아이템 지원 (세트 효과 활성화)
- 향후 옵션 타입 확장성 유지

---

## 10. 보스 시스템

> 세부 내용: [docs/09-boss-system.md](docs/09-boss-system.md)

### 10.1 패턴 구조

```lua
BossPattern = {
    TriggerHP    = 0.5,           -- HP 50% 이하 시 발동
    Action       = "PhaseChange", -- 실행할 액션
    RequiresRole = "Tank",        -- 필요 역할 (nil = 없음)
    TimeLimit    = 10,            -- 초 제한 (옵션)
    DPSCheck     = 50000          -- DPS 체크 (옵션)
}
```

### 10.2 메카닉 종류

| 메카닉 | 설명 |
|--------|------|
| **HP 전환** | 특정 HP 도달 시 페이즈 전환 |
| **역할 메카닉** | 탱커/힐러만 처리 가능한 패턴 |
| **DPS 체크** | 제한 시간 내 일정 딜 미달 시 전멸 |
| **시간 제한** | 특정 행동 제한 시간 내 처리 필요 |

### 10.3 난이도별 패턴 변화

- **Normal**: 기본 패턴만 활성화
- **Hard**: HP 전환 메카닉 추가
- **Extreme**: 역할 메카닉 + DPS 체크 추가
- **Mythic**: 전체 패턴 + 추가 변형 패턴

---

## 11. 미래 확장 계획

### Phase 1 (MVP)
- [ ] 3개 기본 클래스 (Tank/DPS/Healer)
- [ ] 1개 기본 던전 (Normal/Hard)
- [ ] 기본 아이템 드롭 시스템
- [ ] 파티 시스템

### Phase 2 (컨텐츠 확장)
- [ ] 추가 클래스 (Support, Buffer 등)
- [ ] 던전 3~5개 추가
- [ ] Extreme/Mythic 난이도
- [ ] 장비 강화 시스템

### Phase 3 (소셜 확장)
- [ ] 탤런트 트리 시스템
- [ ] 길드 시스템
- [ ] 레이드 컨텐츠 (8인)
- [ ] PvP 아레나

### Phase 4 (라이브 서비스)
- [ ] 시즌 테마 전환
- [ ] 랭킹 시스템
- [ ] 이벤트 던전

---

## 개발 노트

### 기술 스택

| 항목 | 선택 |
|------|------|
| 언어 | Luau (Roblox 공식) |
| 프레임워크 | Roblox 네이티브 |
| 데이터 저장 | DataStore2 / ProfileService |
| 네트워킹 | RemoteEvents / RemoteFunctions |

### 폴더 구조

```
src/
├── ServerScriptService/
│   ├── Services/          # 핵심 서비스 모듈
│   └── Modules/           # 서버 유틸리티
├── ReplicatedStorage/
│   ├── Data/              # 데이터 테이블 (ClassData, ItemData 등)
│   ├── Shared/            # 공용 모듈
│   └── RemoteEvents/      # 이벤트 정의
└── StarterPlayer/
    └── StarterPlayerScripts/  # 클라이언트 컨트롤러
```
