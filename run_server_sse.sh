#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# SSE Server Runner Script for AWS Documentation MCP Server

# Set default values if not provided via environment
: ${FASTMCP_TRANSPORT:=sse}
: ${FASTMCP_PORT:=8000}
: ${FASTMCP_HOST:=0.0.0.0}
: ${FASTMCP_SSE_PATH:=/sse/}
: ${FASTMCP_MESSAGE_PATH:=/messages/}
: ${FASTMCP_LOG_LEVEL:=INFO}
: ${AWS_DOCUMENTATION_PARTITION:=aws}

# Export environment variables
export FASTMCP_TRANSPORT
export FASTMCP_PORT
export FASTMCP_HOST
export FASTMCP_SSE_PATH
export FASTMCP_MESSAGE_PATH
export FASTMCP_LOG_LEVEL
export AWS_DOCUMENTATION_PARTITION

echo "Starting AWS Documentation MCP Server in SSE mode..."
echo "Configuration:"
echo "  Transport: $FASTMCP_TRANSPORT"
echo "  Host: $FASTMCP_HOST"
echo "  Port: $FASTMCP_PORT"
echo "  SSE Path: $FASTMCP_SSE_PATH"
echo "  Message Path: $FASTMCP_MESSAGE_PATH"
echo "  Log Level: $FASTMCP_LOG_LEVEL"
echo "  AWS Partition: $AWS_DOCUMENTATION_PARTITION"

# Run the server with FastMCP SSE transport
exec python -m awslabs.aws_documentation_mcp_server.server_sse