--[[
    PartyController.luau
    파티 관련 클라이언트 로직
    - 파티 초대 수신 → UI에 팝업
    - 파티 상태 변경 → HUD 업데이트
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local PartyController = Knit.CreateController {
    Name = "PartyController",
}

-- 현재 파티 캐시
local currentParty: any = nil

-- ==========================================
-- 공개 메서드
-- ==========================================

function PartyController:GetCurrentParty()
    return currentParty
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function PartyController:KnitStart()
    local PartyService = Knit.GetService("PartyService")

    -- 파티 초대 수신
    PartyService.InviteReceived:Connect(function(inviteData)
        print(string.format("[Party] %s님이 파티에 초대했습니다", inviteData.FromPlayer))
        -- TODO: UIController에 초대 팝업 표시 요청
    end)

    -- 파티 상태 변경 수신
    PartyService.PartyUpdated:Connect(function(updateData)
        local action = updateData.Action
        print(string.format("[Party] 상태 변경: %s", action))

        if action == "Created" then
            -- 파티 정보 가져오기
            PartyService:GetMyParty():andThen(function(partyData)
                currentParty = partyData
                -- TODO: PartyHUD 업데이트
            end)
        elseif action == "MemberJoined" or action == "MemberLeft" then
            currentParty = nil  -- 캐시 무효화
            PartyService:GetMyParty():andThen(function(partyData)
                currentParty = partyData
                -- TODO: PartyHUD 업데이트
            end)
        end
    end)

    -- 초기 파티 정보 로드
    PartyService:GetMyParty():andThen(function(partyData)
        currentParty = partyData
    end)

    print("[PartyController] 시작됨")
end

return PartyController
