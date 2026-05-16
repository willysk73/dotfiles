# C / C++ conventions

## 도구

- 포매터: `clang-format` (프로젝트 `.clang-format` 따름. 없으면 LLVM/Google style 추론 후 본인 확인).
- 린터: `clang-tidy` (프로젝트 `.clang-tidy` 우선).
- 빌드: CMake (3.20+) > Make. 프로젝트 빌드 시스템 우선.
- 테스트: GoogleTest 또는 Catch2. 프로젝트 컨벤션 따름.
- 컴파일러 경고: `-Wall -Wextra -Wpedantic -Werror` 권장. 기존 코드베이스 도입은 점진적.
- 메모리 검증: Debug 빌드는 `-fsanitize=address,undefined`.

## C++ (모던 C++17/20 우선)

- RAII 항상. raw `new`/`delete` 회피 — `std::unique_ptr`, `std::make_unique`.
- `auto` 적극 사용 (의도가 명확할 때).
- range-based for, structured binding, `if constexpr` 활용.
- `std::string_view`, `std::span` 으로 view 전달 (소유권 없는 경우).
- header-only 인라인 함수 외에는 `.h`/`.cpp` 분리.
- `constexpr`/`consteval` 적극 — 런타임 비용 절감.

## C (C11+)

- 메모리: `malloc` 직후 NULL 체크. `free` 후 포인터 NULL 처리.
- 문자열: `strncpy`/`strncat`/`snprintf` (size 명시). `gets`, `strcpy`, `sprintf` 절대 금지.
- 함수 시그니처: `void f(void)` 명시 (C에서 `f()`는 unspecified args).
- `restrict` 키워드로 alias 가정 명시 (성능 hot path).

## 금기

- C-style cast (`(int)x`) — `static_cast`/`reinterpret_cast`/`const_cast` 사용.
- `using namespace std;` 헤더에서 절대. 구현 파일에서도 회피 권장.
- raw owning 포인터. raw non-owning(observer)은 OK.
- `#define` 상수 (C++) — `constexpr` 또는 `enum class` 사용.
- 헤더에 inline 아닌 함수 정의 (ODR violation).
- exception을 일반 control flow에 사용.

## 검증

```bash
clang-format -i src/**/*.{h,hpp,cpp,c}
clang-tidy src/file.cpp -- -Iinclude
cmake --build build && ctest --test-dir build --output-on-failure
```
