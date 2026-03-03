# DataStore 사용법

DataStoreService는 **서버 Script에서만** 사용 가능.

## 기본 패턴

```lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- 버전 관리: 스키마 변경 시 이름 변경 (v1 → v2)
local playerStore = DataStoreService:GetDataStore("PlayerData_v1")

local DEFAULT_DATA = {
    coins     = 0,
    gems      = 0,
    level     = 1,
    exp       = 0,
    inventory = {},
    settings  = { music = true, sfx = true },
}

-- 세션 캐시 (매 요청마다 DataStore 호출 방지)
local cache: {[number]: any} = {}
```

## 데이터 로드 (PlayerAdded)

```lua
local function loadData(player: Player): {[string]: any}
    local key = "player_" .. player.UserId
    local success, data = pcall(function()
        return playerStore:GetAsync(key)
    end)

    if not success then
        warn("[DataStore] 로드 실패:", data)
        -- 실패 시 기본값 반환 (플레이어 킥 또는 재시도 정책 결정 필요)
        return table.clone(DEFAULT_DATA)
    end

    -- 신규 플레이어 or 기존 데이터에 없는 필드 병합
    if data then
        for key, defaultVal in DEFAULT_DATA do
            if data[key] == nil then
                data[key] = defaultVal
            end
        end
        return data
    end

    return table.clone(DEFAULT_DATA)
end

Players.PlayerAdded:Connect(function(player: Player)
    local data = loadData(player)
    cache[player.UserId] = data

    -- leaderstats 설정
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coinsVal = Instance.new("IntValue")
    coinsVal.Name = "Coins"
    coinsVal.Value = data.coins
    coinsVal.Parent = leaderstats
end)
```

## 데이터 저장 (PlayerRemoving)

```lua
local function saveData(player: Player)
    local data = cache[player.UserId]
    if not data then return end

    local key = "player_" .. player.UserId
    local success, err = pcall(function()
        playerStore:SetAsync(key, data)
    end)

    if not success then
        warn("[DataStore] 저장 실패 (userId=" .. player.UserId .. "):", err)
    end

    cache[player.UserId] = nil
end

Players.PlayerRemoving:Connect(saveData)

-- 서버 종료 시 모든 플레이어 저장
game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        saveData(player)
    end
end)
```

## UpdateAsync (동시성 안전)

여러 서버가 동시에 같은 키를 수정할 때 충돌 방지.

```lua
-- 반드시 서버 간 공유 데이터(글로벌 리더보드 등)에 사용
local function addGlobalCoins(userId: number, amount: number)
    local key = "player_" .. userId
    local success, err = pcall(function()
        playerStore:UpdateAsync(key, function(oldData)
            local data = oldData or table.clone(DEFAULT_DATA)
            data.coins = (data.coins or 0) + amount
            return data
        end)
    end)

    if not success then
        warn("[DataStore] UpdateAsync 실패:", err)
    end
end
```

## 자동 저장 (주기적)

```lua
-- 5분마다 자동 저장
local AUTO_SAVE_INTERVAL = 300

task.spawn(function()
    while true do
        task.wait(AUTO_SAVE_INTERVAL)
        for _, player in Players:GetPlayers() do
            saveData(player)
            task.wait(0.1)  -- API 요청 간격 (throttle 방지)
        end
    end
end)
```

## OrderedDataStore (리더보드)

```lua
local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalCoins")

-- 점수 등록
local function submitScore(userId: number, score: number)
    pcall(function()
        leaderboardStore:SetAsync("user_" .. userId, score)
    end)
end

-- 상위 10명 조회
local function getTopPlayers(count: number): {{name: string, score: number}}
    local success, pages = pcall(function()
        return leaderboardStore:GetSortedAsync(false, count)  -- false = 내림차순
    end)

    if not success then return {} end

    local results = {}
    local data = pages:GetCurrentPage()
    for _, entry in data do
        local name = Players:GetNameFromUserIdAsync(tonumber(entry.key:match("%d+")))
        table.insert(results, { name = name, score = entry.value })
    end
    return results
end
```

## API 제한 (Throttle)

| 작업 | 제한 |
|------|------|
| GetAsync / SetAsync | 60 + (10 × 플레이어 수) req/min |
| UpdateAsync | 위와 동일 |
| OrderedDataStore GetSortedAsync | 위와 동일 |

**실천 원칙**:
1. 세션 캐시를 사용하여 DataStore 호출 최소화
2. 플레이어 퇴장 시에만 저장 + 주기적 자동 저장
3. 플레이어 1명당 1개의 키로 모든 데이터 통합 저장
4. 재시도 로직 (pcall + 3회 재시도) 구현 권장
