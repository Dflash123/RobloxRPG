# Roblox Studio 구조

## Data Model 계층

```
DataModel (game)
├── Workspace               -- 3D 월드의 모든 객체 (BasePart, Model, Terrain 등)
├── Players                 -- 접속 플레이어 관리
├── StarterGui              -- 클라이언트 GUI 템플릿 (스폰 시 PlayerGui로 복사)
├── StarterPack             -- 플레이어 시작 아이템 (Tool 등)
├── StarterPlayer
│   ├── StarterCharacterScripts  -- 캐릭터 스폰 시 복사되는 LocalScript
│   └── StarterPlayerScripts     -- 게임 접속 시 1회 실행되는 LocalScript
├── ReplicatedStorage       -- 서버/클라이언트 양쪽 접근 가능 (RemoteEvent, 공용 모듈)
├── ReplicatedFirst         -- 클라이언트 최초 로드 시 가장 먼저 실행
├── ServerStorage           -- 서버 전용 스토리지 (클라이언트 접근 불가)
├── ServerScriptService     -- 서버 Script 전용 컨테이너
├── Lighting                -- 조명 / 환경 설정 (Atmosphere, Sky 등)
├── Teams                   -- 팀 설정
└── SoundService            -- 전역 사운드 관리
```

## 스크립트 배치 규칙

| 스크립트 유형 | 실행 위치 | 권장 배치 위치 |
|---------------|-----------|----------------|
| Script | 서버 | ServerScriptService |
| LocalScript | 클라이언트 | StarterPlayerScripts, StarterGui |
| ModuleScript | 호출하는 쪽 | ReplicatedStorage (공용), ServerStorage (서버 전용) |

## 주요 단축키

| 단축키 | 기능 |
|--------|------|
| `F5` | 테스트 플레이 시작 |
| `Shift+F5` | 테스트 플레이 종료 |
| `Ctrl+Shift+X` | Explorer 창 열기 |
| `Ctrl+Shift+P` | Properties 창 열기 |
| `Ctrl+Shift+C` | Output 창 열기 |
| `Alt+S` | Studio 설정 |

## 인스턴스 생성 패턴

```lua
-- 코드로 파트 생성
local part = Instance.new("Part")
part.Name = "MyPart"
part.Size = Vector3.new(4, 1, 4)
part.Position = Vector3.new(0, 5, 0)
part.Anchored = true
part.BrickColor = BrickColor.new("Bright red")
part.Parent = workspace  -- Parent 설정은 마지막에 (성능)

-- 기존 인스턴스 참조
local floor = workspace:WaitForChild("Floor")      -- 로드 대기 후 참조
local folder = workspace:FindFirstChild("Folder")  -- nil 반환 가능
local tagged = workspace:FindFirstChildOfClass("Part")
```

## 태그 시스템 (CollectionService)

```lua
local CollectionService = game:GetService("CollectionService")

-- 태그 추가
CollectionService:AddTag(part, "Damageable")

-- 태그된 모든 인스턴스 가져오기
local damageables = CollectionService:GetTagged("Damageable")

-- 태그 추가/제거 감지
CollectionService:GetInstanceAddedSignal("Damageable"):Connect(function(inst)
    setupDamageable(inst)
end)
```
