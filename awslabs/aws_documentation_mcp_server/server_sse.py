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
"""AWS Documentation MCP Server SSE Transport Runner."""

import os
import sys
from loguru import logger

# Set up logging
logger.remove()
logger.add(sys.stderr, level=os.getenv('FASTMCP_LOG_LEVEL', 'INFO'))

PARTITION = os.getenv('AWS_DOCUMENTATION_PARTITION', 'aws').lower()


def main():
    """Run the MCP server with SSE transport."""
    # Import the appropriate server based on partition
    if PARTITION == 'aws':
        from awslabs.aws_documentation_mcp_server.server_aws import mcp
    elif PARTITION == 'aws-cn':
        from awslabs.aws_documentation_mcp_server.server_aws_cn import mcp
    else:
        raise ValueError(f'Unsupported AWS documentation partition: {PARTITION}.')
    
    # Set environment variables for FastMCP to pick up
    # These may be used internally by FastMCP
    os.environ.setdefault('FASTMCP_HOST', '0.0.0.0')
    os.environ.setdefault('FASTMCP_PORT', '8000')
    os.environ.setdefault('FASTMCP_SSE_PATH', '/sse/')
    os.environ.setdefault('FASTMCP_MESSAGE_PATH', '/messages/')
    
    # Get configuration for logging
    host = os.getenv('FASTMCP_HOST', '0.0.0.0')
    port = os.getenv('FASTMCP_PORT', '8000')
    sse_path = os.getenv('FASTMCP_SSE_PATH', '/sse/')
    message_path = os.getenv('FASTMCP_MESSAGE_PATH', '/messages/')
    
    logger.info(f'Starting AWS Documentation MCP Server ({PARTITION}) with SSE transport')
    logger.info(f'Configuration: host={host}, port={port}')
    logger.info(f'SSE endpoint: http://{host}:{port}{sse_path}')
    logger.info(f'Message endpoint: http://{host}:{port}{message_path}')
    
    # Run with SSE transport - FastMCP will use environment variables
    mcp.run(transport='sse')


if __name__ == '__main__':
    main()