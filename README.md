# SentinelOne Rootless Syslog-NG Setup

> **Acknowledgments:** Inspiration and credit for this approach go to [sva-s1](https://github.com/sva-s1). 

**Quick Start:**

```bash
cd /etc
sudo mkdir sentinelone
cd sentinelone
sudo chown $USER:$GROUP sentinelone
git clone https://github.com/burnerforge/syslog-ng.git
cd syslog-ng
bash setup.sh
```

*(Note: Remove spaces between the backticks above when pasting into your markdown editor)*

**Target Audience:**

* SentinelOne customers integrating traditional syslog sources with [Singularity Data Lake (SDL)](https://www.sentinelone.com/platform/data-lake/)
* Operations and compliance teams shipping events for analysis
* Security teams enriching [AI-SIEM](https://www.sentinelone.com/platform/ai-siem/) detections
* Organizations enabling [OCSF](https://ocsf.io/) events for [Purple integration](https://www.sentinelone.com/blog/the-purple-ai-athena-release/)

## ⚡ High-Performance Rootless

**Perfect for:** Maximum throughput, security-conscious environments, single-container deployments

* **Use Case:** Content-based differentiation with high throughput capability
* **Method:** Containerized syslog-ng (rootless) shipping via HEC
* **Complexity:** ⭐⭐ Medium
* **Support:** 🔶 Community supported (not officially supported)
* **Container Count:** 1 (rootless, custom built)
* **API:** HEC (higher throughput than addEvents)
* **Setup time:** ~10 minutes

## 📋 Solution Features

* ✅ **Security First:** Fully rootless container execution
* ✅ **Flexibility:** Supports both port-based and content-based log differentiation
* ✅ **Performance:** High-throughput capabilities using the HEC API
* ✅ **Stability:** Containers lock in dependencies
* ✅ **Simplicity:** Easy Docker-based deployment with environment-based configuration
* ✅ **Validation:** Built-in testing capabilities with sample log files included
* ✅ **Documentation:** Comprehensive setup guides

## ⚠️ Important Configuration Note

**S1_INGEST_URL Format:** This solution requires the `S1_INGEST_URL` environment variable to include the full URL with the `https://` prefix.

* ✅ **Correct:** `S1_INGEST_URL=https://ingest.us1.sentinelone.net`  
* ❌ **Incorrect:** `S1_INGEST_URL=ingest.us1.sentinelone.net`

This ensures proper SSL/TLS connectivity to SentinelOne SDL.

---
