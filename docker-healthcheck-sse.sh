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

# Health check script for SSE transport

# Get configuration from environment
: ${FASTMCP_PORT:=8000}
: ${FASTMCP_HOST:=0.0.0.0}
: ${FASTMCP_SSE_PATH:=/sse/}

# Check if the SSE endpoint is responding
# The SSE endpoint should return a 200 status code when accessed with GET
response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "http://localhost:${FASTMCP_PORT}${FASTMCP_SSE_PATH}" -H "Accept: text/event-stream" --max-time 5)

if [ "$response" = "200" ]; then
    echo "SSE endpoint is healthy (HTTP $response)"
    exit 0
else
    echo "SSE endpoint is unhealthy (HTTP $response)"
    exit 1
fi