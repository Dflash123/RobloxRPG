--[[
    init.client.luau
    클라이언트 진입점 — Knit 초기화 및 모든 컨트롤러 로드
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

-- 모든 컨트롤러 일괄 등록
Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

-- Knit 시작
Knit.Start():andThen(function()
    print("[Client] Knit 시작 완료 — 모든 컨트롤러 로드됨")
end):catch(function(err)
    warn("[Client] Knit 시작 실패:", err)
end)
