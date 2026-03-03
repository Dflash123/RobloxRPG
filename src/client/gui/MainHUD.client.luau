--[[
    MainHUD.client.luau
    [DUMMY] 메인 전투 HUD

    역할: 플레이어 HP/MP 바, 스킬 쿨다운, 레벨/경험치 표시

    예상 ScreenGui 계층 구조:
    ScreenGui (MainHUD)
    └── Frame (Container) [AnchorPoint: 0.5,1  Position: 0.5,0, 0,0  Size: 0.6,0, 0.2,0]
        ├── HPBar (Frame)
        │   ├── Fill (Frame)  ← HP 비율만큼 너비 변경
        │   └── Label (TextLabel)  "500 / 1000"
        ├── MPBar (Frame)
        │   ├── Fill (Frame)
        │   └── Label (TextLabel)
        ├── ExpBar (Frame)  [화면 하단 얇은 바]
        │   └── Fill (Frame)
        └── SkillBar (Frame)
            ├── Skill1 (ImageButton)  Q키
            │   ├── Icon (ImageLabel)
            │   └── CooldownOverlay (Frame)  ← 반투명 덮개
            ├── Skill2 (ImageButton)  W키
            ├── Skill3 (ImageButton)  E키
            └── Skill4 (ImageButton)  R키

    구현 시 참고:
    - HP/MP 바: TweenService로 부드럽게 변화
    - 쿨다운: RunService.Heartbeat로 오버레이 크기 갱신
    - UIController:UpdateHPBar(), UpdateMPBar(), UpdateSkillCooldown() 연결
--]]

-- TODO: 직접 UI 구현 예정
print("[MainHUD] Initialized (dummy)")
