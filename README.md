# SentinelOne Syslog Solutions Toolkit

**Quick Start:**

```bash
cd /etc
sudo mkdir sentinelone-syslog-toolkit
sudo chown $USER:$GROUP sentinelone-syslog-toolkit
git clone <your-repo-url>
cd sentinelone-syslog-toolkit
bash setup.sh
```

**Target Audience:**

- SentinelOne customers integrating traditional syslog sources with [Singularity Data Lake (SDL)](https://www.sentinelone.com/platform/data-lake/)
- Operations and compliance teams shipping events for analysis
- Security teams enriching [AI-SIEM](https://www.sentinelone.com/platform/ai-siem/) detections
- Organizations enabling [OCSF](https://ocsf.io/) events for [Purple integration](https://www.sentinelone.com/blog/the-purple-ai-athena-release/)

## 🎯 Choose Your Adventure

### 1. 🚀 Simple Multi-Port Collection

**Perfect for:** Basic setups, different sources on different ports

- **Use Case:** VM network accessible appliances that can only output logs via syslog
- **Method:** Multiple listening ports to differentiate sources
- **Complexity:** ⭐ Low
- **Support:** ✅ Official S1 supported solution
- **Container Count:** 1 (S1 provided)
- **API:** addEvents
- **Setup time:** 5 minutes
- **→ [Go to Simple Collector](simple-collector/)**

### 2. 🔧 Content-Based Pipeline (3-in-1)

**Perfect for:** Advanced routing, same port, different content-based differentiation

- **Use Case:** Most complicated setup for content-based log routing
- **Method:** syslog-NG differentiation + config-generator + S1-collector
- **Complexity:** ⭐⭐⭐ High
- **Support:** ✅ Official S1 supported solution (but complex)
- **Container Count:** 3 (all S1 provided)
- **API:** addEvents (via S1-collector agent)
- **Setup time:** 15 minutes
- **→ [Go to 3-in-1 Pipeline](3-in-1-pipeline/)**

### 3. ⚡ High-Performance Rootless

**Perfect for:** Maximum throughput, security-conscious, single container

- **Use Case:** Content-based differentiation with high throughput capability
- **Method:** Containerized syslog-ng (rootless) shipping via HEC
- **Complexity:** ⭐⭐ Medium
- **Support:** 🔶 Community supported (not officially supported)
- **Container Count:** 1 (rootless, custom built)
- **API:** HEC (higher throughput than addEvents)
- **Setup time:** 10 minutes
- **→ [Go to Rootless Syslog-NG](rootless-syslog-ng/)**

### 4+. 🔮 Coming Soon

- **Native Linux** (no containers) - `coming-soon/native-linux/`
- **Enterprise Offline** (no external repos like EPEL) - `coming-soon/enterprise-offline/`

## Quick Compare

| Feature                 | Simple | 3-in-1 | Rootless |
| ----------------------- | ------ | ------ | -------- |
| Port differentiation    | ✅     | ✅     | ✅       |
| Content differentiation | ❌     | ✅     | ✅       |
| Official S1 support     | ✅     | ✅     | ❌       |
| Container count         | 1      | 3      | 1        |
| Setup complexity        | Low    | High   | Medium   |
| Throughput              | Medium | Medium | High     |
| Dependencies locked     | ✅     | ✅     | ✅       |
| Rootless capable        | ❌     | ❌     | ✅       |
| Built-in testing        | ❌     | ❌     | ✅       |

## 📋 All Solutions Include

- ✅ Containers lock in dependencies
- ✅ Easy Docker-based deployment
- ✅ Environment-based configuration
- ✅ Sample log files for testing
- ✅ Comprehensive documentation

## ⚠️ Important Configuration Note

**S1_INGEST_URL Format:** All solutions require the `S1_INGEST_URL` environment variable to include the full URL with `https://` prefix.

✅ **Correct:** `S1_INGEST_URL=https://ingest.us1.sentinelone.net`  
❌ **Incorrect:** `S1_INGEST_URL=ingest.us1.sentinelone.net`

This ensures proper SSL/TLS connectivity to SentinelOne SDL.

## 🚧 Future Roadmap

- **Native Linux deployments** for customers who cannot use containers
- **Enterprise offline solutions** for environments without access to public repos
- **Additional log source integrations** based on customer feedback

---

**Need help choosing?** Run `bash setup.sh` for an interactive guide, or explore the individual solution directories above.

_Built with ❤️ for secure, scalable log forwarding to SentinelOne SDL_
