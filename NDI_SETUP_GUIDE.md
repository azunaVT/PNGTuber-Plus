# NDI Output for PNGTuber-Plus

This guide explains how to use the NDI (Network Device Interface) output feature in PNGTuber-Plus to stream your avatar to OBS Studio or other NDI-compatible applications.

## Requirements

1. **NDI Runtime**: Download and install the NDI Runtime from [NDI website](http://ndi.link/NDIRedistV6)
   - Windows: [NDI Runtime for Windows](http://ndi.link/NDIRedistV6)
   - macOS: [NDI Runtime for macOS](http://ndi.link/NDIRedistV6Apple)
   - Linux: [NDI Runtime for Linux](https://github.com/DistroAV/DistroAV/wiki/1.-Installation#linux) (Note: Flatpak incompatible)

2. **Godot 4.4-stable or later**: This plugin requires Godot 4.4+ to function properly

3. **NDI-compatible software**: Such as OBS Studio with NDI plugin, vMix, Wirecast, etc.

## Features

- **Real-time NDI streaming**: Stream your PNGTuber avatar over the network
- **Audio support**: Include system audio in the NDI stream (optional)
- **Customizable source name**: Set a custom name for your NDI source
- **Hotkey controls**: Quick toggle streaming with keyboard shortcuts
- **Settings UI**: Easy configuration through the settings menu

## Getting Started

### 1. Basic Setup

The NDI output is automatically enabled when you start PNGTuber-Plus. The default settings are:
- **Source Name**: "PNGTuber-Plus"
- **Audio**: Enabled (Master bus)
- **Auto-start**: Enabled

### 2. Settings Menu Configuration

Access the NDI settings through the Settings Menu:

1. Click the settings wheel in PNGTuber-Plus
2. Scroll down to find the "NDI streaming" section
3. Configure the following options:
   - **NDI streaming**: Enable/disable NDI output
   - **Source name**: Set a custom name for your NDI source (default: "PNGTuber-Plus")
   - **Include audio**: Toggle audio streaming on/off
   - **Avatar-only stream**: Enable a clean avatar-only stream without UI elements
   - **Status**: View current streaming status
   - **Start/Stop NDI**: Manual control button

#### Avatar-Only Streaming

The "Avatar-only stream" option creates a second NDI source called "PNGTuber Avatar" that:
- Streams only the avatar sprites with a transparent background
- Excludes all UI elements, menus, and controls
- Perfect for professional streaming setups
- Syncs automatically with the main avatar state

### 3. Hotkey Controls

Quick keyboard shortcuts for NDI control:
- **F9**: Toggle NDI streaming on/off
- **F10**: Restart NDI streaming (useful for applying new settings)

### 4. OBS Studio Setup

To capture the NDI stream in OBS Studio:

1. **Install NDI Plugin for OBS**:
   - Download from [OBS NDI Plugin](https://github.com/Palakis/obs-ndi/releases)
   - Install following the provided instructions

2. **Add NDI Source in OBS**:
   - In OBS, click the "+" in Sources
   - Select "NDI Source"
   - Name your source (e.g., "PNGTuber Avatar")
   - In the properties, select your NDI source from the dropdown
     - Look for "PNGTuber-Plus" (or your custom name)
   - Configure audio settings as needed

3. **Position and Scale**:
   - Resize and position the NDI source in your scene
   - The stream will include the full PNGTuber viewport

## Troubleshooting

### NDI Source Not Appearing in OBS

1. **Check NDI Runtime**: Ensure NDI Runtime is installed on both machines
2. **Network connectivity**: NDI works over network, ensure devices can communicate
3. **Firewall settings**: NDI uses specific ports, check firewall rules
4. **Restart applications**: Try restarting both PNGTuber-Plus and OBS
5. **Check source name**: Verify the NDI source name matches in settings

### Audio Issues

1. **Audio bus**: Ensure the correct audio bus is selected (default: "Master")
2. **System audio**: Check that PNGTuber-Plus is receiving audio input
3. **OBS audio settings**: Verify NDI source audio is not muted in OBS

### Performance Issues

1. **Network bandwidth**: NDI requires good network performance for quality streaming
2. **Local streaming**: For best performance, use NDI on the same machine
3. **Resolution**: Lower viewport resolution if experiencing lag
4. **Frame rate**: Adjust FPS settings in PNGTuber-Plus settings

### NDI Not Working

1. **Godot version**: Ensure you're using Godot 4.4-stable or later
2. **Plugin enabled**: Verify the godot-ndi plugin is properly installed
3. **System compatibility**: Check NDI Runtime compatibility with your OS
4. **Console errors**: Check Godot console for any NDI-related errors

## Advanced Configuration

### Custom Audio Bus

You can route specific audio to NDI by:
1. Creating a custom audio bus in PNGTuber-Plus
2. Setting the NDI audio bus to your custom bus name
3. Routing desired audio sources to that bus

### Network Performance

For optimal network streaming:
- Use wired connections when possible
- Ensure sufficient bandwidth (>100 Mbps recommended for high quality)
- Keep NDI devices on the same network segment
- Consider NDI quality settings if available

### Multiple Instances

You can run multiple PNGTuber-Plus instances with different NDI source names:
1. Change the "Source name" in each instance
2. Each will appear as a separate NDI source
3. Useful for multiple avatars or backup streams

## Technical Details

- **Video Format**: NDI handles video format automatically based on viewport
- **Audio Format**: Uses the selected audio bus output
- **Compression**: NDI uses efficient compression for network streaming
- **Latency**: Typically very low latency (<1 frame) on local network

## Legal Notice

NDI® is a registered trademark of Vizrt NDI AB. Your application must comply with the [NDI SDK license](http://ndi.link/ndisdk_license) when using this feature.

## Support

For issues specific to NDI functionality:
1. Check the console output for error messages
2. Verify NDI Runtime installation
3. Test with other NDI applications to isolate issues
4. Check network connectivity for remote streaming

For PNGTuber-Plus specific issues, refer to the main application documentation and support channels.
