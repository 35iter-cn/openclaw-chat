# 九州通健康科技 — AI 智能体平台

基于 [OpenClaw](https://github.com/openclaw/openclaw) + [LibreChat](https://github.com/danny-avila/LibreChat) 构建的多租户 AI 智能体平台。

## 架构

```
用户浏览器 → http://localhost:3080
                    │
            ┌───────┴───────┐
            │  LibreChat    │  ← 多用户 Web 对话界面（注册/登录/会话隔离）
            ├───────────────┤
            │  MongoDB      │  ← 用户与会话数据
            └───────┬───────┘
                    │ OpenAI 兼容 API
            ┌───────▼───────┐
            │  OpenClaw     │  ← AI 智能体引擎
            │  Gateway      │
            ├───────────────┤
            │  DeepSeek V4  │  ← 大模型
            │  Flash        │
            │  SOUL.md      │  ← Agent 身份设定
            └───────────────┘
```

## 一键部署

```bash
# 1. 克隆
git clone <repo-url>
cd openclaw-clawcontrol-deploy

# 2. 配置
cp .env.example .env
# 编辑 .env，填入 DEEPSEEK_API_KEY

# 3. 启动
bash scripts/setup.sh
docker compose up -d

# 4. 注册账号
open http://localhost:3080/register

# 5. 开始对话
open http://localhost:3080
```

## 服务

| 地址 | 服务 | 说明 |
|------|------|------|
| `http://localhost:3080` | LibreChat | 多用户对话界面 |
| `http://localhost:18789` | OpenClaw Gateway | AI 引擎 |

## 目录结构

```
├── docker-compose.yml
├── .env.example
├── .gitignore
├── openclaw/
│   ├── openclaw.json         # OpenClaw 配置
│   └── workspace/SOUL.md     # Agent 身份设定
├── librechat.yaml            # LibreChat 配置
├── images/jointown.png       # 九州通 Logo
└── scripts/setup.sh          # 上游仓库克隆
```

