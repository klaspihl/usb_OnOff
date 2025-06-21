# USB Fan Control Script

This project provides a Bash script to automatically control the power state of a USB port (for example, to turn a USB fan on or off) based on the system's CPU temperature. The script is designed to run inside a Docker container and can be orchestrated with Docker Compose.

## What the Script Does
- Monitors the CPU temperature using the `sensors` command (from the `lm-sensors` package).
- Turns the USB port ON or OFF using `uhubctl` depending on configurable temperature thresholds.
- Logs each ON/OFF event with a timestamp and the current temperature.
- Handles stop/restart signals for immediate shutdown (useful for Docker environments).

## Packages Used
- **lm-sensors**: For reading CPU temperature.
- **uhubctl**: For controlling USB port power state.

## Environment Variables
You can configure the script using the following environment variables:
- `TEMP_THRESHOLD_HIGH`: Temperature (°C) to turn the USB port ON (default: 65)
- `TEMP_THRESHOLD_LOW`: Temperature (°C) to turn the USB port OFF (default: 45)
- `FREQ`: How often (in seconds) to check the temperature (default: 30)
- `UHUBCTL_LOCATION`: The USB hub location for uhubctl `-l` (default: 7-1)
- `UHUBCTL_PORT`: The USB port number for uhubctl `-p` (default: 2)

## Example: docker-compose.yml (using Docker Hub image)
```yaml
services:
  usb-fan:
    image: klaspihl/usb_onoff:latest
    devices:
      - "/dev/bus/usb:/dev/bus/usb"
    privileged: true
    restart: unless-stopped
    environment:
      - TEMP_THRESHOLD_HIGH=65
      - TEMP_THRESHOLD_LOW=45
      - FREQ=30
      - UHUBCTL_LOCATION=7-1
      - UHUBCTL_PORT=2
    healthcheck:
      test: ["CMD", "pgrep", "-f", "usb_OnOff.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Example: Run Directly with Docker or Podman

```bash
# With Docker
docker run --rm -it \
  --device /dev/bus/usb:/dev/bus/usb \
  --privileged \
  -e TEMP_THRESHOLD_HIGH=65 \
  -e TEMP_THRESHOLD_LOW=45 \
  -e FREQ=30 \
  -e UHUBCTL_LOCATION=7-1 \
  -e UHUBCTL_PORT=2 \
  klaspihl/usb_onoff:latest

# With Podman
podman run --rm -it \
  --device /dev/bus/usb:/dev/bus/usb \
  --privileged \
  -e TEMP_THRESHOLD_HIGH=65 \
  -e TEMP_THRESHOLD_LOW=45 \
  -e FREQ=30 \
  -e UHUBCTL_LOCATION=7-1 \
  -e UHUBCTL_PORT=2 \
  klaspihl/usb_onoff:latest
```

## Usage
1. Pull and start the container using the docker-compose file from the GitHub repository:
   ```bash
   curl -O https://raw.githubusercontent.com/klaspihl/usb_OnOff/main/docker-compose.yml
   docker compose -f docker-compose.yml up
   ```

2. The script will automatically monitor the temperature and control the USB port power.

## Notes
- Make sure your USB hub supports per-port power switching and is compatible with `uhubctl`.
- You may need to adjust the `uhubctl` parameters (`-l` and `-p`) in the script to match your hardware setup.
