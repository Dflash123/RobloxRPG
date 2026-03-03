--[[
    PartyService.luau
    파티 생성/초대/관리 서비스
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local PartyService = Knit.CreateService {
    Name = "PartyService",
    Client = {
        -- 서버 → 클라이언트: 파티 상태 변경 알림
        PartyUpdated  = Knit.CreateSignal(),
        -- 서버 → 클라이언트: 파티 초대 수신
        InviteReceived = Knit.CreateSignal(),
    },
}

local MAX_PARTY_SIZE = 4

-- 파티 저장소: [partyId] = Party
local Parties: { [string]: any } = {}
-- 플레이어 → 파티ID 매핑
local PlayerParty: { [Player]: string } = {}
-- 대기 중인 초대: [targetPlayer] = { fromPlayer, partyId }
local PendingInvites: { [Player]: { fromPlayer: Player, partyId: string } } = {}

-- ==========================================
-- 내부 헬퍼
-- ==========================================

local function generatePartyId(): string
    return string.format("party_%d_%d", os.time(), math.random(1000, 9999))
end

local function notifyPartyMembers(partyId: string, eventData: any)
    local party = Parties[partyId]
    if not party then return end
    for _, member in ipairs(party.Members) do
        PartyService.Client.PartyUpdated:Fire(member.Player, eventData)
    end
end

-- ==========================================
-- 공개 메서드
-- ==========================================

--[[
    파티 생성 (파티장이 됨)
--]]
function PartyService:CreateParty(player: Player): string?
    if PlayerParty[player] then
        warn(string.format("[PartyService] %s는 이미 파티에 소속됨", player.Name))
        return nil
    end

    local classId = player:GetAttribute("ClassId") or "Warrior"
    local role    = player:GetAttribute("Role") or "Tank"
    local partyId = generatePartyId()

    Parties[partyId] = {
        Id      = partyId,
        Leader  = player,
        Members = {
            { Player = player, Role = role, ClassId = classId }
        },
        MaxSize = MAX_PARTY_SIZE,
        Status  = "Idle",
    }
    PlayerParty[player] = partyId

    self.Client.PartyUpdated:Fire(player, { Action = "Created", PartyId = partyId })
    return partyId
end

--[[
    파티 초대 발송
--]]
function PartyService:InvitePlayer(leader: Player, targetPlayer: Player)
    local partyId = PlayerParty[leader]
    if not partyId then
        warn("[PartyService] 파티가 없는 플레이어가 초대 시도")
        return
    end

    local party = Parties[partyId]
    if party.Leader ~= leader then
        warn("[PartyService] 파티장만 초대 가능")
        return
    end

    if #party.Members >= MAX_PARTY_SIZE then
        warn("[PartyService] 파티 인원 초과")
        return
    end

    if PlayerParty[targetPlayer] then
        warn("[PartyService] 대상이 이미 다른 파티에 소속")
        return
    end

    PendingInvites[targetPlayer] = { fromPlayer = leader, partyId = partyId }
    self.Client.InviteReceived:Fire(targetPlayer, {
        FromPlayer = leader.Name,
        PartyId    = partyId,
    })
end

--[[
    초대 수락
--]]
function PartyService:AcceptInvite(player: Player)
    local invite = PendingInvites[player]
    if not invite then
        warn("[PartyService] 수락할 초대 없음")
        return
    end

    PendingInvites[player] = nil
    local partyId = invite.partyId
    local party   = Parties[partyId]

    if not party or #party.Members >= MAX_PARTY_SIZE then
        warn("[PartyService] 파티가 꽉 찼거나 존재하지 않음")
        return
    end

    local classId = player:GetAttribute("ClassId") or "Warrior"
    local role    = player:GetAttribute("Role") or "DPS"
    table.insert(party.Members, { Player = player, Role = role, ClassId = classId })
    PlayerParty[player] = partyId

    notifyPartyMembers(partyId, {
        Action  = "MemberJoined",
        Player  = player.Name,
        Members = party.Members,
    })
end

--[[
    파티 탈퇴
--]]
function PartyService:LeaveParty(player: Player)
    local partyId = PlayerParty[player]
    if not partyId then return end

    local party = Parties[partyId]
    PlayerParty[player] = nil

    -- 멤버 제거
    for i, member in ipairs(party.Members) do
        if member.Player == player then
            table.remove(party.Members, i)
            break
        end
    end

    -- 파티장 탈퇴 시 다음 멤버에게 위임
    if party.Leader == player then
        if #party.Members > 0 then
            party.Leader = party.Members[1].Player
            notifyPartyMembers(partyId, { Action = "LeaderChanged", NewLeader = party.Leader.Name })
        else
            -- 파티원 없음 → 파티 해산
            Parties[partyId] = nil
            return
        end
    end

    notifyPartyMembers(partyId, { Action = "MemberLeft", Player = player.Name })
end

--[[
    플레이어의 현재 파티 정보 반환 (클라이언트 요청용)
--]]
function PartyService.Client:GetMyParty(player: Player)
    local partyId = PlayerParty[player]
    if not partyId then return nil end

    local party = Parties[partyId]
    -- 플레이어 객체 제외한 직렬화 가능한 데이터 반환
    local memberData = {}
    for _, m in ipairs(party.Members) do
        table.insert(memberData, {
            Name    = m.Player.Name,
            Role    = m.Role,
            ClassId = m.ClassId,
        })
    end
    return {
        Id       = party.Id,
        Leader   = party.Leader.Name,
        Members  = memberData,
        Status   = party.Status,
    }
end

--[[
    플레이어 퇴장 처리
--]]
function PartyService:HandlePlayerRemoving(player: Player)
    PendingInvites[player] = nil
    self:LeaveParty(player)
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function PartyService:KnitInit()
    Players.PlayerRemoving:Connect(function(player)
        self:HandlePlayerRemoving(player)
    end)
end

function PartyService:KnitStart()
    print("[PartyService] 시작됨")
end

return PartyService
