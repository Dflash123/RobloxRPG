# Roblox 개발 참고 자료 인덱스

> 로블록스 게임 개발 시 필요한 핵심 개념과 코드 예제 모음

## 파일 목록

| 파일 | 내용 |
|------|------|
| [01-studio-structure.md](./01-studio-structure.md) | Studio 구조, Data Model 계층, 인스턴스 생성, 태그 시스템 |
| [02-luau-basics.md](./02-luau-basics.md) | Luau 문법, 타입 어노테이션, 테이블, OOP 메타테이블, task 라이브러리 |
| [03-client-server.md](./03-client-server.md) | Script/LocalScript/ModuleScript 구분, RemoteEvent, RemoteFunction, 보안 체크리스트 |
| [04-core-services.md](./04-core-services.md) | Players, RunService, TweenService, UserInputService, PathfindingService, HttpService |
| [05-datastore.md](./05-datastore.md) | 데이터 로드/저장, UpdateAsync, 자동 저장, OrderedDataStore (리더보드) |
| [06-physics-gui.md](./06-physics-gui.md) | BasePart 속성, Raycast, Humanoid, ScreenGui, BillboardGui, UDim2 |
| [07-animation.md](./07-animation.md) | Animator, AnimationTrack, 우선순위, 키프레임 마커, NPC 애니메이션 |
| [08-module-patterns.md](./08-module-patterns.md) | ModuleScript 패턴, OOP 클래스, 싱글톤 서비스, 프로젝트 구조 레이아웃 |
| [09-monetization.md](./09-monetization.md) | GamePass, Developer Product, Premium 혜택, 가격 책정 |
| [10-useful-links.md](./10-useful-links.md) | 공식 문서, 오픈소스 라이브러리, 무료 에셋, 개발 도구, Rojo 설정 |

## 핵심 원칙 요약

1. **보안** — 클라이언트 데이터는 절대 신뢰하지 말고 서버에서 검증
2. **통신** — Client↔Server 통신은 RemoteEvent(단방향) / RemoteFunction(양방향)만 사용
3. **데이터** — DataStore는 서버 전용, 세션 캐시로 API 요청 최소화
4. **구조** — ModuleScript로 서비스 분리, init.server.lua / init.client.lua 진입점 패턴
5. **성능** — Heartbeat(서버/공용), RenderStepped(클라이언트 렌더링)로 루프 구분
