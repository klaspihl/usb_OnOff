FROM debian:stable-slim

ENV TEMP_THRESHOLD_HIGH=65 \
    TEMP_THRESHOLD_LOW=45 \
    FREQ=30 \
    UHUBCTL_LOCATION=7-1 \
    UHUBCTL_PORT=2

RUN apt-get update && \
    apt-get install -y lm-sensors uhubctl && \
    rm -rf /var/lib/apt/lists/*

COPY usb_OnOff.sh /usr/local/bin/usb_OnOff.sh
RUN chmod +x /usr/local/bin/usb_OnOff.sh

CMD ["/usr/local/bin/usb_OnOff.sh"]
