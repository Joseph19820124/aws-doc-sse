# SSE Deployment Guide for AWS Documentation MCP Server

This guide explains how to deploy the AWS Documentation MCP Server using Server-Sent Events (SSE) transport instead of STDIO.

## Overview

SSE transport allows the MCP server to be accessed over HTTP, making it suitable for:
- Web-based integrations
- Remote access
- Multi-client scenarios
- Production deployments with load balancing

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and run the SSE server
docker-compose -f docker-compose-sse.yml up -d

# View logs
docker-compose -f docker-compose-sse.yml logs -f

# Stop the server
docker-compose -f docker-compose-sse.yml down
```

### Using Docker Directly

```bash
# Build the SSE Docker image
docker build -f Dockerfile.sse -t aws-documentation-mcp-sse .

# Run the container
docker run -d \
  --name aws-documentation-mcp-sse \
  -p 8000:8000 \
  -e AWS_DOCUMENTATION_PARTITION=aws \
  -e FASTMCP_LOG_LEVEL=INFO \
  aws-documentation-mcp-sse

# Check health
docker exec aws-documentation-mcp-sse docker-healthcheck-sse.sh
```

### Running Locally (Development)

```bash
# Install dependencies
pip install -e .

# Run with SSE transport
export FASTMCP_TRANSPORT=sse
export FASTMCP_PORT=8000
export FASTMCP_HOST=0.0.0.0
python -m awslabs.aws_documentation_mcp_server.server_sse
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AWS_DOCUMENTATION_PARTITION` | `aws` | AWS partition (`aws` or `aws-cn`) |
| `FASTMCP_TRANSPORT` | `sse` | Transport type (set to `sse`) |
| `FASTMCP_PORT` | `8000` | Port to listen on |
| `FASTMCP_HOST` | `0.0.0.0` | Host to bind to |
| `FASTMCP_SSE_PATH` | `/sse/` | SSE endpoint path |
| `FASTMCP_MESSAGE_PATH` | `/messages/` | Message POST endpoint |
| `FASTMCP_LOG_LEVEL` | `INFO` | Logging level |

### Endpoints

- **SSE Endpoint**: `http://localhost:8000/sse/` - Connect here for server-sent events
- **Message Endpoint**: `http://localhost:8000/messages/` - POST messages here
- **Health Check**: `curl -H "Accept: text/event-stream" http://localhost:8000/sse/`

## Production Deployment

### With Nginx Reverse Proxy

For production, use the included nginx configuration:

```bash
# Run with nginx profile
docker-compose -f docker-compose-sse.yml --profile production up -d
```

This provides:
- Proper SSE proxying with disabled buffering
- CORS headers configuration
- SSL/TLS termination (configure certificates)
- Load balancing capabilities

### Security Considerations

1. **Authentication**: Implement authentication at the reverse proxy level
2. **CORS**: Configure appropriate CORS headers for your domains
3. **SSL/TLS**: Always use HTTPS in production
4. **Firewall**: Restrict access to the SSE ports
5. **Rate Limiting**: Implement rate limiting at the proxy level

### Scaling

For high availability:

```yaml
# docker-compose-scale.yml
services:
  aws-documentation-mcp-sse:
    # ... same configuration ...
    deploy:
      replicas: 3
```

Then use a load balancer with sticky sessions for SSE connections.

## Client Connection Example

### JavaScript/TypeScript

```javascript
// Connect to SSE endpoint
const eventSource = new EventSource('http://localhost:8000/sse/');

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
};

// Send messages via POST
async function sendMessage(message) {
  const response = await fetch('http://localhost:8000/messages/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(message),
  });
  return response.json();
}
```

### Python

```python
import requests
import sseclient

# Connect to SSE
response = requests.get('http://localhost:8000/sse/', stream=True)
client = sseclient.SSEClient(response)

for event in client.events():
    print(f"Received: {event.data}")

# Send message
message_response = requests.post(
    'http://localhost:8000/messages/',
    json={"method": "tools/list"}
)
```

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if the server is running: `docker ps`
   - Verify port mapping: `docker port aws-documentation-mcp-sse`
   - Check firewall rules

2. **SSE Connection Drops**
   - Check proxy timeouts (nginx: `proxy_read_timeout`)
   - Verify no buffering in proxy configuration
   - Check client-side reconnection logic

3. **CORS Errors**
   - Update nginx CORS headers for your domain
   - Ensure OPTIONS preflight requests are handled

4. **Health Check Failures**
   - Verify SSE endpoint is accessible
   - Check server logs: `docker logs aws-documentation-mcp-sse`
   - Ensure proper startup time in health check

### Debugging

```bash
# Test SSE endpoint
curl -H "Accept: text/event-stream" http://localhost:8000/sse/

# Check server logs
docker logs -f aws-documentation-mcp-sse

# Monitor health checks
watch docker exec aws-documentation-mcp-sse docker-healthcheck-sse.sh

# Test with MCP Inspector
npx @modelcontextprotocol/inspector http://localhost:8000/sse/
```

## Monitoring

For production monitoring:

1. Set up health check alerts
2. Monitor SSE connection count
3. Track message latency
4. Log errors and reconnections
5. Monitor resource usage (CPU, memory, connections)

## Migration from STDIO

To migrate from STDIO to SSE:

1. Update client configuration to use HTTP transport
2. Configure authentication if needed
3. Update connection URLs
4. Test failover and reconnection logic
5. Monitor for any behavioral differences

## Additional Resources

- [FastMCP SSE Documentation](https://gofastmcp.com/deployment/running-server)
- [MCP Transport Concepts](https://modelcontextprotocol.io/docs/concepts/transports)
- [Server-Sent Events Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html)