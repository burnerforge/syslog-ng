#!/bin/bash

# Syslog Collector Test Script
# Sends sample messages to test firewall, router, and Palo Alto pattern matching

echo "🧪 Testing Syslog Collector with sample messages..."
echo "📡 Target: UDP port 514 on localhost"
echo ""

# Directory containing sample log files
SAMPLES_DIR="$(dirname "$0")/../samples"

# Function to send a log message with comprehensive debugging
send_log() {
    local log_file="$1"
    local description="$2"
    local pattern="$3"
    
    if [ ! -f "$SAMPLES_DIR/$log_file" ]; then
        echo "❌ Sample file $log_file not found in $SAMPLES_DIR"
        return 1
    fi
    
    echo "📤 Sending $description (should match $pattern pattern)..."
    
    # Read and display the log content
    LOG_CONTENT=$(cat "$SAMPLES_DIR/$log_file")
    echo "📋 Message content: $LOG_CONTENT"
    
    # Extract key fields for debugging (handle both RFC3164 and RFC5424 formats)
    if echo "$LOG_CONTENT" | grep -q '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T'; then
        # RFC5424 format: <pri>version timestamp hostname appname procid msgid [structured-data] msg
        HOST=$(echo "$LOG_CONTENT" | sed -n 's/<[0-9]*>[0-9]* [^ ]* \([^ ]*\) .*/\1/p')
        PROGRAM=$(echo "$LOG_CONTENT" | sed -n 's/<[0-9]*>[0-9]* [^ ]* [^ ]* \([^ ]*\) .*/\1/p')
    else
        # RFC3164 format: <pri>timestamp hostname program: msg
        HOST=$(echo "$LOG_CONTENT" | sed -n 's/<[0-9]*>[A-Za-z]* *[0-9]* *[0-9:]* *\([^ ]*\) .*/\1/p')
        PROGRAM=$(echo "$LOG_CONTENT" | sed -n 's/<[0-9]*>[A-Za-z]* *[0-9]* *[0-9:]* *[^ ]* *\([^:]*\):.*/\1/p')
    fi
    echo "🔍 Extracted HOST: '$HOST', PROGRAM: '$PROGRAM'"
    echo "📁 Expected filename: syslog-collector-$HOST-$PROGRAM-*.log"
    
    # Send the message with detailed error handling
    echo "🚀 Sending via netcat to localhost:514..."
    if echo "$LOG_CONTENT" | docker run -i --rm --network host ${ALPINE_NC_IMAGE:-ghcr.io/sentinelone/alpine-nc}:latest /bin/ash -c "nc -u -w 1 127.0.0.1 514"; then
        echo "✅ $description sent successfully via netcat"
        
        # Wait a moment for syslog-ng to process
        echo "⏳ Waiting 3 seconds for syslog-ng to process message..."
        sleep 3
        
        # Check if syslog-ng created the expected log file
        echo "🔍 Checking if syslog-ng created log file..."
        EXPECTED_PATTERN="syslog-collector-$HOST-$PROGRAM-*.log"
        if docker compose exec syslog-ng ls /var/log/syslog-collector/$EXPECTED_PATTERN 2>/dev/null; then
            echo "✅ Log file created by syslog-ng"
            
            # Show the content of the created file
            CREATED_FILE=$(docker compose exec syslog-ng ls /var/log/syslog-collector/$EXPECTED_PATTERN 2>/dev/null | head -1)
            if [ -n "$CREATED_FILE" ]; then
                echo "📄 Content of created file:"
                docker compose exec syslog-ng cat "/var/log/syslog-collector/$CREATED_FILE" 2>/dev/null || echo "❌ Could not read file content"
            fi
        else
            echo "❌ No matching log file found in syslog-ng"
            echo "📋 Available log files:"
            docker compose exec syslog-ng ls -la /var/log/syslog-collector/ 2>/dev/null || echo "❌ Could not list log files"
        fi
        
        # Check if scalyr-agent is monitoring the file
        echo "🔍 Checking if scalyr-agent is monitoring this file pattern..."
        AGENT_JSON=$(docker compose exec scalyr-agent cat /etc/scalyr-agent-2/agent.json 2>/dev/null)
        
        # Check if any agent.json patterns would match our expected filename
        EXPECTED_FILE="syslog-collector-$HOST-$PROGRAM-a45e96c1bb.log"
        echo "📁 Testing pattern match for: $EXPECTED_FILE"
        
        # Extract patterns and test each one
        PATTERNS=$(echo "$AGENT_JSON" | grep '"path"' | sed 's/.*"path": "\([^"]*\)".*/\1/')
        MATCH_FOUND=false
        
        while IFS= read -r pattern; do
            if [ -n "$pattern" ]; then
                echo "   Testing pattern: $pattern"
                # Convert glob pattern to regex for testing (simpler approach)
                # Just check if the pattern structure matches without complex regex
                pattern_base=$(basename "$pattern")
                expected_base=$(basename "$EXPECTED_FILE")
                # Simple wildcard matching test
                if echo "$expected_base" | grep -q "$(echo "$pattern_base" | sed 's/\*/.*/')"; then
                    match_result=true
                else
                    match_result=false
                fi
                if [ "$match_result" = "true" ]; then
                    echo "   ✅ MATCH! This pattern should work"
                    MATCH_FOUND=true
                else
                    echo "   ❌ No match"
                fi
            fi
        done <<< "$PATTERNS"
        
        if [ "$MATCH_FOUND" = "true" ]; then
            echo "✅ Scalyr-agent has matching file pattern"
        else
            echo "❌ No matching pattern found in agent.json"
        fi
        
    else
        echo "❌ Failed to send $description via netcat"
        return 1
    fi
    
    echo ""
}

