# 九州通健康科技 — AI 智能体平台

基于 [OpenClaw](https://github.com/openclaw/openclaw) + [LibreChat](https://github.com/danny-avila/LibreChat) 构建的多租户 AI 智能体平台。

**代号：小九** 🤖

<img width="2367" height="1470" alt="6dc6a1157a43fc5d75c89bc401a46daa" src="https://github.com/user-attachments/assets/778b2180-71e8-4a55-80e8-ba11cd1c3e2c" />

## 架构

```
┌─ 用户浏览器 ─────────────────────────────────┐
│                                               │
│  http://localhost:3080 ← LibreChat            │
│    ┌────────────────────────────────────┐     │
│    │  用户注册 / 登录 / 会话隔离        │     │
│    │  选择模型 → "小九" 开始对话       │     │
│    └──────────────┬─────────────────────┘     │
│                   │ OpenAI 兼容 API            │
│    ┌──────────────▼─────────────────────┐     │
│    │  OpenClaw Gateway                  │     │
│    │  ├ DeepSeek V4 Flash (大模型)      │     │
│    │  ├ SOUL.md（Agent 身份设定）       │     │
│    │  └ Skills / Tool Calling           │     │
│    └────────────────────────────────────┘     │
└───────────────────────────────────────────────┘
```

## 前置条件

| 要求 | 说明 |
|------|------|
| [Docker](https://docs.docker.com/engine/install/) | ≥ 24.0 |
| Docker Compose | ≥ 2.20（Docker Desktop 或 docker compose 插件均可） |
| [Git](https://git-scm.com/) | 克隆仓库使用 |
| 内存 | ≥ 4GB（推荐 8GB） |
| 网络 | 首次运行需拉取 Docker 镜像和上游仓库 |

## 快速开始

### 1. 克隆

```bash
git clone https://github.com/35iter-cn/openclaw-chat.git
cd openclaw-chat
```

### 2. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env`文件，**至少**设置 `DEEPSEEK_API_KEY`：

```bash
# 打开 .env 填写你的 DeepSeek API Key
# 申请地址：https://platform.deepseek.com/api_keys
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

其他变量已有默认值，可以不修改。

### 3. 启动服务

```bash
docker compose up -d
```

> ⏱ 首次启动需下载 Docker 镜像，约 **2-5 分钟**，取决于网络。

### 4. 注册账号

打开浏览器访问 **http://localhost:3080/register**，注册第一个用户（自动成为管理员）。

### 5. 选择模型开始对话

1. 登录后，在对话界面顶部找到模型下拉菜单
2. 选择 **"小九"**（如果看不到，刷新页面或重新登录）
3. 输入消息开始对话

## 验证服务是否正常

```bash
# 查看所有容器状态
docker compose ps

# 所有服务应为 "Up" 或 "healthy" 状态
# 
# NAME                    STATUS
# librechat-api           Up
# librechat-meilisearch   Up
# librechat-mongodb       Up
# openclaw-gateway        Up (healthy)

# 测试 OpenClaw API
curl -s http://localhost:18789/healthz
# 应返回: {"ok":true,"status":"live"}

# 测试 LibreChat 页面
curl -s -o /dev/null -w "%{http_code}" http://localhost:3080/
# 应返回: 200

# 测试 LibreChat 注册页面
curl -s -o /dev/null -w "%{http_code}" http://localhost:3080/register
# 应返回: 200
```

## 服务说明

| 地址 | 服务 | 说明 |
|------|------|------|
| `http://localhost:3080` | LibreChat | 多用户 Web 对话界面 |
| `http://localhost:18789` | OpenClaw Gateway | AI 引擎 + 管理后台 |

## 目录结构

```
├── docker-compose.yml           # Docker 编排（3 个容器）
├── .env.example                 # 环境变量模板
├── .gitignore
├── README.md
├── librechat.yaml               # LibreChat 配置（模型端点、界面文字）
├── openclaw/
│   ├── openclaw.json            # OpenClaw 配置（模型、认证、API）
│   └── workspace/
│       └── SOUL.md              # 小九的身份设定
├── images/
│   └── jointown.png             # 九州通 Logo
```

## 故障排查

### 注册提示 "Registration is not allowed"

`.env` 中设置：
```bash
ALLOW_REGISTRATION=true
ALLOW_UNVERIFIED_EMAIL_LOGIN=true
```
然后 `docker compose up -d librechat-api` 使其生效。

### 对话报错 "Missing API Key" / "Authentication Fails"

检查 `.env` 中 `DEEPSEEK_API_KEY` 是否正确设置，然后：
```bash
docker compose up -d openclaw-gateway
```

DeepSeek API Key 在 https://platform.deepseek.com/api_keys 获取。

### 端口被占用

修改 `.env` 中的端口号：
```bash
LIBRECHAT_PORT=3090           # 改为其他端口
OPENCLAW_GATEWAY_PORT=18790   # 改为其他端口
```
然后 `docker compose up -d` 使其生效。

### 查看日志

```bash
# 所有服务日志
docker compose logs -f

# 只看某个服务
docker compose logs -f openclaw-gateway
docker compose logs -f librechat-api
```

### 重启服务

```bash
docker compose restart                   # 全部重启
docker compose restart openclaw-gateway  # 只重启某个服务
```

### 更新到最新版本

```bash
# 拉取最新 Docker 镜像并重启
docker compose pull
docker compose up -d
```

## 技术栈

| 组件 | 技术 |
|------|------|
| Web 界面 | LibreChat（Node.js / React / Express） |
| AI 引擎 | OpenClaw Gateway（Node.js / TypeScript） |
| 大模型 | DeepSeek V4 Flash（通过 OpenAI 兼容 API） |
| 用户存储 | MongoDB |
| 搜索索引 | MeiliSearch |
| 容器编排 | Docker Compose |

## 相关链接

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [LibreChat GitHub](https://github.com/danny-avila/LibreChat)
- [DeepSeek Platform](https://platform.deepseek.com)
