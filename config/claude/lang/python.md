# Python conventions

## 도구

- 포매터·린터: `ruff format` + `ruff check --fix`. black/isort/flake8 신규 도입 금지 — ruff 단일.
- 타입 체커: `mypy --strict` 또는 `pyright`. 프로젝트 설정 우선. 새 코드는 type hint 필수.
- 테스트: `pytest`. 신규 코드에서 unittest는 회피.
- 패키지: `uv` 또는 `pdm` (`pyproject.toml` 기준). 글로벌 `pip install` 금지.
- 가상환경: `.venv/` 프로젝트 로컬 (`uv venv` 또는 `python -m venv .venv`).

## 스타일

- type hint 필수. `Optional[X]` 보다 `X | None` (Python 3.10+).
- `dataclasses` > 평범한 클래스 > dict. immutable 필요 시 `@dataclass(frozen=True)`.
- f-string > `.format()` > `%`. 로깅은 lazy formatting (`logger.info("x=%s", x)`).
- 예외는 구체 클래스. `except Exception:` 회피, 잡으면 re-raise 또는 명시적 처리.
- `pathlib.Path` > `os.path` 문자열 조작.
- import는 `from x import y` 절대경로 우선. 같은 패키지 내에서만 상대 import.

## 금기

- mutable default arg (`def f(x=[])`) — 절대.
- `from x import *` — 절대.
- `print()` 디버깅 코드 커밋 금지. 디버깅엔 `breakpoint()`.
- `requirements.txt` 신규 생성 금지 — `pyproject.toml` 사용.
- `__init__.py`에 로직 — 명시 요청 시에만 (sub-import 정도만 허용).

## 검증 명령 (작업 후 실행)

```bash
ruff format . && ruff check --fix . && mypy . && pytest
```

프로젝트에 tox/nox/Makefile/`pyproject.toml [tool.poe]` 있으면 그것 우선.
