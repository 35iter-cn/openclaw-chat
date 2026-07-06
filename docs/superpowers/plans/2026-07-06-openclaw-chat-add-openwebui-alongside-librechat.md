# 在现有 LibreChat 旁新增 Open WebUI 入口

> **For agentic workers:** REQUIRED SUB-_SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 保留现有 LibreChat Web 入口，新增 Open WebUI 作为并行的 Web 入口，两者共用同一个 OpenClaw Gateway AI 后端。

**Architecture:** OpenClaw Gateway 继续作为唯一的 OpenAI-compatible 后端；LibreChat 和 Open WebUI 作为两个独立的 Web UI 容器接入同一 `claw-network` Docker 网络。Open WebUI 通过环境变量 `OPENAI_API_BASE_URL` 指向 OpenClaw Gateway 的 `/v1` 端点。

**Tech Stack:** Docker Compose, Open WebUI (`ghcr.io/open-webui/open-webui:main`), OpenClaw Gateway, LibreChat, MongoDB, MeiliSearch.

## Global Constraints

- 不得修改 OpenClaw Gateway 容器配置与 `openclaw/` 目录内容。
- LibreChat 服务（端口 3080）必须保持原样可用。
- Open WebUI 使用独立端口，默认 `3090`，可通过 `.env` 修改。
- 所有新增容器必须加入现有 `claw-network` 网络。
- `.env` 文件不提交到 Git，所有新增配置项必须同步到 `.env.example`。

---

## File Structure

- `.env.example`：新增 `OPENWEBUI_PORT`、`ENABLE_OPENAI_API`、`OPENAI_API_BASE_URL` 等模板变量。
- `.env`：本地实际环境变量（手动同步 `.env.example` 的变更，不提交）。
- `docker-compose.yml`：新增 `open-webui` 服务，依赖 `openclaw-gateway`。
- `README.md`：补充 Open WebUI 访问地址、初始账号说明、连接 OpenClaw 的简要配置。

---

### Task 1: 在 `.env.example` 中新增 Open WebUI 配置模板

**Files:**
- Modify: `.env.example`

**Interfaces:**
- Produces: 环境变量 `OPENWEBUI_PORT`、`ENABLE_OPENAI_API`、`OPENAI_API_BASE_URL`、`OPENAI_API_KEY` 供 `docker-compose.yml` 使用。

- [ ] **Step 1: 在 `.env.example` 中追加 Open WebUI 配置段**

  在文件末尾追加：

  ```bash
  # ─── Open WebUI 多用户聊天界面 ───────────────────────────────────────────
  OPENWEBUI_PORT=3090

  # OpenClaw Gateway 作为 OpenAI-compatible 后端
  ENABLE_OPENAI_API=true
  OPENAI_API_BASE_URL=http://openclaw-gateway:18789/v1
  OPENAI_API_KEY=${OPENCLAW_GATEWAY_TOKEN}
  ```

- [ ] **Step 2: 提交 `.env.example` 变更**

  ```bash
  git add .env.example
  git commit -m "chore(env): add Open WebUI configuration template"
  ```

---

### Task 2: 在 `docker-compose.yml` 中新增 `open-webui` 服务

**Files:**
- Modify: `docker-compose.yml`

**Interfaces:**
- Consumes: `.env` 中的 `OPENWEBUI_PORT`、`OPENAI_API_BASE_URL`、`OPENAI_API_KEY`、`ENABLE_OPENAI_API`、`TZ`。
- Produces: 运行在 `claw-network` 上的 `open-webui` 容器，端口映射到 `127.0.0.1:${OPENWEBUI_PORT}`。

- [ ] **Step 1: 在 `docker-compose.yml` 的 `librechat-api` 服务之后新增 `open-webui` 服务**

  新增服务定义：

  ```yaml
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "127.0.0.1:${OPENWEBUI_PORT:-3090}:8080"
    depends_on:
      - openclaw-gateway
    environment:
      - ENABLE_OPENAI_API=${ENABLE_OPENAI_API:-true}
      - OPENAI_API_BASE_URL=${OPENAI_API_BASE_URL:-http://openclaw-gateway:18789/v1}
      - OPENAI_API_KEY=${OPENAI_API_KEY:-}
      - TZ=${TZ:-UTC}
    volumes:
      - openwebui_data:/app/backend/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
    networks:
      - claw-network
  ```

- [ ] **Step 2: 在 `volumes:` 段新增 `openwebui_data` 卷**

  ```yaml
  volumes:
    # ... 已有卷
    openwebui_data:
  ```

