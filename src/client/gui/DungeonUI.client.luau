--[[
    DungeonUI.client.luau
    [DUMMY] 던전 선택 및 정보 UI

    역할:
    - 던전 목록 표시 (해금된 던전만)
    - 난이도 선택 (Normal/Hard/Extreme/Mythic)
    - 예상 보상 미리보기
    - 파티장만 시작 버튼 활성화

    예상 ScreenGui 계층 구조:
    ScreenGui (DungeonUI)  [기본 숨김, 특정 트리거 시 표시]
    └── Frame (Background) [화면 중앙]
        ├── Title (TextLabel)  "던전 선택"
        ├── DungeonList (ScrollingFrame)
        │   └── DungeonEntry × N개
        │       ├── Thumbnail (ImageLabel)
        │       ├── DungeonName (TextLabel)
        │       ├── RecommendedLevel (TextLabel)
        │       └── SelectButton (TextButton)
        ├── DifficultyPanel (Frame)  [던전 선택 후 표시]
        │   ├── DifficultyButtons (Frame)
        │   │   ├── Normal (TextButton)
        │   │   ├── Hard (TextButton)
        │   │   ├── Extreme (TextButton)
        │   │   └── Mythic (TextButton)
        │   └── RewardPreview (Frame)
        │       ├── ExpReward (TextLabel)
        │       └── ItemPreview (ScrollingFrame)
        ├── StartButton (TextButton)  [파티장만 활성화]
        └── CloseButton (TextButton)

    구현 시 참고:
    - DungeonData에서 던전 목록 로드
    - 파티장 여부: PartyController:GetCurrentParty().Leader == LocalPlayer.Name
    - 시작 버튼 클릭 → DungeonService:CreateInstance() 서버 요청
--]]

-- TODO: 직접 UI 구현 예정
print("[DungeonUI] Initialized (dummy)")
