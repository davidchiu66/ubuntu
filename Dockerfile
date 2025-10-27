FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/vevc/ubuntu"

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=12345678

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY reboot.sh /usr/local/sbin/reboot
COPY index.js /index.js
COPY app.js /app.js
COPY package.json /package.json
COPY app.sh /app.sh

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 nodejs npm --no-install-recommends; \
    apt-get clean; \
    npm install; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    chmod +x index.js; \
    chmod +x app.sh; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

EXPOSE 10000/tcp

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D"]
# CMD 指令指向 supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
