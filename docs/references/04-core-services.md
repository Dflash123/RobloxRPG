# 핵심 서비스 레퍼런스

## 서비스 가져오기 (표준 패턴)

```lua
-- 항상 GetService() 사용 (직접 접근보다 안전)
local Players             = game:GetService("Players")
local Workspace           = game:GetService("Workspace")       -- 또는 workspace (소문자)
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerStorage       = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService") -- LocalScript 전용
local TweenService        = game:GetService("TweenService")
local DataStoreService    = game:GetService("DataStoreService") -- Script 전용
local MarketplaceService  = game:GetService("MarketplaceService")
local HttpService         = game:GetService("HttpService")
local CollectionService   = game:GetService("CollectionService")
local PhysicsService      = game:GetService("PhysicsService")
local SoundService        = game:GetService("SoundService")
local TextService         = game:GetService("TextService")
local ContextActionService = game:GetService("ContextActionService") -- LocalScript
local PathfindingService  = game:GetService("PathfindingService")
```

---

## Players

```lua
local Players = game:GetService("Players")

-- 플레이어 목록
local allPlayers = Players:GetPlayers()  -- {Player}

-- 캐릭터 → 플레이어 역참조
local player = Players:GetPlayerFromCharacter(character)

-- 이벤트
Players.PlayerAdded:Connect(function(player: Player)
    print(player.Name .. " 접속")
    print("UserId:", player.UserId)
    print("AccountAge:", player.AccountAge)  -- 계정 생성 후 일수
end)

Players.PlayerRemoving:Connect(function(player: Player)
    print(player.Name .. " 퇴장")
end)

-- 로컬 플레이어 (LocalScript에서)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
```

---

## RunService

```lua
local RunService = game:GetService("RunService")

-- 환경 판별
RunService:IsServer()   -- 서버 Script
RunService:IsClient()   -- LocalScript
RunService:IsStudio()   -- Studio 테스트 중

-- Heartbeat: 물리 처리 후 (서버/클라이언트 모두)
-- deltaTime: 이전 프레임과의 시간 차이 (초)
RunService.Heartbeat:Connect(function(dt: number)
    updateGameLogic(dt)
end)

-- RenderStepped: 렌더링 직전 (클라이언트 전용, UI/카메라)
RunService.RenderStepped:Connect(function(dt: number)
    updateCamera(dt)
end)

-- Stepped: 물리 처리 전 (클라이언트 전용)
RunService.Stepped:Connect(function(time: number, dt: number)
    applyForces(dt)
end)

-- 연결 해제 (메모리 누수 방지)
local conn = RunService.Heartbeat:Connect(function(dt) end)
conn:Disconnect()
```

---

## TweenService

```lua
local TweenService = game:GetService("TweenService")

-- TweenInfo 생성자: (시간, 이징스타일, 방향, 반복횟수, 역방향, 지연)
local info = TweenInfo.new(
    0.5,                          -- duration
    Enum.EasingStyle.Quad,        -- Quad, Cubic, Back, Bounce, Elastic, Linear...
    Enum.EasingDirection.Out,     -- In, Out, InOut
    0,                            -- repeatCount (-1 = 무한)
    false,                        -- reverses
    0                             -- delayTime
)

-- 트윈 가능한 속성: Position, Size, Color, Transparency, CFrame, TextColor3 등
local tween = TweenService:Create(part, info, {
    Position = Vector3.new(10, 0, 0),
    Transparency = 0.5,
    Color = Color3.fromRGB(255, 0, 0),
})

tween:Play()
tween:Pause()
tween:Cancel()

tween.Completed:Connect(function(playbackState: Enum.PlaybackState)
    if playbackState == Enum.PlaybackState.Completed then
        print("트윈 완료")
    end
end)
```

---

## UserInputService (LocalScript 전용)

```lua
local UIS = game:GetService("UserInputService")

-- 키 입력
UIS.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end  -- 채팅/UI 입력 무시

    if input.KeyCode == Enum.KeyCode.E then
        interactWithObject()
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        startSprint()
    end
end)

UIS.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        stopSprint()
    end
end)

-- 마우스 위치
local mousePos = UIS:GetMouseLocation()  -- Vector2

-- 마우스 잠금 (FPS 등)
UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

-- 플랫폼 감지
UIS.TouchEnabled   -- 모바일
UIS.KeyboardEnabled
UIS.GamepadEnabled
```

---

## PathfindingService (NPC AI)

```lua
local PathfindingService = game:GetService("PathfindingService")

local path = PathfindingService:CreatePath({
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    AgentCanClimb = false,
    Costs = {
        Water = 100,  -- 지형 비용
    }
})

local function moveTo(npc: Model, target: Vector3)
    local success, err = pcall(function()
        path:ComputeAsync(npc.PrimaryPart.Position, target)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        warn("경로 탐색 실패:", err)
        return
    end

    local waypoints = path:GetWaypoints()
    for _, waypoint in waypoints do
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            npc.Humanoid.Jump = true
        end
        npc.Humanoid:MoveTo(waypoint.Position)
        npc.Humanoid.MoveToFinished:Wait()
    end
end
```

---

## HttpService

```lua
local HttpService = game:GetService("HttpService")

-- JSON 직렬화/역직렬화 (DataStore 데이터 처리 시 유용)
local json = HttpService:JSONEncode({ key = "value", num = 42 })
local data = HttpService:JSONDecode(json)

-- UUID 생성
local id = HttpService:GenerateGUID(false)  -- "xxxxxxxx-xxxx-..."

-- HTTP 요청 (Studio에서 HttpEnabled 설정 필요, 서버 전용)
local response = HttpService:RequestAsync({
    Url = "https://api.example.com/data",
    Method = "GET",
    Headers = { ["Content-Type"] = "application/json" },
})
if response.Success then
    local body = HttpService:JSONDecode(response.Body)
end
```
