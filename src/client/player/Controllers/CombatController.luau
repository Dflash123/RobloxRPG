--[[
    CombatController.luau
    전투 입력 처리 컨트롤러
    - 스킬 키 입력 감지 → 서버에 스킬 사용 요청
    - 전투 결과 수신 → UI에 반영
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local CombatController = Knit.CreateController {
    Name = "CombatController",
}

-- 스킬 키 바인딩 (Q/W/E/R → 스킬 슬롯 1~4)
local SKILL_KEYBINDS = {
    [Enum.KeyCode.Q] = 1,
    [Enum.KeyCode.W] = 2,
    [Enum.KeyCode.E] = 3,
    [Enum.KeyCode.R] = 4,
}

-- 현재 타겟 (마우스 클릭으로 설정)
local currentTarget: string? = nil

-- ==========================================
-- 내부 메서드
-- ==========================================

local function getSkillIdBySlot(slot: number): string?
    -- TODO: ClassService에서 현재 클래스의 스킬 목록 가져오기
    -- 임시: 슬롯 번호를 그대로 사용
    return nil
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function CombatController:KnitStart()
    local CombatService = Knit.GetService("CombatService")

    -- 스킬 키 입력 처리
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        local slot = SKILL_KEYBINDS[input.KeyCode]
        if not slot then return end

        local skillId = getSkillIdBySlot(slot)
        if not skillId then return end
        if not currentTarget then return end

        -- 서버에 스킬 사용 요청
        CombatService.SkillUsed:Fire(skillId, currentTarget)
    end)

    -- 서버로부터 전투 결과 수신
    CombatService.CombatResult:Connect(function(result)
        if result.IsCrit then
            print(string.format("[Combat] 크리티컬! %d 피해", result.Damage))
        elseif result.IsHeal then
            print(string.format("[Combat] 치유: %d", result.Amount))
        else
            print(string.format("[Combat] %d 피해", result.Damage))
        end
        -- TODO: UIController에 전투 결과 전달 (데미지 숫자 표시 등)
    end)

    print("[CombatController] 시작됨")
end

return CombatController
