# ModuleScript 패턴

## 기본 모듈

```lua
-- ReplicatedStorage/Modules/Utils.lua
local Utils = {}

function Utils.clamp(val: number, min: number, max: number): number
    return math.max(min, math.min(max, val))
end

function Utils.round(val: number, decimals: number): number
    local factor = 10 ^ decimals
    return math.floor(val * factor + 0.5) / factor
end

function Utils.formatNumber(n: number): string
    if n >= 1_000_000 then
        return string.format("%.1fM", n / 1_000_000)
    elseif n >= 1_000 then
        return string.format("%.1fK", n / 1_000)
    end
    return tostring(n)
end

return Utils
```

```lua
-- 사용
local Utils = require(ReplicatedStorage.Modules.Utils)
print(Utils.formatNumber(12500))  -- "12.5K"
```

## OOP 클래스 패턴

```lua
-- ReplicatedStorage/Classes/Character.lua
local Character = {}
Character.__index = Character

export type CharacterType = {
    player: Player,
    level: number,
    hp: number,
    maxHp: number,
    attack: number,
    defense: number,
}

function Character.new(player: Player, data: {[string]: any}): CharacterType
    local self = setmetatable({} :: CharacterType, Character)
    self.player   = player
    self.level    = data.level or 1
    self.maxHp    = 100 + (self.level - 1) * 20
    self.hp       = self.maxHp
    self.attack   = 10 + (self.level - 1) * 3
    self.defense  = 5 + (self.level - 1) * 2
    return self
end

function Character:takeDamage(amount: number): number
    local actual = math.max(1, amount - self.defense)
    self.hp = math.max(0, self.hp - actual)
    return actual
end

function Character:heal(amount: number)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function Character:isDead(): boolean
    return self.hp <= 0
end

function Character:getSaveData(): {[string]: any}
    return {
        level = self.level,
        hp    = self.hp,
    }
end

return Character
```

## 싱글톤 서비스 패턴

```lua
-- ServerScriptService/Services/CombatService.lua
local CombatService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local DamageEvent = ReplicatedStorage.Events:WaitForChild("DamageEvent")

-- 내부 상태
local combatData: {[number]: { lastAttack: number }} = {}

-- 초기화 (PlayerAdded 연결)
function CombatService:init()
    Players.PlayerAdded:Connect(function(player)
        combatData[player.UserId] = { lastAttack = 0 }
    end)
    Players.PlayerRemoving:Connect(function(player)
        combatData[player.UserId] = nil
    end)

    DamageEvent.OnServerEvent:Connect(function(player, data)
        self:handleAttack(player, data)
    end)
end

function CombatService:handleAttack(player: Player, data: any)
    if typeof(data) ~= "table" then return end

    local state = combatData[player.UserId]
    if not state then return end

    -- 쿨타임 검증
    if tick() - state.lastAttack < 0.5 then return end
    state.lastAttack = tick()

    -- 대미지 적용 로직
    local targetChar = workspace:FindFirstChild(tostring(data.targetName))
    if not targetChar then return end

    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end

    targetHumanoid:TakeDamage(data.damage or 10)

    -- 클라이언트에 결과 전송
    local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
    if targetPlayer then
        DamageEvent:FireClient(targetPlayer, { damage = data.damage })
    end
end

return CombatService
```

## Knit 프레임워크 (선택적, 대규모 프로젝트)

[Sleitnick/Knit](https://github.com/Sleitnick/Knit) — 서비스/컨트롤러 패턴을 표준화하는 인기 프레임워크.

```lua
-- 서버 서비스
local Knit = require(ReplicatedStorage.Packages.Knit)

local CoinService = Knit.CreateService {
    Name = "CoinService",
    Client = {
        CoinsChanged = Knit.CreateSignal(),  -- RemoteEvent 자동 생성
    },
}

function CoinService:AddCoins(player: Player, amount: number)
    playerData[player.UserId].coins += amount
    self.Client.CoinsChanged:Fire(player, playerData[player.UserId].coins)
end

function CoinService.Client:GetCoins(player: Player): number
    return playerData[player.UserId].coins
end

return CoinService
```

## 모듈 구조 권장 레이아웃

```
ReplicatedStorage/
├── Modules/
│   ├── Utils.lua           -- 범용 유틸리티
│   ├── Config.lua          -- 게임 상수/설정값
│   └── Types.lua           -- 공용 타입 정의
├── Classes/
│   ├── Character.lua
│   └── Skill.lua
└── Events/                 -- RemoteEvent 인스턴스

ServerScriptService/
├── Services/
│   ├── CombatService.lua
│   ├── DataService.lua
│   └── DungeonService.lua
└── init.server.lua         -- 진입점 (모든 서비스 초기화)

StarterPlayer/StarterPlayerScripts/
├── Controllers/
│   ├── InputController.lua
│   ├── CameraController.lua
│   └── UIController.lua
└── init.client.lua         -- 진입점
```

## init.server.lua 패턴 (서버 진입점)

```lua
-- ServerScriptService/init.server.lua
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Services")

-- 모든 서비스 로드 및 초기화
local serviceModules = Services:GetChildren()
local services = {}

for _, module in serviceModules do
    if module:IsA("ModuleScript") then
        local service = require(module)
        if service.init then
            service:init()
        end
        services[module.Name] = service
    end
end

print("[Server] 모든 서비스 초기화 완료:", #serviceModules)
```
