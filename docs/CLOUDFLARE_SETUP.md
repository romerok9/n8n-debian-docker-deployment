# Cloudflare Tunnel Setup Guide

This guide will walk you through setting up a Cloudflare Tunnel to securely expose your n8n instance to the internet without opening ports on your firewall.

## Prerequisites

- Cloudflare account (free plan works)
- Domain managed by Cloudflare
- Server with Docker running

## Step 1: Install cloudflared

### Debian/Ubuntu

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
```

### Other Linux

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
sudo mv cloudflared /usr/local/bin/
sudo chmod +x /usr/local/bin/cloudflared
```

## Step 2: Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

This will open a browser window. Select your domain and authorize the tunnel.

## Step 3: Create a Tunnel

```bash
cloudflared tunnel create n8n-tunnel
```

**Important**: Copy the UUID displayed (e.g., `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

## Step 4: Configure the Tunnel

Edit `config/cloudflared-config.yml`:

```yaml
tunnel: YOUR_TUNNEL_UUID_HERE
credentials-file: /root/.cloudflared/YOUR_TUNNEL_UUID_HERE.json

ingress:
  - hostname: n8n.yourdomain.com
    service: http://localhost:5678
  
  - hostname: yourdomain.com
    service: http://localhost:80
  
  - service: http_status:404
```

Replace:
- `YOUR_TUNNEL_UUID_HERE` with your tunnel UUID
- `yourdomain.com` with your actual domain

## Step 5: Copy Configuration

```bash
sudo mkdir -p /etc/cloudflared
sudo cp config/cloudflared-config.yml /etc/cloudflared/config.yml
```

## Step 6: Create DNS Records

In your Cloudflare dashboard (DNS settings):

### For n8n subdomain:
- **Type**: CNAME
- **Name**: n8n
- **Target**: `YOUR_TUNNEL_UUID.cfargotunnel.com`
- **Proxy status**: Proxied (orange cloud)

### For main domain (optional):
- **Type**: CNAME
- **Name**: @
- **Target**: `YOUR_TUNNEL_UUID.cfargotunnel.com`
- **Proxy status**: Proxied (orange cloud)

**Important**: DNS propagation can take a few minutes.

## Step 7: Install as System Service

```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

## Step 8: Verify

```bash
# Check service status
sudo systemctl status cloudflared

# Check tunnel status
sudo cloudflared tunnel info n8n-tunnel

# View logs
sudo journalctl -u cloudflared -f
```

## Step 9: Test Access

Wait 2-5 minutes for DNS propagation, then visit:

```
https://n8n.yourdomain.com
```

## Troubleshooting

### Tunnel not connecting

```bash
# Check configuration
sudo cloudflared tunnel info n8n-tunnel

# Test manually
sudo cloudflared tunnel run n8n-tunnel
```

### DNS not resolving

```bash
# Check DNS
nslookup n8n.yourdomain.com

# Flush local DNS cache
sudo systemd-resolve --flush-caches  # Linux
```

### 502 Bad Gateway

- Ensure n8n container is running: `docker ps`
- Check if port 5678 is accessible: `curl http://localhost:5678`
- Verify service URLs in config.yml

### Certificate Errors

Cloudflare automatically provides SSL certificates. If you see certificate errors:

1. Ensure Cloudflare proxy is enabled (orange cloud)
2. Wait a few minutes for certificate provisioning
3. Clear browser cache

## Security Best Practices

1. **Enable Cloudflare Access** (optional but recommended):
   - Go to Zero Trust dashboard
   - Add application policy
   - Require email authentication

2. **Use n8n Basic Auth**:
   - Already configured via environment variables
   - Provides double authentication layer

3. **Monitor Access Logs**:
   ```bash
   sudo journalctl -u cloudflared -f
   ```

4. **Rotate Tunnel Credentials**:
   - Delete old tunnels: `cloudflared tunnel delete OLD_TUNNEL`
   - Create new ones periodically

## Advanced Configuration

### Multiple Services

Add more ingress rules:

```yaml
ingress:
  - hostname: n8n.yourdomain.com
    service: http://localhost:5678
  
  - hostname: grafana.yourdomain.com
    service: http://localhost:3000
  
  - hostname: yourdomain.com
    service: http://localhost:80
  
  - service: http_status:404
```

### IP Restrictions

In Cloudflare Dashboard → Firewall Rules:

```
(http.host eq "n8n.yourdomain.com" and ip.geoip.country ne "YOUR_COUNTRY")
Action: Block
```

## Useful Commands

```bash
# List all tunnels
cloudflared tunnel list

# Delete a tunnel
cloudflared tunnel delete TUNNEL_NAME

# Update cloudflared
sudo apt update && sudo apt upgrade cloudflared

# Restart service
sudo systemctl restart cloudflared

# Stop service
sudo systemctl stop cloudflared
```

## Resources

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflare Zero Trust](https://www.cloudflare.com/products/zero-trust/)
- [Cloudflare Community](https://community.cloudflare.com/)

---

**Need help?** Open an issue on GitHub or check the [Troubleshooting Guide](TROUBLESHOOTING.md).






















