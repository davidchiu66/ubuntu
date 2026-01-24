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
COPY app.py /app.py
COPY requirements.txt /requirements.txt
COPY app.sh /app.sh

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 nano htop python3.10 pip --no-install-recommends; \
    apt-get clean; \
    pip install -r requirements.txt; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    chmod +x index.js; \
    chmod +x app.py; \
    chmod +x appy.js; \
    chmod +x app.sh; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

# 禁用nvm的交互式提示
ENV NVM_DIR="/root/.nvm"

# 安装nvm + Node.js 20.10.0（全程无嵌套shell，无.bashrc依赖）
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    # 直接加载nvm（. 等同于source）
    . "$NVM_DIR/nvm.sh" && \
    # 安装指定版本
    nvm install 20.10.0 && \
    # 设置默认版本
    nvm alias default 20.10.0 && \
    # 验证安装（关键：此时能执行说明nvm生效）
    node -v && npm -v && \
    # 清理缓存
    nvm cache clear

# 全局配置PATH（确保任何环境都能找到node/npm）
ENV PATH="$NVM_DIR/versions/node/v20.10.0/bin:$PATH"

# 验证全局PATH是否生效
RUN node -v && npm -v

# 启动脚本可执行
RUN chmod +x /data/komari/start.sh

EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D"]
# CMD 指令指向 supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
