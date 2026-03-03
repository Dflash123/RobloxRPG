# Instance Growth RPG

> Roblox 인스턴스 던전 성장형 RPG — Knit 프레임워크 기반

## 프로젝트 소개

파티를 구성해 인스턴스 던전을 공략하고, 아이템을 파밍해 더 높은 난이도에 도전하는 Roblox RPG입니다.

## 기획서

전체 기획서: **[GAMEDESIGN.md](GAMEDESIGN.md)**

| 문서 | 내용 |
|------|------|
| [01-game-overview.md](docs/01-game-overview.md) | 게임 개요 |
| [02-architecture.md](docs/02-architecture.md) | 아키텍처 |
| [03-class-system.md](docs/03-class-system.md) | 클래스 시스템 |
| [04-combat-system.md](docs/04-combat-system.md) | 전투 시스템 |
| [05-party-system.md](docs/05-party-system.md) | 파티 시스템 |
| [06-dungeon-system.md](docs/06-dungeon-system.md) | 던전 시스템 |
| [07-progression-system.md](docs/07-progression-system.md) | 성장 시스템 |
| [08-item-system.md](docs/08-item-system.md) | 아이템 시스템 |
| [09-boss-system.md](docs/09-boss-system.md) | 보스 시스템 |

---

## 개발 환경 설정

### 필요 도구

| 도구 | 용도 | 설치 |
|------|------|------|
| [Rojo](https://rojo.space) | 파일↔Roblox Studio 동기화 | `aftman install` |
| [Wally](https://github.com/UpliftGames/wally) | 패키지 관리 (Knit 설치) | `aftman install` |
| [Aftman](https://github.com/LPGhatguy/aftman) | 툴체인 관리 | GitHub 릴리즈 |

### 초기 설정

```bash
# 1. 패키지 설치 (Knit 등)
wally install

# 2. Rojo 서버 시작 (Roblox Studio 연동)
rojo serve default.project.json
```

### Roblox Studio에서

1. Rojo 플러그인 설치
2. Studio에서 `Connect` → `localhost:34872`
3. 파일 수정 시 Studio에 자동 반영

---

## 프로젝트 구조

```
src/
├── server/                         → ServerScriptService
│   ├── init.server.luau            Knit 서버 진입점
│   └── Services/
│       ├── CombatService.luau      전투 계산 (서버 권위)
│       ├── PartyService.luau       파티 관리
│       ├── DungeonService.luau     인스턴스 던전
│       ├── ClassService.luau       클래스/스탯
│       ├── ItemService.luau        아이템/장착/강화
│       └── ProgressionService.luau 레벨/DataStore
│
├── shared/                         → ReplicatedStorage
│   ├── Types.luau                  공용 타입 정의
│   ├── Data/                       데이터 테이블 (수치 모두 여기)
│   │   ├── ClassData.luau
│   │   ├── SkillData.luau
│   │   ├── ItemData.luau
│   │   ├── DungeonData.luau
│   │   ├── EnemyData.luau
│   │   └── BossData.luau
│   └── Modules/                    공용 유틸리티
│       ├── DamageCalculator.luau
│       └── DropGenerator.luau
│
└── client/
    ├── player/                     → StarterPlayerScripts
    │   ├── init.client.luau        Knit 클라이언트 진입점
    │   └── Controllers/
    │       ├── CombatController.luau
    │       ├── PartyController.luau
    │       └── UIController.luau
    └── gui/                        → StarterGui (UI 더미)
        ├── MainHUD.client.luau     HP/MP/스킬 바
        ├── PartyHUD.client.luau    파티원 목록
        ├── DungeonUI.client.luau   던전 선택
        ├── InventoryUI.client.luau 인벤토리
        └── ClassSelectUI.client.luau 클래스 선택
```

---

## 아키텍처

### 프레임워크: Knit

```
서버 Service   ←→  RemoteEvent/Signal  ←→  클라이언트 Controller
CombatService      자동 생성됨              CombatController
PartyService                                PartyController
...                                         UIController
```

### 설계 원칙

- **서버 권위**: 모든 피해/힐 계산은 서버에서 처리
- **데이터 기반**: `src/shared/Data/` 파일만 수정으로 컨텐츠 추가
- **확장성**: 새 클래스/스킬/던전/보스 추가 시 코어 서비스 코드 수정 불필요

---

## 개발 로드맵

| Phase | 내용 | 상태 |
|-------|------|------|
| **Phase 1 MVP** | 3클래스, 1던전, 기본 파티/전투 | 🔧 진행 중 |
| **Phase 2** | 추가 클래스, 3~5개 던전, 강화 시스템 | 📋 예정 |
| **Phase 3** | 길드, 레이드(8인), PvP | 📋 예정 |
| **Phase 4** | 시즌, 랭킹, 이벤트 던전 | 📋 예정 |
