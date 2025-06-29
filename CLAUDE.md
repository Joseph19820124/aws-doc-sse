# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the AWS Documentation MCP Server - a Model Context Protocol (MCP) server that provides tools to access AWS documentation, search for content, and get recommendations.

## Architecture

### Project Structure
```
awslabs/aws_documentation_mcp_server/
├── server.py          # Main entry point that routes to partition-specific servers
├── server_aws.py      # Global AWS documentation server implementation
├── server_aws_cn.py   # AWS China documentation server implementation
├── server_utils.py    # Shared utilities for documentation reading
├── models.py          # Pydantic data models
└── util.py            # Utility functions for parsing responses
```

### Key Components

1. **Partition Routing**: The server supports two partitions controlled by `AWS_DOCUMENTATION_PARTITION` environment variable:
   - `aws` (default): Global AWS documentation
   - `aws-cn`: AWS China documentation

2. **Available Tools**:
   - `read_documentation`: Fetches and converts AWS documentation pages to markdown
   - `search_documentation`: Search AWS docs (global only)
   - `recommend`: Get content recommendations (global only)
   - `get_available_services`: List available services (China only)

3. **Dependencies**: Uses FastMCP framework, httpx for HTTP requests, markdownify for HTML-to-markdown conversion, and BeautifulSoup for HTML parsing.

## Development Commands

### Running Tests
```bash
# Run all tests
pytest

# Run tests excluding live API tests
pytest -m "not live"

# Run tests with coverage
pytest --cov=awslabs

# Run specific test file
pytest tests/test_server_aws.py
```

### Code Quality
```bash
# Run linter
ruff check .

# Run formatter
ruff format .

# Type checking
pyright
```

### Running the Server
```bash
# Install and run with uv (recommended)
uvx awslabs.aws-documentation-mcp-server@latest

# Run from source
python -m awslabs.aws_documentation_mcp_server.server

# Run with specific partition
AWS_DOCUMENTATION_PARTITION=aws-cn python -m awslabs.aws_documentation_mcp_server.server
```

### Docker
```bash
# Build Docker image
docker build -t mcp/aws-documentation .

# Run Docker container
docker run --rm -it \
  --env FASTMCP_LOG_LEVEL=ERROR \
  --env AWS_DOCUMENTATION_PARTITION=aws \
  mcp/aws-documentation:latest
```

## Environment Variables

- `AWS_DOCUMENTATION_PARTITION`: Set to `aws` (default) or `aws-cn`
- `FASTMCP_LOG_LEVEL`: Logging level (default: `WARNING`)

## Testing Strategy

- Tests are organized by functionality (server logic, models, utilities)
- Live tests (marked with `@pytest.mark.live`) make actual API calls
- Mock tests use pytest-mock for unit testing without external dependencies
- Both sync and async test patterns are supported

## Important Notes

- The server uses different API endpoints for global vs China partitions
- Search and recommendations are only available for global AWS documentation
- The server includes user agent headers and session tracking for API calls
- HTML content is cleaned and converted to markdown for better usability