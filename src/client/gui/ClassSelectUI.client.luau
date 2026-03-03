--[[
    ClassSelectUI.client.luau
    [DUMMY] 클래스 선택 UI

    역할:
    - 게임 최초 접속 또는 클래스 미설정 시 표시
    - 선택 가능한 클래스 목록 (Tank/DPS/Healer)
    - 각 클래스 기본 스탯 미리보기
    - 스킬 목록 미리보기
    - 확인 버튼 클릭 → ClassService에 클래스 설정 요청

    예상 ScreenGui 계층 구조:
    ScreenGui (ClassSelectUI)
    └── Frame (Background) [화면 전체 덮음]
        ├── Title (TextLabel)  "클래스를 선택하세요"
        ├── ClassCards (Frame)  [수평 배열]
        │   ├── WarriorCard (Frame)
        │   │   ├── ClassIcon (ImageLabel)
        │   │   ├── ClassName (TextLabel)  "워리어"
        │   │   ├── RoleTag (TextLabel)    "TANK"
        │   │   ├── Description (TextLabel)
        │   │   ├── StatPreview (Frame)
        │   │   │   ├── HP Bar (미리보기)
        │   │   │   ├── ATK Bar
        │   │   │   └── DEF Bar
        │   │   └── SkillList (Frame)
        │   ├── BerserkerCard (Frame)
        │   └── PriestCard (Frame)
        └── ConfirmButton (TextButton)  [카드 선택 후 활성화]

    구현 시 참고:
    - ClassData.GetAll()로 클래스 목록 동적 로드
    - 새 클래스 추가 시 카드 자동 생성 가능하도록 구현
    - 선택된 카드 강조 표시 (테두리 색 변경)
    - 확인 → ClassService.Client:SelectClass(classId) 호출
    - 완료 후 이 UI 숨김, 메인 게임 진입
--]]

-- TODO: 직접 UI 구현 예정
print("[ClassSelectUI] Initialized (dummy)")
