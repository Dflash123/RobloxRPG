--[[
    ClassService.luau
    클래스 관련 로직 — 선택, 스탯 계산, 스킬 유효성 검증
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local ClassData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("ClassData"))
local SkillData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SkillData"))

local ClassService = Knit.CreateService {
    Name = "ClassService",
    Client = {
        ClassChanged = Knit.CreateSignal(),
    },
}

-- ==========================================
-- 공개 메서드
-- ==========================================

--[[
    플레이어 클래스 설정 (클래스 선택 화면에서 호출)
--]]
function ClassService:SetClass(player: Player, classId: string)
    local classData = ClassData[classId]
    if not classData then
        warn(string.format("[ClassService] 유효하지 않은 클래스: %s", classId))
        return false
    end

    -- 플레이어 속성에 클래스 정보 저장
    player:SetAttribute("ClassId", classId)
    player:SetAttribute("Role", classData.Role)

    -- 기본 스탯 적용
    local level = player:GetAttribute("Level") or 1
    local stats = self:CalculateStats(classId, level)

    for stat, value in pairs(stats) do
        player:SetAttribute(stat, value)
    end

    self.Client.ClassChanged:Fire(player, { ClassId = classId, Stats = stats })
    print(string.format("[ClassService] %s → 클래스: %s (%s)", player.Name, classId, classData.Role))
    return true
end

--[[
    레벨+클래스 기반 최종 스탯 계산
--]]
function ClassService:CalculateStats(classId: string, level: number): { [string]: number }
    local classData = ClassData.Get(classId)
    local base   = classData.BaseStats
    local growth = classData.StatGrowth
    local stats  = {}

    for stat, baseValue in pairs(base) do
        local growthValue = (growth[stat] or 0) * (level - 1)
        stats[stat] = baseValue + growthValue
    end

    return stats
end

--[[
    스킬 사용 권한 검증 (CombatService에서 호출)
--]]
function ClassService:CanUseSkill(player: Player, skillId: string): (boolean, string?)
    local classId = player:GetAttribute("ClassId")
    if not classId then
        return false, "클래스가 설정되지 않음"
    end

    local classData = ClassData.Get(classId)
    local hasSkill = false
    for _, id in ipairs(classData.Skills) do
        if id == skillId then
            hasSkill = true
            break
        end
    end

    if not hasSkill then
        return false, string.format("클래스 %s는 스킬 %s를 사용할 수 없음", classId, skillId)
    end

    local skillData = SkillData[skillId]
    if not skillData then
        return false, string.format("스킬 데이터 없음: %s", skillId)
    end

    return true, nil
end

--[[
    클라이언트 요청: 선택 가능한 클래스 목록
--]]
function ClassService.Client:GetAllClasses(_player: Player)
    return ClassData.GetAll()
end

--[[
    클라이언트 요청: 클래스 선택
--]]
function ClassService.Client:SelectClass(player: Player, classId: string)
    return ClassService:SetClass(player, classId)
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function ClassService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        -- 기본 클래스 미설정 상태로 대기 (클래스 선택 UI에서 설정)
        player:SetAttribute("ClassId", nil)
        player:SetAttribute("Level", 1)
        player:SetAttribute("Experience", 0)
    end)
end

function ClassService:KnitStart()
    print("[ClassService] 시작됨")
end

return ClassService
