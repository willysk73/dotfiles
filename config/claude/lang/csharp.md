# C# conventions

## 도구

- SDK: .NET 8 LTS 또는 .NET 9. `global.json`으로 버전 고정 권장.
- 포매터: `dotnet format` (`.editorconfig` 기반).
- 린터: Roslyn analyzers. `Microsoft.CodeAnalysis.NetAnalyzers` 패키지 권장.
- 테스트: xUnit (선호) 또는 NUnit. MSTest 신규 도입 회피.
- nullable reference types: `<Nullable>enable</Nullable>` 신규 프로젝트 필수.
- IDE: Rider/VS — `.editorconfig` 항상 우선.

## 스타일 (C# 12+)

- file-scoped namespace, primary constructor, collection expression `[1, 2, 3]`, `record` for DTO.
- `var` 우선 (타입이 우측에 명확할 때). 명시 타입은 가독성 살릴 때.
- expression-bodied member 짧은 함수에 활용.
- LINQ 적극 사용. 단, hot path는 plain loop.
- `using` declaration (C# 8+) 으로 dispose 자동화.

## Async / Threading

- `.Result`, `.Wait()` 절대 금지 — deadlock 위험. `await` 사용.
- async 메서드는 `Async` 접미사 + `Task<T>` 반환. `async void`는 이벤트 핸들러 한정.
- `ConfigureAwait(false)`: 라이브러리 코드에서 사용, 앱 코드에선 생략.
- `CancellationToken` 항상 propagate.
- `Task.Run` 남발 금지 — CPU bound 작업 한정.

## 금기

- `catch (Exception ex) { }` 빈 catch — 절대.
- `throw ex;` (스택 트레이스 손실) — `throw;`만.
- string concatenation 루프 — `StringBuilder` 또는 `string.Join`.
- public field — `{ get; init; }` 또는 `{ get; set; }` property 사용.
- nullable 무시 (`!` null-forgiving 연산자 남용) — null check 또는 `ArgumentNullException.ThrowIfNull`.
- `dynamic` — 명시적 정당화 필요.

## 검증

```bash
dotnet format && dotnet build -warnaserror && dotnet test
```
