# 수익화 (Robux / GamePass / Developer Product)

## 개요

| 유형 | 특징 | 용도 예시 |
|------|------|-----------|
| **GamePass** | 1회 구매, 영구 보유 | VIP, 특수 클래스 해금 |
| **Developer Product** | 반복 구매 가능 | 코인 패키지, 부활 아이템 |
| **Premium** | Roblox 월정액 구독자 혜택 | 보너스 보상, 전용 콘텐츠 |

**수익 구조**: 판매금의 70% 개발자 수령, 30% Roblox 수수료
**DevEx 조건**: 최소 30,000 Robux 보유 시 현금 환전 가능

---

## GamePass

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local PASS_IDS = {
    VIP       = 123456789,
    DoubleXP  = 234567890,
    ExtraSlot = 345678901,
}

-- 보유 여부 확인 (서버에서 호출 권장)
local function hasPass(player: Player, passId: number): boolean
    local success, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return success and result == true
end

-- 입장 시 패스 확인 및 혜택 적용
Players.PlayerAdded:Connect(function(player: Player)
    task.spawn(function()
        if hasPass(player, PASS_IDS.VIP) then
            applyVIPBenefits(player)
        end
        if hasPass(player, PASS_IDS.DoubleXP) then
            playerData[player.UserId].xpMultiplier = 2
        end
    end)
end)

-- 구매 프롬프트 (클라이언트 LocalScript)
local function promptPassPurchase(passId: number)
    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, passId)
end

-- 구매 완료 처리 (서버 Script)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(
    player: Player,
    passId: number,
    wasPurchased: boolean
)
    if not wasPurchased then return end

    if passId == PASS_IDS.VIP then
        applyVIPBenefits(player)
        notifyPurchase(player, "VIP 패스 구매 완료!")
    elseif passId == PASS_IDS.DoubleXP then
        playerData[player.UserId].xpMultiplier = 2
    end
end)
```

---

## Developer Product

반복 구매 가능한 소모성 아이템. **ProcessReceipt는 반드시 서버 Script에서 1개만 설정**.

```lua
local PRODUCT_IDS = {
    Coins100  = 1111111111,
    Coins1000 = 2222222222,
    Revive    = 3333333333,
}

local PRODUCT_REWARDS = {
    [PRODUCT_IDS.Coins100]  = function(player) addCoins(player, 100) end,
    [PRODUCT_IDS.Coins1000] = function(player) addCoins(player, 1000) end,
    [PRODUCT_IDS.Revive]    = function(player) revivePlayer(player) end,
}

-- 구매 처리 (서버 Script — 게임 전체에서 1번만 등록)
MarketplaceService.ProcessReceipt = function(receiptInfo: {
    PlayerId: number,
    ProductId: number,
    PurchaseId: string,
})
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

    -- 플레이어가 서버에 없으면 처리 보류
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local handler = PRODUCT_REWARDS[receiptInfo.ProductId]
    if not handler then
        return Enum.ProductPurchaseDecision.PurchaseGranted  -- 알 수 없는 상품은 승인 처리
    end

    local success = pcall(handler, player)
    if success then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    else
        return Enum.ProductPurchaseDecision.NotProcessedYet  -- 실패 시 재시도
    end
end
```

---

## Premium 구독자 혜택

```lua
-- 플레이어가 Premium 구독자인지 확인
Players.PlayerAdded:Connect(function(player: Player)
    if player.MembershipType == Enum.MembershipType.Premium then
        applyPremiumBonuses(player)
        print(player.Name, "은 Premium 구독자입니다")
    end
end)

-- Premium 구독/해지 감지
player:GetPropertyChangedSignal("MembershipType"):Connect(function()
    if player.MembershipType == Enum.MembershipType.Premium then
        applyPremiumBonuses(player)
    end
end)

-- Premium 구독 유도 프롬프트 (LocalScript)
MarketplaceService:PromptPremiumPurchase(Players.LocalPlayer)
```

---

## 상점 UI 연동 패턴

```lua
-- LocalScript: 상점 버튼 클릭 → 서버에 구매 요청
local purchaseEvent = ReplicatedStorage.Events:WaitForChild("PurchaseEvent")

local function openShop()
    -- 아이템 목록 조회
    local items = getShopItemsFunc:InvokeServer()
    renderShopUI(items)
end

local function purchaseItem(itemId: string)
    -- GamePass면 Roblox 내장 프롬프트 사용
    if isGamePass(itemId) then
        MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, getPassId(itemId))
    else
        -- 인게임 재화(코인 등)로 구매
        purchaseEvent:FireServer(itemId)
    end
end
```

---

## 가격 책정 가이드

| Robux | 대략 USD | 권장 용도 |
|-------|----------|-----------|
| 50 R$ | $0.50 | 소형 패키지 |
| 200 R$ | $2.00 | 스타터팩 |
| 500 R$ | $5.00 | VIP 패스 |
| 1,000 R$ | $10.00 | 프리미엄 패스 |
| 2,000 R$ | $20.00 | 고가 패키지 |
