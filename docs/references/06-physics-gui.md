# 물리 엔진 & GUI 시스템

## BasePart 핵심 속성

```lua
local part = workspace.MyPart

-- 물리 제어
part.Anchored = true           -- true: 위치 고정, false: 물리 적용
part.CanCollide = true          -- 충돌 여부
part.CanQuery = true            -- Raycast/FindPartInRadius 탐지 여부
part.CanTouch = true            -- Touched 이벤트 발생 여부
part.Massless = false           -- 부모 파트의 질량에 영향 X (연결 파트용)

-- 시각
part.Transparency = 0           -- 0 = 불투명, 1 = 완전 투명
part.CastShadow = true
part.Material = Enum.Material.SmoothPlastic
part.Color = Color3.fromRGB(255, 100, 50)
part.BrickColor = BrickColor.new("Bright red")

-- 크기/위치 (서버에서 변경 → 모든 클라이언트에 자동 복제)
part.Size = Vector3.new(4, 1, 4)
part.Position = Vector3.new(0, 5, 0)
part.CFrame = CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(45), 0)

-- 사용자 정의 물리 속성
part.CustomPhysicalProperties = PhysicalProperties.new(
    0.7,   -- density
    0.3,   -- friction
    0.5,   -- elasticity
    0.1,   -- frictionWeight
    0.1    -- elasticityWeight
)
```

## 충돌 감지 & Raycast

```lua
-- Touched 이벤트
part.Touched:Connect(function(otherPart: BasePart)
    local character = otherPart.Parent
    local player = game:GetService("Players"):GetPlayerFromCharacter(character)
    if player then
        print(player.Name .. "이 닿았습니다")
    end
end)

-- 한 번만 처리 (데바운스)
local touchDebounce = {}
part.Touched:Connect(function(otherPart: BasePart)
    local player = Players:GetPlayerFromCharacter(otherPart.Parent)
    if not player then return end
    if touchDebounce[player.UserId] then return end

    touchDebounce[player.UserId] = true
    processTouch(player)
    task.delay(1, function()
        touchDebounce[player.UserId] = nil
    end)
end)

-- Raycast
local origin    = Vector3.new(0, 10, 0)
local direction = Vector3.new(0, -100, 0)

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { workspace.CurrentCamera }

local result = workspace:Raycast(origin, direction, params)
if result then
    print("히트:", result.Instance.Name)
    print("거리:", result.Distance)
    print("위치:", result.Position)
    print("법선:", result.Normal)
end
```

## Humanoid (캐릭터)

```lua
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- 기본 속성
humanoid.MaxHealth  = 100
humanoid.Health     = 100
humanoid.WalkSpeed  = 16    -- 기본값
humanoid.JumpHeight = 7.2   -- 기본값 (JumpPower 대신 권장)

-- 이동 제어
humanoid:MoveTo(Vector3.new(10, 0, 10))
humanoid.MoveToFinished:Wait()

-- 피해 처리
humanoid:TakeDamage(30)     -- 서버에서 호출

-- 이벤트
humanoid.Died:Connect(function()
    print(player.Name, "사망")
end)

humanoid.HealthChanged:Connect(function(health: number)
    updateHealthUI(health, humanoid.MaxHealth)
end)

-- 상태 확인
local state = humanoid:GetState()
-- Enum.HumanoidStateType: Running, Jumping, Falling, Swimming, Dead 등
```

---

## GUI 시스템

### 계층 구조

```
PlayerGui (플레이어마다 개별 소유)
└── ScreenGui (ResetOnSpawn = false 권장)
    ├── Frame
    │   ├── TextLabel
    │   ├── TextButton
    │   ├── TextBox
    │   ├── ImageLabel
    │   └── ImageButton
    └── UIListLayout / UIGridLayout / UIAspectRatioConstraint
```

### 크기/위치 (UDim2)

```lua
-- UDim2.new(scaleX, offsetX, scaleY, offsetY)
-- scale: 부모 크기 대비 비율 (0~1)
-- offset: 픽셀 단위 절대값

frame.Size     = UDim2.new(0.3, 0, 0.05, 0)    -- 너비 30%, 높이 5%
frame.Position = UDim2.new(0, 10, 0, 10)        -- 좌상단에서 10px, 10px
frame.AnchorPoint = Vector2.new(0.5, 0.5)        -- 중심 기준점
```

### 기본 UI 코드

```lua
-- LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui   = playerGui:WaitForChild("MainGui")

-- 체력바 업데이트 (TweenService로 부드럽게)
local function updateHealthBar(current: number, max: number)
    local healthBar = mainGui.HUD.HealthBar.Fill
    local ratio = math.clamp(current / max, 0, 1)

    TweenService:Create(
        healthBar,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(ratio, 0, 1, 0) }
    ):Play()

    mainGui.HUD.HealthBar.Label.Text = `{current} / {max}`
end

-- 버튼 이벤트
local shopButton = mainGui.HUD.ShopButton
shopButton.MouseButton1Click:Connect(function()
    openShop()
end)

-- 팝업 애니메이션
local function showPopup(popup: Frame)
    popup.Visible = true
    popup.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(
        popup,
        TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0.4, 0, 0.5, 0) }
    ):Play()
end
```

### 유용한 UI 컴포넌트 속성

```lua
-- TextButton
button.Text = "확인"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
button.BorderSizePixel = 0       -- 테두리 제거
button.AutoButtonColor = true    -- 클릭 시 색상 자동 변경

-- UICorner (둥근 모서리)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)  -- 8px
corner.Parent = button

-- UIStroke (테두리)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Parent = button

-- UIListLayout (자동 정렬)
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)   -- 항목 간격 8px
layout.Parent = frame
```

### Billboard GUI (3D 세계 내 UI)

```lua
-- NPC 이름표, 피해 숫자 등에 사용
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 100, 0, 40)
billboard.StudsOffset = Vector3.new(0, 3, 0)  -- 파트 위 3스터드
billboard.AlwaysOnTop = false
billboard.Adornee = npcPart   -- 붙을 파트
billboard.Parent = workspace

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "Enemy Lv.5"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 50, 50)
label.Font = Enum.Font.GothamBold
label.Parent = billboard
```
