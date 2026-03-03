# 애니메이션 시스템

## 기본 구조

- **Animator**: 실제 애니메이션 재생 담당 (Humanoid 내부에 자동 생성)
- **AnimationTrack**: 로드된 애니메이션 인스턴스
- **Priority**: 여러 애니메이션 동시 재생 시 우선순위 결정

```
Priority 낮음 ──────────────────────────── 높음
  Idle → Movement → Action → Action2 → Action3 → Action4
```

## 캐릭터 애니메이션 (LocalScript 권장)

```lua
-- StarterCharacterScripts 또는 StarterPlayerScripts
local Players = game:GetService("Players")
local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator")

-- 애니메이션 로드
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://507770239"  -- Roblox Animation Asset ID

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
track.Looped = false  -- 반복 여부

-- 재생
track:Play()
track:Play(0.1)            -- 0.1초 페이드인
track:Play(0.1, 1, 1.5)    -- 페이드인, 가중치, 배속

-- 정지
track:Stop()
track:Stop(0.3)  -- 0.3초 페이드아웃

-- 이벤트
track.Stopped:Connect(function()
    print("애니메이션 종료")
end)

-- 키프레임 마커 이벤트 (Animation Editor에서 마커 추가 필요)
track:GetMarkerReachedSignal("HitFrame"):Connect(function(paramString: string)
    applyHitEffect()
end)
```

## NPC/모델 애니메이션 (AnimationController)

Humanoid 없는 모델에 AnimationController를 직접 추가.

```lua
-- 모델에 AnimationController 추가 (Studio 또는 코드)
local npcModel = workspace.BossModel
local animController = npcModel:WaitForChild("AnimationController")
local animator = animController:WaitForChild("Animator")

local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://123456789"

local idleTrack = animator:LoadAnimation(idleAnim)
idleTrack.Priority = Enum.AnimationPriority.Idle
idleTrack.Looped = true
idleTrack:Play()
```

## 기본 애니메이션 덮어쓰기

플레이어 캐릭터의 기본 Idle/Walk 등을 교체하는 패턴.

```lua
-- StarterCharacterScripts/LocalScript
local humanoid = script.Parent:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- 기존 기본 애니메이션 중지
for _, track in animator:GetPlayingAnimationTracks() do
    track:Stop(0)
end

-- 커스텀 애니메이션 재생
local customIdle = Instance.new("Animation")
customIdle.AnimationId = "rbxassetid://MY_IDLE_ID"

local idleTrack = animator:LoadAnimation(customIdle)
idleTrack.Priority = Enum.AnimationPriority.Idle
idleTrack.Looped = true
idleTrack:Play()
```

## 애니메이션 상태 기계 예시

```lua
-- RPG 전투 애니메이션 관리
local AnimationManager = {}

local ANIM_IDS = {
    idle        = "rbxassetid://1000000001",
    run         = "rbxassetid://1000000002",
    attack1     = "rbxassetid://1000000003",
    attack2     = "rbxassetid://1000000004",
    skill1      = "rbxassetid://1000000005",
    hit         = "rbxassetid://1000000006",
    death       = "rbxassetid://1000000007",
}

local tracks: {[string]: AnimationTrack} = {}

function AnimationManager.init(animator: Animator)
    for name, id in ANIM_IDS do
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        tracks[name] = animator:LoadAnimation(anim)
    end

    -- 우선순위 설정
    tracks.idle.Priority    = Enum.AnimationPriority.Idle
    tracks.run.Priority     = Enum.AnimationPriority.Movement
    tracks.attack1.Priority = Enum.AnimationPriority.Action
    tracks.attack2.Priority = Enum.AnimationPriority.Action
    tracks.skill1.Priority  = Enum.AnimationPriority.Action2
    tracks.hit.Priority     = Enum.AnimationPriority.Action
    tracks.death.Priority   = Enum.AnimationPriority.Action4

    tracks.idle.Looped = true
    tracks.run.Looped  = true
    tracks.death.Looped = true
end

function AnimationManager.play(name: string, fadeTime: number?)
    local track = tracks[name]
    if not track then return end

    -- 같은 우선순위 이하 애니메이션 정지
    track:Play(fadeTime or 0.1)
end

function AnimationManager.stop(name: string)
    local track = tracks[name]
    if track then track:Stop(0.1) end
end

return AnimationManager
```

## 주의사항

- `AnimationController:LoadAnimation()` — **deprecated**, `Animator:LoadAnimation()` 직접 호출 사용
- 서버에서도 애니메이션 재생 가능하지만 **클라이언트에서 재생하는 것이 성능상 유리**
- 동일 애니메이션을 여러 번 `LoadAnimation()` 호출하면 별도 트랙 생성 → 1회만 로드 후 재사용
- `track.Looped` 속성은 Animation Editor에서도 설정 가능하며, 코드 설정이 우선
