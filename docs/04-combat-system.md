# 전투 시스템 (Combat System)

## 데미지 계산 공식

```
최종 데미지 = max(1, (AttackPower × SkillMultiplier) - Defense)

크리티컬 시:
최종 데미지 = max(1, (AttackPower × SkillMultiplier × CritMultiplier) - Defense)
```

### 스탯 설명

| 스탯 | 설명 |
|------|------|
| AttackPower | 기본 공격력 (클래스 + 장비 합산) |
| SkillMultiplier | 스킬별 배율 (SkillData에서 정의) |
| Defense | 방어력 (피해 감소 고정값) |
| CritRate | 크리티컬 발동 확률 (%) |
| CritMultiplier | 크리티컬 피해 배율 (기본 1.5x) |

## 서버 검증 흐름

```lua
-- CombatService 처리 순서
function CombatService.HandleSkillUse(player, skillId, targetId)
    -- 1. 플레이어 유효성 검사
    -- 2. 쿨다운 검증 (서버 타임스탬프 비교)
    -- 3. MP 소모 검증
    -- 4. 타겟 유효성 검증 (같은 인스턴스 내 존재)
    -- 5. 데미지 계산
    -- 6. 어그로 업데이트
    -- 7. 적 HP 적용
    -- 8. 사망 처리 또는 결과 브로드캐스트
end
```

## 어그로 시스템

### 어그로 테이블 구조
```lua
AggroTable[enemyId] = {
    [player1] = 1500,  -- 어그로 수치
    [player2] = 800,
    [player3] = 200,
}
```

### 어그로 발생 규칙
- 피해를 가할 때: `피해량 × 1.0` 어그로 발생
- 힐 적용 시: `힐량 × 0.5` 어그로 발생 (힐러 보호)
- 도발 스킬: 탱커에게 어그로 강제 집중
- 탱커 공격: 어그로 배율 추가 적용 (AggroMultiplier)

### 타겟팅 결정
```lua
-- 어그로 최고값 플레이어가 타겟
local function GetHighestAggro(aggroTable)
    local maxAggro = 0
    local target = nil
    for player, aggro in pairs(aggroTable) do
        if aggro > maxAggro then
            maxAggro = aggro
            target = player
        end
    end
    return target
end
```

## 상태이상 시스템

| 상태이상 | 효과 | 해제 조건 |
|---------|------|-----------|
| Stun | 행동 불가 | 지속시간 종료 |
| Slow | 이동속도 50% 감소 | 지속시간 종료 |
| Burn | 매 초 DoT 피해 | 지속시간 종료 / 힐러 정화 |
| Silence | 스킬 사용 불가 | 지속시간 종료 |
| Taunt | 강제로 특정 타겟 공격 | 지속시간 종료 |

## 쿨다운 검증

```lua
-- 서버에서 마지막 스킬 사용 시간을 기록
CooldownTracker[player][skillId] = os.time()

-- 검증 시
local lastUsed = CooldownTracker[player][skillId] or 0
local cooldown = SkillData[skillId].Cooldown
if os.time() - lastUsed < cooldown then
    return false, "쿨다운 중"
end
```

## 역할 기반 메카닉

특정 보스 패턴은 특정 역할을 요구합니다:

```lua
-- 보스 패턴 예시
Pattern = {
    TriggerHP    = 0.5,
    Action       = "TankBuster",  -- 탱커만 처리 가능
    RequiresRole = "Tank",
    Description  = "탱커가 앞에 서지 않으면 파티 전체 즉사"
}
```

파티에 해당 역할이 없으면 패턴 클리어 불가 → 던전 실패
