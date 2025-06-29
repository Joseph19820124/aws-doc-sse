# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在处理此仓库代码时提供指导。

## 仓库概述

这是 AWS 文档 MCP 服务器 - 一个模型上下文协议（MCP）服务器，提供访问 AWS 文档、搜索内容和获取推荐的工具。

## 架构

### 项目结构
```
awslabs/aws_documentation_mcp_server/
├── server.py          # 主入口点，路由到特定分区的服务器
├── server_aws.py      # 全球 AWS 文档服务器实现
├── server_aws_cn.py   # AWS 中国文档服务器实现
├── server_utils.py    # 文档读取的共享工具
├── models.py          # Pydantic 数据模型
└── util.py            # 解析响应的工具函数
```

### 关键组件

1. **分区路由**：服务器支持两个分区，通过 `AWS_DOCUMENTATION_PARTITION` 环境变量控制：
   - `aws`（默认）：全球 AWS 文档
   - `aws-cn`：AWS 中国文档

2. **可用工具**：
   - `read_documentation`：获取并将 AWS 文档页面转换为 markdown
   - `search_documentation`：搜索 AWS 文档（仅限全球）
   - `recommend`：获取内容推荐（仅限全球）
   - `get_available_services`：列出可用服务（仅限中国）

3. **依赖项**：使用 FastMCP 框架、httpx 进行 HTTP 请求、markdownify 进行 HTML 到 markdown 转换，以及 BeautifulSoup 进行 HTML 解析。

## 开发命令

### 运行测试
```bash
# 运行所有测试
pytest

# 运行测试（排除实时 API 测试）
pytest -m "not live"

# 运行测试并生成覆盖率报告
pytest --cov=awslabs

# 运行特定测试文件
pytest tests/test_server_aws.py
```

### 代码质量
```bash
# 运行代码检查器
ruff check .

# 运行代码格式化
ruff format .

# 类型检查
pyright
```

### 运行服务器
```bash
# 使用 uv 安装并运行（推荐）
uvx awslabs.aws-documentation-mcp-server@latest

# 从源代码运行
python -m awslabs.aws_documentation_mcp_server.server

# 使用特定分区运行
AWS_DOCUMENTATION_PARTITION=aws-cn python -m awslabs.aws_documentation_mcp_server.server
```

### Docker
```bash
# 构建 Docker 镜像
docker build -t mcp/aws-documentation .

# 运行 Docker 容器
docker run --rm -it \
  --env FASTMCP_LOG_LEVEL=ERROR \
  --env AWS_DOCUMENTATION_PARTITION=aws \
  mcp/aws-documentation:latest
```

## 环境变量

- `AWS_DOCUMENTATION_PARTITION`：设置为 `aws`（默认）或 `aws-cn`
- `FASTMCP_LOG_LEVEL`：日志级别（默认：`WARNING`）

## 测试策略

- 测试按功能组织（服务器逻辑、模型、工具）
- 实时测试（标记为 `@pytest.mark.live`）会进行实际的 API 调用
- 模拟测试使用 pytest-mock 进行单元测试，无需外部依赖
- 支持同步和异步测试模式

## 重要说明

- 服务器对全球和中国分区使用不同的 API 端点
- 搜索和推荐功能仅适用于全球 AWS 文档
- 服务器包含用户代理标头和会话跟踪用于 API 调用
- HTML 内容会被清理并转换为 markdown 以提高可用性