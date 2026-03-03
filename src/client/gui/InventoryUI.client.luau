--[[
    InventoryUI.client.luau
    [DUMMY] 인벤토리 및 장비 UI

    역할:
    - 보유 아이템 목록 (등급별 색상 표시)
    - 장착 중인 슬롯 표시 (무기/방어구/장신구)
    - 아이템 클릭 → 상세 정보 (스탯, 랜덤 옵션)
    - 장착/해제 버튼
    - 강화 버튼 (강화 UI 진입)
    - 세트 효과 표시

    예상 ScreenGui 계층 구조:
    ScreenGui (InventoryUI)  [기본 숨김]
    └── Frame (Background)
        ├── EquipmentPanel (Frame)  [좌측]
        │   ├── WeaponSlot (ImageButton)  빈 슬롯 / 아이템 아이콘
        │   ├── ArmorSlot (ImageButton)
        │   └── AccessorySlot (ImageButton)
        ├── InventoryGrid (ScrollingFrame)  [우측]
        │   └── ItemSlot × N개
        │       ├── ItemIcon (ImageLabel)
        │       ├── RarityBorder (Frame)  등급 색상 테두리
        │       └── EnhancementLabel (TextLabel)  "+5" 등
        ├── ItemDetailPanel (Frame)  [하단, 아이템 선택 시 표시]
        │   ├── ItemName (TextLabel)
        │   ├── ItemStats (TextLabel)  기본 스탯
        │   ├── RandomOptions (Frame)  랜덤 옵션 목록
        │   ├── EquipButton (TextButton)
        │   └── EnhanceButton (TextButton)
        └── CloseButton (TextButton)

    등급별 색상:
    - Common:    rgb(180, 180, 180)  회색
    - Rare:      rgb(80, 120, 255)   파랑
    - Epic:      rgb(160, 60, 255)   보라
    - Legendary: rgb(255, 140, 0)    주황
    - Mythic:    rgb(255, 40, 40)    빨강

    구현 시 참고:
    - ItemService:GetInventory() → 아이템 목록 로드
    - 아이템 클릭 → DetailPanel 갱신
    - 강화 버튼 → EnhanceUI 서브패널 표시
--]]

-- TODO: 직접 UI 구현 예정
print("[InventoryUI] Initialized (dummy)")
