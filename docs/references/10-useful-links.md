# 유용한 링크 & 리소스

## 공식 문서

| 카테고리 | URL |
|----------|-----|
| Creator Hub 메인 | https://create.roblox.com/docs |
| 시작하기 튜토리얼 | https://create.roblox.com/docs/get-started |
| Engine API 레퍼런스 | https://create.roblox.com/docs/reference/engine |
| Luau 언어 레퍼런스 | https://create.roblox.com/docs/luau |
| Studio 사용법 | https://create.roblox.com/docs/studio |
| 튜토리얼 모음 | https://create.roblox.com/docs/tutorials |

## 핵심 API 페이지

| API | URL |
|-----|-----|
| RemoteEvent | https://create.roblox.com/docs/scripting/events/remote |
| DataStore | https://create.roblox.com/docs/cloud-services/data-stores |
| GamePass 수익화 | https://create.roblox.com/docs/production/monetization/game-passes |
| Developer Product | https://create.roblox.com/docs/production/monetization/developer-products |
| TweenService | https://create.roblox.com/docs/reference/engine/classes/TweenService |
| PathfindingService | https://create.roblox.com/docs/reference/engine/classes/PathfindingService |
| Humanoid | https://create.roblox.com/docs/reference/engine/classes/Humanoid |
| Animator | https://create.roblox.com/docs/reference/engine/classes/Animator |

## 커뮤니티 & 포럼

| 이름 | URL | 용도 |
|------|-----|------|
| Developer Forum | https://devforum.roblox.com | 질문/답변, 뉴스 |
| Luau 공식 사이트 | https://luau.org | 언어 스펙 |
| Creator Hub 깃허브 | https://github.com/Roblox/creator-docs | 문서 오픈소스 |
| Roblox API (비공식) | https://robloxapi.github.io/ref | 빠른 API 검색 |

## 유용한 오픈소스 라이브러리

| 라이브러리 | URL | 설명 |
|------------|-----|------|
| **Knit** | https://github.com/Sleitnick/Knit | 서비스/컨트롤러 프레임워크 |
| **ProfileService** | https://github.com/MadStudioRoblox/ProfileService | DataStore 래퍼, 세션 잠금 지원 |
| **ReplicaService** | https://github.com/MadStudioRoblox/ReplicaService | 서버→클라이언트 데이터 동기화 |
| **Signal** | https://github.com/Quenty/NevermoreEngine | 이벤트 시스템 |
| **Roact** | https://github.com/Roblox/roact | React 스타일 UI 프레임워크 |
| **Rodux** | https://github.com/Roblox/rodux | Redux 스타일 상태 관리 |
| **Cmdr** | https://github.com/evaera/Cmdr | 개발자 명령어 시스템 |
| **Wally** | https://github.com/UpliftGames/wally | Roblox 패키지 매니저 |

## 무료 에셋 소스

| 이름 | URL | 종류 |
|------|-----|------|
| Roblox Marketplace | https://www.roblox.com/catalog | 모델, 애니메이션, 사운드 |
| Roblox Animation Library | Creator Hub 내 검색 | 기본 제공 애니메이션 |
| itch.io (게임 에셋) | https://itch.io/game-assets/free | 텍스처, UI, 사운드 |
| OpenGameArt | https://opengameart.org | CC 라이선스 에셋 |
| Freesound | https://freesound.org | 무료 사운드 이펙트 |

## 개발 도구

| 도구 | 설명 |
|------|------|
| **Roblox Studio** | 공식 IDE |
| **VS Code + Roblox LSP** | 외부 에디터 (타입 자동완성 지원) |
| **Rojo** | 파일 시스템 ↔ Studio 동기화 |
| **Argon** | Rojo 대안, 더 빠른 동기화 |
| **Selene** | Luau 정적 분석 linter |
| **StyLua** | Luau 코드 포맷터 |
| **TestEZ** | Roblox 전용 테스트 프레임워크 |

## Rojo 설정 (파일 기반 개발)

```json
// default.project.json
{
  "name": "RobloxRPG",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Services": {
        "$path": "src/ServerScriptService"
      }
    },
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Modules": {
        "$path": "src/ReplicatedStorage/Modules"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$path": "src/StarterPlayer/StarterPlayerScripts"
      }
    }
  }
}
```

## 자주 쓰는 rbxasset ID

| 용도 | Asset ID |
|------|----------|
| 기본 달리기 사운드 | rbxasset://sounds/action_footsteps_plastic.mp3 |
| 점프 사운드 | rbxasset://sounds/action_jump.mp3 |
| 사망 사운드 | rbxasset://sounds/uuhhh.mp3 |
| 기본 Idle 애니메이션 | rbxassetid://507766666 |
| 기본 Walk 애니메이션 | rbxassetid://507777826 |
| 기본 Run 애니메이션 | rbxassetid://507767714 |
| 기본 Jump 애니메이션 | rbxassetid://507765000 |
| 기본 Fall 애니메이션 | rbxassetid://507767968 |