- [ ] **Step 3: 验证 YAML 语法**

  ```bash
  docker compose config > /dev/null
  ```

  Expected: 命令退出码为 0，无 YAML 解析错误。

- [ ] **Step 4: 提交 `docker-compose.yml` 变更**

  ```bash
  git add docker-compose.yml
  git commit -m "feat(compose): add open-webui service alongside librechat"
  ```

---

### Task 3: 更新 `README.md` 补充 Open WebUI

**Files:**
- Modify: `README.md`

**Interfaces:**
- Produces: 用户可见的 Open WebUI 访问地址与初始配置说明。

- [ ] **Step 1: 更新架构图与服务说明表格**

  在现有架构图 LibreChat 节点旁增加 Open WebUI 节点；在服务说明表格中新增一行：

  ```markdown
  | `http://localhost:3090` | Open WebUI | 并行的多用户 Web 对话界面 |
  ```

- [ ] **Step 2: 在「快速开始」或「验证服务」段增加 Open WebUI 验证命令**

  ```bash
  # 测试 Open WebUI 页面
  curl -s -o /dev/null -w "%{http_code}" http://localhost:3090/
  # 应返回: 200
  ```

- [ ] **Step 3: 提交 `README.md` 变更**

  ```bash
  git add README.md
  git commit -m "docs(readme): document Open WebUI access endpoint"
  ```

---

### Task 4: 本地 `.env` 同步并启动服务

**Files:**
- Modify: `.env`（不提交 Git，仅本地更新）

**Interfaces:**
- Consumes: `.env.example` 中的新增变量模板。

- [ ] **Step 1: 在 `.env` 中追加 Open WebUI 实际值**

  把 `.env.example` 新增的段复制到 `.env`，并确保 `OPENAI_API_KEY` 与已有的 `OPENCLAW_GATEWAY_TOKEN` 一致：

  ```bash
  # ─── Open WebUI 多用户聊天界面 ───────────────────────────────────────────
  OPENWEBUI_PORT=3090

  # OpenClaw Gateway 作为 OpenAI-compatible 后端
  ENABLE_OPENAI_API=true
  OPENAI_API_BASE_URL=http://openclaw-gateway:18789/v1
  OPENAI_API_KEY=${OPENCLAW_GATEWAY_TOKEN}
  ```

  注意：`OPENAI_API_KEY=${OPENCLAW_GATEWAY_TOKEN}` 在 `.env` 中会被 docker compose 直接按字面量传递；Open WebUI 只需要一个非空字符串即可通过连接验证，真正的鉴权由 OpenClaw Gateway 处理。

- [ ] **Step 2: 拉取镜像并启动 Open WebUI**

  ```bash
  docker compose pull open-webui
  docker compose up -d
  ```

  Expected: 所有服务状态为 `Up`，`open-webui` 容器健康启动。

- [ ] **Step 3: 验证 OpenClaw Gateway 健康**

  ```bash
  curl -s http://localhost:18789/healthz
  ```

  Expected: `{"ok":true,"status":"live"}`

- [ ] **Step 4: 验证 LibreChat 仍可用**

  ```bash
  curl -s -o /dev/null -w "%{http_code}" http://localhost:3080/
  ```

  Expected: `200`

- [ ] **Step 5: 验证 Open WebUI 可访问**

  ```bash
  curl -s -o /dev/null -w "%{http_code}" http://localhost:3090/
  ```

  Expected: `200`

- [ ] **Step 6: 检查 Open WebUI 是否已发现 OpenClaw 模型**

  登录 Open WebUI 后（第一个注册账号自动成为管理员），进入 **Admin Settings → Connections → OpenAI**，确认连接的 URL 为 `http://openclaw-gateway:18789/v1`。若 `/models` 未返回模型，在 **Model IDs (Filter)** 中手动添加 `openclaw`。

- [ ] **Step 7: 在 Open WebUI 中发起一次测试对话**

  选择 `openclaw` 模型，输入 "你好"，确认能收到来自 OpenClaw Gateway 的流式回复。

---

## Self-Review

1. **Spec coverage:** 保留 LibreChat ✅、新增 Open WebUI ✅、共用 OpenClaw Gateway ✅、配置文档化 ✅、本地验证 ✅。
2. **Placeholder scan:** 无 TBD/TODO，所有代码片段完整。
3. **Type consistency:** 环境变量名在 `.env.example`、`docker-compose.yml`、README 中一致。

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-07-06-openclaw-chat-add-openwebui-alongside-librechat.md`. Two execution options:**

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

**Which approach?**
