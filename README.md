# Instance Growth RPG

> Roblox 인스턴스 던전 성장형 RPG

## 프로젝트 소개

파티를 구성해 인스턴스 던전을 공략하고, 아이템을 파밍해 더 높은 난이도에 도전하는 Roblox RPG입니다.

## 기획서

전체 기획서는 **[GAMEDESIGN.md](GAMEDESIGN.md)** 를 참조하세요.

### 세부 문서

| 문서 | 내용 |
|------|------|
| [01-game-overview.md](docs/01-game-overview.md) | 게임 개요 및 컨셉 |
| [02-architecture.md](docs/02-architecture.md) | 아키텍처 설계 |
| [03-class-system.md](docs/03-class-system.md) | 클래스 시스템 |
| [04-combat-system.md](docs/04-combat-system.md) | 전투 시스템 |
| [05-party-system.md](docs/05-party-system.md) | 파티 시스템 |
| [06-dungeon-system.md](docs/06-dungeon-system.md) | 던전 시스템 |
| [07-progression-system.md](docs/07-progression-system.md) | 성장 시스템 |
| [08-item-system.md](docs/08-item-system.md) | 아이템 시스템 |
| [09-boss-system.md](docs/09-boss-system.md) | 보스 시스템 |

## 폴더 구조

```
RobloxRPG/
├── GAMEDESIGN.md              # 전체 기획서
├── README.md
├── docs/                      # 세부 기획 문서
│   ├── 01-game-overview.md
│   ├── 02-architecture.md
│   ├── 03-class-system.md
│   ├── 04-combat-system.md
│   ├── 05-party-system.md
│   ├── 06-dungeon-system.md
│   ├── 07-progression-system.md
│   ├── 08-item-system.md
│   └── 09-boss-system.md
└── src/                       # Roblox 소스코드
    ├── ServerScriptService/
    │   ├── Services/          # 핵심 서비스 (DungeonService 등)
    │   └── Modules/           # 서버 유틸리티
    ├── ReplicatedStorage/
    │   ├── Data/              # 데이터 테이블 (ClassData, ItemData 등)
    │   ├── Shared/            # 공용 모듈
    │   └── RemoteEvents/      # 클라이언트-서버 이벤트
    └── StarterPlayer/
        └── StarterPlayerScripts/  # 클라이언트 컨트롤러
```

## 개발 로드맵

- **Phase 1 (MVP)**: 3클래스, 1던전, 기본 파티/전투
- **Phase 2**: 추가 클래스, 3~5개 던전, 강화 시스템
- **Phase 3**: 길드, 레이드, PvP
- **Phase 4**: 시즌, 랭킹, 이벤트
