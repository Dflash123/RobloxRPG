--[[
    init.server.luau
    서버 진입점 — Knit 초기화 및 모든 서비스 로드
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Wally로 설치된 Knit 패키지 로드
-- wally install 실행 후 Packages/ 폴더에 생성됨
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

-- 모든 서비스 일괄 등록
Knit.AddServices(ServerScriptService:WaitForChild("Services"))

-- Knit 시작 (모든 서비스의 KnitInit → KnitStart 순서로 호출됨)
Knit.Start():andThen(function()
    print("[Server] Knit 시작 완료 — 모든 서비스 로드됨")
end):catch(function(err)
    warn("[Server] Knit 시작 실패:", err)
end)
