#!/bin/bash
# ConnectTunnel Manager - Disconnect Test & Debug Helper

echo "=== ConnectTunnel Debug Helper ==="
echo ""

echo "1. Checking for running ConnectTunnel processes..."
if pgrep -f "SnwlConnect.jar" > /dev/null; then
    echo "✓ ConnectTunnel IS running"
    echo "  PID(s): $(pgrep -f 'SnwlConnect.jar' | tr '\n' ' ')"
    ps aux | grep "SnwlConnect.jar" | grep -v grep
else
    echo "✗ ConnectTunnel is NOT running"
fi

echo ""
echo "2. Checking for ConnectTunnel UI processes..."
if pgrep -f "startctui.sh" > /dev/null; then
    echo "✓ startctui.sh IS running"
    echo "  PID(s): $(pgrep -f 'startctui.sh' | tr '\n' ' ')"
else
    echo "✗ startctui.sh is NOT running"
fi

echo ""
echo "3. Checking for Java processes..."
if pgrep -f "java.*Aventail" > /dev/null; then
    echo "✓ Java processes found:"
    ps aux | grep "java" | grep "Aventail" | grep -v grep
else
    echo "✗ No Aventail Java processes"
fi

echo ""
echo "4. Testing disconnect sequence..."
echo ""
read -r -p "Press Enter to test SIGTERM (graceful shutdown)..."

echo "→ Sending SIGTERM..."
pkill -TERM -f "SnwlConnect.jar"
sleep 1

if pgrep -f "SnwlConnect.jar" > /dev/null; then
    echo "⚠ Process still running after SIGTERM"
    echo "→ Sending SIGKILL (force kill)..."
    pkill -9 -f "SnwlConnect.jar"
    pkill -9 -f "startctui.sh"
    sleep 1
    
    if pgrep -f "SnwlConnect.jar" > /dev/null; then
        echo "✗ ERROR: Process STILL running after SIGKILL!"
    else
        echo "✓ Process killed with SIGKILL"
    fi
else
    echo "✓ Process stopped gracefully with SIGTERM"
fi

echo ""
echo "5. Final status check..."
if pgrep -f "SnwlConnect.jar" > /dev/null; then
    echo "✗ ConnectTunnel STILL RUNNING"
    echo "  Manual kill required:"
    echo "  sudo pkill -9 -f SnwlConnect"
else
    echo "✓ ConnectTunnel fully stopped"
fi

echo ""
echo "=== Debug Complete ==="
