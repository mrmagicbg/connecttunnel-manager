# Disconnect Timeout Fix

**Version:** 1.0.1  
**Date:** January 27, 2026  
**Issue:** Disconnect command timing out after 5 seconds

---

## Problem

Users experienced disconnect timeout errors:

```
Error during disconnect:
Command ['bash', '/usr/local/Aventail/startct.sh', 'stop'] timed out after 5 seconds

The tunnel may still be running.
```

This occurred because:
1. The VPN disconnect process can take longer than 5 seconds
2. The `startct.sh stop` script sometimes hangs
3. No fallback mechanism was in place

---

## Solution Implemented

### Changes Made

#### 1. Increased Timeout
- **Before:** 5 seconds
- **After:** 30 seconds
- **Reason:** VPN disconnect legitimately takes 10-20 seconds in some cases

#### 2. Added Timeout Exception Handling
```python
except subprocess.TimeoutExpired:
    # Specific handling for timeout
    # Automatically attempts force-kill
```

#### 3. Force-Kill Fallback
If normal disconnect times out:
1. Automatically runs `pkill -9 -f SnwlConnect.jar`
2. Also kills `startctui.sh` processes
3. Notifies user of force disconnect

#### 4. Post-Disconnect Verification
After disconnect attempt:
1. Waits 1 second
2. Checks if process is still running
3. Warns user if process persists

---

## Technical Details

### Old Code
```python
try:
    subprocess.run(
        ["bash", str(self.connect_script), "stop"],
        timeout=5,  # Too short!
        capture_output=True
    )
    time.sleep(1)
    subprocess.run(
        ["pkill", "-9", "-f", "SnwlConnect.jar"],
        timeout=2,
        capture_output=True
    )
    # Success message
except Exception as e:
    # Generic error handling
```

### New Code
```python
try:
    subprocess.run(
        ["bash", str(self.connect_script), "stop"],
        timeout=30,  # Increased!
        capture_output=True,
        text=True
    )
    time.sleep(2)
    
    # Force kill remaining processes
    subprocess.run(["pkill", "-9", "-f", "SnwlConnect.jar"], timeout=5)
    subprocess.run(["pkill", "-9", "-f", "startctui.sh"], timeout=5)
    
    # Verify disconnection
    time.sleep(1)
    check_result = subprocess.run(["pgrep", "-f", "SnwlConnect.jar"])
    
    if check_result.returncode == 0:
        # Warn about running process
    else:
        # Success
        
except subprocess.TimeoutExpired:
    # Specific timeout handling
    # Force kill and notify
    
except Exception as e:
    # Other errors
```

---

## Impact

### Files Modified
1. `bin/connecttunnel-control-panel` - Control Panel disconnect function
2. `CHANGELOG.md` - Version 1.0.1 notes

### User Experience Improvements

**Before:**
- Disconnect failed with cryptic timeout error
- User had to manually kill processes
- No guidance on what to do next

**After:**
- Disconnect waits longer (30s) for clean shutdown
- Automatic force-kill if timeout occurs
- Clear status verification
- Helpful error messages

---

## Testing

### Test Scenarios

#### 1. Normal Disconnect (Fast)
- **Expected:** Disconnect in < 5 seconds
- **Result:** ✅ Works perfectly
- **Experience:** Quick, clean disconnect

#### 2. Slow Disconnect (10-20 seconds)
- **Expected:** Disconnect in 10-20 seconds
- **Result:** ✅ Now works (previously failed)
- **Experience:** Brief wait, then success

#### 3. Hung Process (> 30 seconds)
- **Expected:** Timeout, then force kill
- **Result:** ✅ Force kills successfully
- **Experience:** Timeout message, then force disconnect notification

#### 4. Stubborn Process
- **Expected:** Force kill might fail
- **Result:** ✅ Warning shown to user
- **Experience:** Clear guidance on manual intervention

---

## Manual Disconnect (If Needed)

If automatic disconnect fails completely:

```bash
# Check if running
pgrep -f SnwlConnect

# Force kill
sudo pkill -9 -f SnwlConnect
sudo pkill -9 -f startctui

# Verify stopped
pgrep -f SnwlConnect
# (Should return nothing)
```

Or use the CLI helper:
```bash
connecttunnel-helper --disconnect
```

---

## Prevention

To avoid disconnect issues:

1. **Allow sufficient time** - Don't interrupt disconnect process
2. **Close tunnel window** before disconnecting
3. **Check status** after disconnect
4. **Use force kill** only as last resort

---

## Future Improvements

Potential enhancements:

1. **Progressive timeout**: Try clean disconnect first, then escalate
2. **Background disconnect**: Don't block UI during disconnect
3. **Status streaming**: Show real-time disconnect progress
4. **Automatic retry**: Retry disconnect if first attempt fails
5. **VPN state check**: Verify actual VPN connection state, not just process

---

## Related Issues

- ConnectTunnel Java-based GUI limitations
- Process management on different Linux distributions
- VPN daemon behavior variations

---

## Summary

**Problem:** 5-second timeout too short for VPN disconnect  
**Solution:** 30-second timeout + force-kill fallback + verification  
**Result:** Reliable disconnect that handles edge cases gracefully  

**Status:** ✅ Fixed in version 1.0.1

---

*Last updated: January 27, 2026*
