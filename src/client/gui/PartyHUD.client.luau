--[[
    PartyHUD.client.luau
    [DUMMY] 파티원 상태 HUD

    역할: 파티원 목록, 각 멤버의 HP/MP 바, 역할 아이콘, 상태이상 표시

    예상 ScreenGui 계층 구조:
    ScreenGui (PartyHUD)
    └── Frame (PartyList) [좌측 상단 고정]
        ├── MemberFrame × 최대 4개 (각 파티원)
        │   ├── RoleIcon (ImageLabel)  Tank/DPS/Healer 아이콘
        │   ├── PlayerName (TextLabel)
        │   ├── HPBar (Frame)
        │   │   └── Fill (Frame)
        │   ├── MPBar (Frame)
        │   │   └── Fill (Frame)
        │   └── StatusEffects (Frame)  상태이상 아이콘들
        └── (멤버 없을 때 숨김)

    구현 시 참고:
    - PartyController.PartyUpdated 이벤트 수신 시 갱신
    - 본인 프레임은 약간 강조 표시
    - 파티원 사망 시 프레임 회색 처리
    - 힐러: 파티원 HP 바 클릭 → 타겟 설정
--]]

-- TODO: 직접 UI 구현 예정
print("[PartyHUD] Initialized (dummy)")