# Test Message 1: Cisco Firewall (matches SOURCE2_MATCHER=firewall*)
send_log "cisco-firewall.log" "🔥 CISCO FIREWALL message" "firewall*"

# Test Message 2: Cisco Router (matches SOURCE1_MATCHER=router*)
send_log "cisco-router.log" "🌐 CISCO ROUTER message" "router*"

# Test Message 3: Palo Alto Firewall (matches SOURCE3_MATCHER=PA-*)
send_log "palo-alto.log" "🛡️ PALO ALTO FIREWALL message" "PA-*"

echo "✅ Test complete! All messages sent"
echo ""
echo "📋 Messages sent:"
echo "   1. Cisco Firewall (hostname: firewall4) → ciscoFirewall1 parser"
echo "   2. Cisco Router (hostname: router01) → ciscoRouter1 parser"
echo "   3. Palo Alto Firewall (appname: PA-220) → paloAltoFirewall parser"
echo ""
echo "🔍 Check your SentinelOne SIEM or container logs to verify message processing:"
echo "   docker compose logs scalyr-agent"
echo "   docker compose logs syslog-ng"
echo "   docker compose logs config-generator"
echo ""
echo "🎯 Expected DataSource attributes in SDL:"
echo "   • Cisco Firewall: Category=security, Name='Cisco Firepower Threat Defense', Vendor='Cisco'"
echo "   • Cisco Router: Category=security, Name='Cisco Router', Vendor='Cisco'"
echo "   • Palo Alto: Category=security, Name='Palo Alto Firewall', Vendor='Palo Alto Networks'"
echo ""
echo "🔍 DEBUGGING: Checking end-to-end message delivery..."
echo ""

# Wait for scalyr-agent to process and send messages
echo "⏳ Waiting 10 seconds for scalyr-agent to process and send messages to SDL..."
sleep 10

# Check scalyr-agent request statistics
echo "📊 Scalyr-agent request statistics:"
SCALYR_LOGS=$(docker compose logs scalyr-agent --tail 20)
echo "$SCALYR_LOGS" | grep "agent_requests" | tail -3

# Check for authentication errors
echo ""
echo "🔐 Checking for authentication errors:"
if echo "$SCALYR_LOGS" | grep -qi "401\|unauthorized\|authentication.*failed\|invalid.*token\|forbidden"; then
    echo "❌ AUTHENTICATION ERROR DETECTED!"
    echo "$SCALYR_LOGS" | grep -i "401\|unauthorized\|authentication.*failed\|invalid.*token\|forbidden" | head -3
    echo "🔧 Check your AISIEM_LOGACCESS_WRITE_TOKEN"
else
    echo "✅ No authentication errors found"
fi

# Check for network/connectivity errors
echo ""
echo "🌐 Checking for network/connectivity errors:"
if echo "$SCALYR_LOGS" | grep -qi "connection.*refused\|timeout\|network.*error\|dns.*resolution"; then
    echo "❌ NETWORK ERROR DETECTED!"
    echo "$SCALYR_LOGS" | grep -i "connection.*refused\|timeout\|network.*error\|dns.*resolution" | head -3
else
    echo "✅ No network errors found"
fi

# Show recent error/warning messages
echo ""
echo "⚠️  Recent warnings/errors in scalyr-agent:"
ERROR_LINES=$(echo "$SCALYR_LOGS" | grep -i "error\|warn\|fail" | tail -5)
if [ -n "$ERROR_LINES" ]; then
    echo "$ERROR_LINES"
else
    echo "✅ No recent errors or warnings"
fi

# Check current log file monitoring status
echo ""
echo "📁 Current log files being monitored by scalyr-agent:"
AGENT_JSON=$(docker compose exec scalyr-agent cat /etc/scalyr-agent-2/agent.json 2>/dev/null)
echo "$AGENT_JSON" | grep -A2 '"path"' | grep -E '"path"|"source_type"' | sed 's/^[[:space:]]*/   /'

# Show actual log files created
echo ""
echo "📂 Actual log files created by syslog-ng:"
docker compose exec syslog-ng ls -la /var/log/syslog-collector/*.log 2>/dev/null | tail -10 | sed 's/^/   /'

echo ""
echo "🎯 SUMMARY:"
echo "   1. Messages sent via netcat ✅"
echo "   2. Check if syslog-ng created files ⬆️"
echo "   3. Check if scalyr-agent patterns match ⬆️"
echo "   4. Check scalyr-agent SDL delivery ⬆️"
echo "   5. Check for auth/network errors ⬆️"
echo ""
echo "💡 If messages aren't reaching SDL, check:"
echo "   - API token validity (AISIEM_LOGACCESS_WRITE_TOKEN)"
echo "   - Network connectivity to $AISIEM_SERVER"
echo "   - File pattern matching between syslog-ng and agent.json"
echo "   - Scalyr-agent logs for specific error messages"
