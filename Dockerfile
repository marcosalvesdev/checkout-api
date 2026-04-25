FROM python:3.12-slim as builder

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN uv sync --no-dev --frozen

COPY src/ ./src

FROM python:3.12-slim as runtime

WORKDIR /app

COPY --from=builder /app/.venv ./.venv

COPY --from=builder /app/src ./src

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/src"

CMD ["uvicorn", "checkout.infrastructure.http.main:app", "--host", "0.0.0.0", "--port", "8000"]
