# Client-Server 아키텍처

## 기본 원칙

- **서버(Script)**: 게임 로직, 데이터 저장, 보안 검증 담당
- **클라이언트(LocalScript)**: UI, 입력 처리, 카메라, 시각 효과 담당
- **클라이언트 데이터는 절대 신뢰 금지** — 모든 중요 처리는 서버에서 수행

## 스크립트 유형 비교

| 구분 | Script | LocalScript | ModuleScript |
|------|--------|-------------|--------------|
| 실행 위치 | 서버 | 클라이언트 (각자 독립) | 호출하는 쪽 |
| 배치 위치 | ServerScriptService | StarterPlayerScripts, StarterGui | ReplicatedStorage, ServerStorage |
| 플레이어 접근 | 전체 플레이어 | 자기 자신만 | — |
| DataStore | 가능 | 불가 | — |

## RemoteEvent (단방향 통신)

ReplicatedStorage에 RemoteEvent 인스턴스 배치 필수.

```lua
-- ─── 서버 (Script) ────────────────────────────────
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local DamageEvent = Events:WaitForChild("DamageEvent")

-- 특정 클라이언트로 전송
DamageEvent:FireClient(player, { damage = 50, hitPos = Vector3.new(0,0,0) })

-- 모든 클라이언트로 전송
DamageEvent:FireAllClients({ type = "explosion", pos = Vector3.new(0,0,0) })

-- 클라이언트로부터 수신 (서버 검증 필수!)
DamageEvent.OnServerEvent:Connect(function(player: Player, data: any)
    -- data는 신뢰하지 말고 검증
    if typeof(data) ~= "table" then return end
    if typeof(data.targetId) ~= "number" then return end

    applyDamage(player, data.targetId, data.damage)
end)
```

```lua
-- ─── 클라이언트 (LocalScript) ─────────────────────
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageEvent = ReplicatedStorage.Events:WaitForChild("DamageEvent")

-- 서버로 전송
DamageEvent:FireServer({ targetId = enemyId, damage = 30 })

-- 서버로부터 수신
DamageEvent.OnClientEvent:Connect(function(data: any)
    showDamageNumber(data.damage, data.hitPos)
end)
```

## RemoteFunction (양방향 통신)

응답이 필요한 경우에만 사용. 남용 시 성능 저하.

```lua
-- ─── 서버 (Script) ────────────────────────────────
local GetPlayerDataFunc = ReplicatedStorage:WaitForChild("GetPlayerData")

-- OnServerInvoke는 하나만 등록 가능 (Connect 아님!)
GetPlayerDataFunc.OnServerInvoke = function(player: Player, key: string): any
    if typeof(key) ~= "string" then return nil end
    return playerDataCache[player.UserId][key]
end
```

```lua
-- ─── 클라이언트 (LocalScript) ─────────────────────
local GetPlayerDataFunc = ReplicatedStorage:WaitForChild("GetPlayerData")

-- InvokeServer는 결과가 올 때까지 블로킹
local coins = GetPlayerDataFunc:InvokeServer("coins")
print("보유 코인:", coins)
```

## BindableEvent / BindableFunction (같은 쪽 통신)

서버↔서버 또는 클라이언트↔클라이언트 내부 모듈 간 통신.

```lua
-- 같은 서버 내 Script끼리
local bindable = Instance.new("BindableEvent")
bindable:Fire("hello")
bindable.Event:Connect(function(msg) print(msg) end)
```

## 통신 구조 설계 패턴

```
ReplicatedStorage/
├── Events/
│   ├── Combat/
│   │   ├── AttackEvent        (Client → Server: 공격 요청)
│   │   ├── DamageEvent        (Server → Client: 피해 시각화)
│   │   └── DeathEvent         (Server → AllClients: 사망 알림)
│   ├── UI/
│   │   ├── UpdateHPEvent      (Server → Client: HP 갱신)
│   │   └── NotificationEvent  (Server → Client: 알림 표시)
│   └── Shop/
│       └── PurchaseEvent      (Client → Server: 구매 요청)
└── Functions/
    ├── GetPlayerDataFunc      (Client ↔ Server: 데이터 조회)
    └── GetShopItemsFunc       (Client ↔ Server: 상점 목록)
```

## 보안 체크리스트

```lua
-- 서버에서 반드시 검증해야 할 항목들
DamageEvent.OnServerEvent:Connect(function(player: Player, data: any)
    -- 1. 타입 검증
    if typeof(data) ~= "table" then return end

    -- 2. 범위 검증 (핵 방지)
    local damage = tonumber(data.damage) or 0
    if damage <= 0 or damage > MAX_DAMAGE then return end

    -- 3. 거리 검증 (위치 조작 방지)
    local character = player.Character
    if not character then return end
    local dist = (character.PrimaryPart.Position - targetPosition).Magnitude
    if dist > MAX_ATTACK_RANGE then return end

    -- 4. 쿨타임 검증 (어뷰징 방지)
    local lastAttack = attackCooldowns[player.UserId] or 0
    if tick() - lastAttack < ATTACK_COOLDOWN then return end
    attackCooldowns[player.UserId] = tick()

    applyDamage(player, data.targetId, damage)
end)
```

## 레이트 리밋

- RemoteEvent: 클라이언트당 약 **500 req/s** 제한 (Roblox 내부 제한)
- 서버에서도 별도 쿨타임 로직으로 어뷰징 방지 권장
