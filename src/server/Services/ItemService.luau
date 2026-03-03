--[[
    ItemService.luau
    아이템 드롭, 인벤토리, 장착, 강화 서비스
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local ItemData      = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("ItemData"))
local DropGenerator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DropGenerator"))

local ItemService = Knit.CreateService {
    Name = "ItemService",
    Client = {
        InventoryUpdated = Knit.CreateSignal(),
        ItemDropped      = Knit.CreateSignal(),
    },
}

-- 인벤토리: [player] = { [instanceId] = Item }
local Inventories: { [Player]: { [string]: any } } = {}
-- 장착 슬롯: [player] = { Weapon=Item?, Armor=Item?, Accessory=Item? }
local EquippedItems: { [Player]: { [string]: any? } } = {}

-- ==========================================
-- 인벤토리 관리
-- ==========================================

function ItemService:GetInventory(player: Player)
    return Inventories[player] or {}
end

function ItemService:GetEquipped(player: Player)
    return EquippedItems[player] or {}
end

--[[
    아이템 드롭 생성 및 플레이어에게 지급
    @param players    보상 대상 플레이어 목록
    @param dropTable  DungeonData에서 가져온 드롭 테이블
--]]
function ItemService:DistributeDrops(players: { Player }, dropTable: { any })
    for _, player in ipairs(players) do
        local itemId = DropGenerator.RollDrop(dropTable)
        if itemId then
            local item = DropGenerator.CreateItemInstance(itemId)
            self:AddItemToInventory(player, item)
            self.Client.ItemDropped:Fire(player, item)
        end
    end
end

function ItemService:AddItemToInventory(player: Player, item: any)
    if not Inventories[player] then
        Inventories[player] = {}
    end
    Inventories[player][item.InstanceId] = item
    self.Client.InventoryUpdated:Fire(player, { Action = "Added", Item = item })
end

function ItemService:RemoveItemFromInventory(player: Player, instanceId: string)
    if not Inventories[player] then return end
    Inventories[player][instanceId] = nil
    self.Client.InventoryUpdated:Fire(player, { Action = "Removed", InstanceId = instanceId })
end

-- ==========================================
-- 장착 관리
-- ==========================================

--[[
    장비 착용
--]]
function ItemService:EquipItem(player: Player, instanceId: string): (boolean, string?)
    local inv = Inventories[player]
    if not inv then return false, "인벤토리 없음" end

    local item = inv[instanceId]
    if not item then return false, "아이템 없음" end

    local itemBase = ItemData.Get(item.ItemId)

    -- 역할 제한 확인
    if itemBase.AllowedRoles then
        local playerRole = player:GetAttribute("Role")
        local allowed = false
        for _, role in ipairs(itemBase.AllowedRoles) do
            if role == playerRole then allowed = true break end
        end
        if not allowed then return false, "해당 클래스 착용 불가" end
    end

    -- 레벨 제한 확인
    local playerLevel = player:GetAttribute("Level") or 1
    if playerLevel < (itemBase.RequiredLevel or 1) then
        return false, "레벨 부족"
    end

    if not EquippedItems[player] then EquippedItems[player] = {} end

    -- 기존 장착 해제
    local slot = item.Type  -- "Weapon" | "Armor" | "Accessory"
    if EquippedItems[player][slot] then
        self:UnequipItem(player, slot)
    end

    EquippedItems[player][slot] = item
    self:ApplyEquipmentStats(player)
    self.Client.InventoryUpdated:Fire(player, { Action = "Equipped", Item = item, Slot = slot })
    return true, nil
end

--[[
    장비 해제
--]]
function ItemService:UnequipItem(player: Player, slot: string)
    if not EquippedItems[player] then return end
    EquippedItems[player][slot] = nil
    self:ApplyEquipmentStats(player)
    self.Client.InventoryUpdated:Fire(player, { Action = "Unequipped", Slot = slot })
end

--[[
    장착된 모든 장비 스탯 합산 → 플레이어 속성 업데이트
--]]
function ItemService:ApplyEquipmentStats(player: Player)
    local equipped = EquippedItems[player] or {}
    local totalBonus: { [string]: number } = {}

    for _, item in pairs(equipped) do
        if item then
            -- 기본 스탯
            for stat, value in pairs(item.BaseStats) do
                totalBonus[stat] = (totalBonus[stat] or 0) + value
            end
            -- 랜덤 옵션
            for _, option in ipairs(item.RandomOptions) do
                totalBonus[option.Type] = (totalBonus[option.Type] or 0) + option.Value
            end
            -- 강화 보너스
            if item.Enhancement > 0 then
                local enhBonus = DropGenerator.CalculateEnhancementBonus(
                    item.BaseStats, item.Enhancement, item.Rarity
                )
                for stat, value in pairs(enhBonus) do
                    totalBonus[stat] = (totalBonus[stat] or 0) + value
                end
            end
        end
    end

    -- TODO: ClassService 기본 스탯과 합산하여 최종 스탯 설정
    for stat, value in pairs(totalBonus) do
        player:SetAttribute("Equipment_" .. stat, value)
    end
end

-- ==========================================
-- 강화 시스템
-- ==========================================

-- 강화 성공 확률 테이블
local ENHANCE_RATES = { 1,1,1,1,1, 0.8,0.8,0.8,0.8, 0.6,0.6,0.6, 0.3,0.3, 0.15 }
-- 실패 시 강화 수치 감소량
local ENHANCE_FAIL_PENALTY = { 0,0,0,0,0, 0,0,0,0, -1,-1,-1, -2,-2, -3 }

function ItemService:EnhanceItem(player: Player, instanceId: string): { Success: boolean, NewEnhancement: number }
    local inv = Inventories[player]
    if not inv or not inv[instanceId] then
        return { Success = false, NewEnhancement = 0 }
    end

    local item = inv[instanceId]
    local currentStep = item.Enhancement
    if currentStep >= 15 then
        return { Success = false, NewEnhancement = 15 }
    end

    local successRate = ENHANCE_RATES[currentStep + 1] or 0.1
    local success = math.random() < successRate

    if success then
        item.Enhancement = currentStep + 1
    else
        local penalty = ENHANCE_FAIL_PENALTY[currentStep + 1] or 0
        item.Enhancement = math.max(0, currentStep + penalty)
    end

    self.Client.InventoryUpdated:Fire(player, { Action = "Enhanced", Item = item, Success = success })
    return { Success = success, NewEnhancement = item.Enhancement }
end

-- ==========================================
-- 클라이언트 요청
-- ==========================================

function ItemService.Client:GetInventory(player: Player)
    return ItemService:GetInventory(player)
end

function ItemService.Client:EquipItem(player: Player, instanceId: string)
    return ItemService:EquipItem(player, instanceId)
end

function ItemService.Client:UnequipItem(player: Player, slot: string)
    ItemService:UnequipItem(player, slot)
end

function ItemService.Client:EnhanceItem(player: Player, instanceId: string)
    return ItemService:EnhanceItem(player, instanceId)
end

-- ==========================================
-- Knit 생명주기
-- ==========================================

function ItemService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        Inventories[player]   = {}
        EquippedItems[player] = {}
    end)

    Players.PlayerRemoving:Connect(function(player)
        -- TODO: DataStore에 저장
        Inventories[player]   = nil
        EquippedItems[player] = nil
    end)
end

function ItemService:KnitStart()
    print("[ItemService] 시작됨")
end

return ItemService
