--[[
    UIController.luau
    UI 전반 관리 컨트롤러
    - 각 UI 패널의 표시/숨김
    - 다른 컨트롤러로부터 UI 업데이트 요청 수신
    - PlayerGui 내 UI 요소 참조 관리
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local UIController = Knit.CreateController {
    Name = "UIController",
}

local player = Players.LocalPlayer
local playerGui: PlayerGui

-- UI 패널 참조 캐시 (나중에 직접 UI 구현 시 채워짐)
local UIRefs: { [string]: any } = {}

-- ==========================================
-- 공개 메서드
-- ==========================================

--[[
    UI 패널 표시/숨김 토글
    @param panelName  "MainHUD" | "InventoryUI" | "DungeonUI" | "ClassSelectUI" | "PartyHUD"
    @param visible    boolean
--]]
function UIController:SetPanelVisible(panelName: string, visible: boolean)
    local ref = UIRefs[panelName]
    if ref then
        ref.Enabled = visible
    else
        warn(string.format("[UIController] UI 패널 없음: %s (더미 상태)", panelName))
    end
end

--[[
    데미지/힐 숫자 플로팅 표시 (전투 결과)
    @param position  Vector3
    @param amount    number
    @param isCrit    boolean
    @param isHeal    boolean
--]]
function UIController:ShowFloatingText(position: Vector3, amount: number, isCrit: boolean, isHeal: boolean)
    -- TODO: 직접 UI 구현 예정 (BillboardGui 기반)
    print(string.format("[UIController] FloatingText: %s%d%s",
        isHeal and "+" or "-",
        amount,
        isCrit and " (CRIT)" or ""
    ))
end

--[[
    플레이어 HP/MP 바 업데이트
--]]
function UIController:UpdateHPBar(current: number, max: number)
    -- TODO: MainHUD.HPBar 업데이트
end

function UIController:UpdateMPBar(current: number, max: number)
    -- TODO: MainHUD.MPBar 업데이트
end

--[[
    스킬 쿨다운 표시 업데이트
    @param slot    number (1~4)
    @param remaining  number (남은 쿨다운 초)
--]]
function UIController:UpdateSkillCooldown(slot: number, remaining: number)
    -- TODO: MainHUD.SkillBar.Skill{slot} 업데이트
end

--[[
    알림 토스트 표시
    @param message  string
    @param duration  number (초)
--]]
function UIController:ShowNotification(message: string, duration: number)
    duration = duration or 3
    print(string.format("[UIController] 알림: %s (%ds)", message, duration))
    -- TODO: 직접 UI 구현 예정
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function UIController:KnitInit()
    playerGui = player:WaitForChild("PlayerGui")

    -- UI 참조 초기화 (직접 UI 구현 후 여기서 참조)
    -- 현재는 더미 상태라 warn 출력됨
    local function tryRef(name: string)
        local ref = playerGui:FindFirstChild(name, true)
        if ref then
            UIRefs[name] = ref
        end
    end

    tryRef("MainHUD")
    tryRef("PartyHUD")
    tryRef("DungeonUI")
    tryRef("InventoryUI")
    tryRef("ClassSelectUI")
end

function UIController:KnitStart()
    -- 서비스 이벤트 연결
    local ProgressionService = Knit.GetService("ProgressionService")

    ProgressionService.LeveledUp:Connect(function(data)
        self:ShowNotification(string.format("레벨 업! Lv.%d", data.NewLevel), 4)
    end)

    print("[UIController] 시작됨")
end

return UIController
