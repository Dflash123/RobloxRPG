--[[
    DamageCalculator.luau
    데미지 계산 공식 모듈 (서버/클라이언트 공유)
    서버에서만 실제 피해 적용 — 이 모듈은 계산만 담당
--]]

local DamageCalculator = {}

-- 기본 상수
local MIN_DAMAGE = 1
local BASE_CRIT_MULTIPLIER = 1.5

--[[
    기본 피해량 계산
    공식: max(MIN_DAMAGE, (AttackPower × SkillMultiplier) - Defense)
--]]
function DamageCalculator.Calculate(params: {
    AttackPower: number,
    SkillMultiplier: number,
    Defense: number,
    CritRate: number?,
    CritDamage: number?,
}): { Damage: number, IsCrit: boolean }

    local atk  = params.AttackPower
    local mult = params.SkillMultiplier
    local def  = params.Defense
    local critRate   = params.CritRate   or 0
    local critDamage = params.CritDamage or BASE_CRIT_MULTIPLIER

    -- 크리티컬 판정 (서버에서 처리 — 클라이언트 신뢰 불가)
    local isCrit = math.random() < critRate

    -- 데미지 계산
    local rawDamage = (atk * mult) - def
    if isCrit then
        rawDamage = rawDamage * critDamage
    end

    local finalDamage = math.max(MIN_DAMAGE, math.floor(rawDamage))

    return {
        Damage = finalDamage,
        IsCrit = isCrit,
    }
end

--[[
    힐량 계산
    공식: max(1, HealPower × SkillMultiplier)
--]]
function DamageCalculator.CalculateHeal(params: {
    HealPower: number,
    SkillMultiplier: number,
}): number

    local heal = params.HealPower * params.SkillMultiplier
    return math.max(1, math.floor(heal))
end

--[[
    방어력 감소율 계산 (선택적 — 방어력을 % 감소로 쓸 때)
    현재는 고정값 감소 방식을 기본으로 사용
--]]
function DamageCalculator.DefenseReduction(defense: number, baseDamage: number): number
    -- 현재 방식: 고정값 감소
    return math.max(MIN_DAMAGE, baseDamage - defense)
end

--[[
    난이도 배율 적용
--]]
function DamageCalculator.ApplyDifficultyScale(baseDamage: number, scale: number): number
    return math.floor(baseDamage * scale)
end

return DamageCalculator
