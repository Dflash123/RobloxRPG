# Luau 언어 기초

Lua 5.1 기반의 Roblox 전용 확장 언어. 정적 타입 추론, 문자열 보간, 성능 개선이 추가됨.

## 변수 & 타입 어노테이션

```lua
-- 로컬 변수 (스코프 제한, 항상 local 사용)
local name: string = "Player"
local score: number = 0
local isAlive: boolean = true
local nothing: nil = nil

-- 타입 정의 (Luau 고유)
type PlayerData = {
    userId: number,
    name: string,
    level: number,
    coins: number,
}

-- 문자열 보간 (Luau 고유, 백틱 사용)
local msg = `Hello {name}! Score: {score}`

-- 타입 캐스팅
local val = something :: string
```

## 함수

```lua
-- 기본 함수
local function add(a: number, b: number): number
    return a + b
end

-- 가변 인수
local function sum(...: number): number
    local total = 0
    for _, v in {...} do
        total += v
    end
    return total
end

-- 다중 반환
local function minmax(t: {number}): (number, number)
    local min, max = math.huge, -math.huge
    for _, v in t do
        if v < min then min = v end
        if v > max then max = v end
    end
    return min, max
end

local lo, hi = minmax({3, 1, 4, 1, 5})
```

## 테이블 (배열 + 딕셔너리)

```lua
-- 배열 (1-indexed)
local items: {string} = {"Sword", "Shield", "Potion"}
table.insert(items, "Bow")
table.remove(items, 1)
print(#items)  -- 길이

-- 딕셔너리
local stats: {[string]: number} = {
    attack = 10,
    defense = 5,
    speed = 16,
}

-- 반복
for i, item in ipairs(items) do      -- 배열용 (순서 보장)
    print(i, item)
end

for key, val in pairs(stats) do      -- 딕셔너리용
    print(key, val)
end

-- 테이블 복사 (shallow)
local copy = table.clone(original)

-- 테이블 정렬
table.sort(items, function(a, b) return a < b end)
```

## 조건문 & 반복문

```lua
-- 삼항 연산자 대체 패턴
local result = condition and trueValue or falseValue

-- 범위 for
for i = 1, 10 do print(i) end
for i = 10, 1, -1 do print(i) end  -- 역순

-- while
local count = 0
while count < 5 do
    count += 1
end

-- repeat-until
repeat
    count -= 1
until count <= 0
```

## 오류 처리

```lua
-- pcall: 오류를 캐치하여 false + 메시지 반환
local success, result = pcall(function()
    return dangerousOperation()
end)

if not success then
    warn("오류:", tostring(result))
    return
end

-- xpcall: 스택 트레이스 포함
local ok, err = xpcall(function()
    error("something went wrong")
end, function(msg)
    return debug.traceback(msg, 2)
end)
```

## 메타테이블 (OOP 기반)

```lua
local Animal = {}
Animal.__index = Animal

function Animal.new(name: string, sound: string)
    return setmetatable({
        name = name,
        sound = sound,
    }, Animal)
end

function Animal:speak()
    print(self.name .. " says " .. self.sound)
end

-- 상속
local Dog = setmetatable({}, {__index = Animal})
Dog.__index = Dog

function Dog.new(name: string)
    local self = Animal.new(name, "Woof")
    return setmetatable(self, Dog)
end

function Dog:fetch(item: string)
    print(self.name .. " fetches " .. item)
end

local rex = Dog.new("Rex")
rex:speak()   -- Animal 메서드 상속
rex:fetch("ball")
```

## task 라이브러리 (코루틴 대체)

```lua
-- 지연 실행
task.delay(2, function()
    print("2초 후 실행")
end)

-- 다음 프레임에 실행
task.defer(function()
    print("다음 프레임")
end)

-- 비동기 대기
task.spawn(function()
    task.wait(1)   -- 1초 대기 (coroutine.yield 대신 사용)
    print("1초 후")
end)

-- 주의: wait() 대신 task.wait() 사용 권장 (정밀도 향상)
```

## 유용한 내장 함수

```lua
-- 수학
math.floor(3.7)      -- 3
math.ceil(3.2)       -- 4
math.clamp(x, 0, 100)
math.random(1, 10)   -- 1~10 랜덤 정수
math.huge            -- 무한대

-- 문자열
string.format("%.2f", 3.14159)  -- "3.14"
string.len("hello")             -- 5
string.upper("hello")           -- "HELLO"
string.split("a,b,c", ",")      -- {"a","b","c"}
string.find("hello world", "world")  -- 7, 11

-- 타입 확인
type(value)          -- "number", "string", "table", "boolean", "nil", "function"
typeof(instance)     -- "Instance", "Vector3", "CFrame" 등 Roblox 타입 포함
```
