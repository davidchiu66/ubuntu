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
    
# 安装nvm（Node版本管理器）
# 1. 安装nvm并指定版本，避免版本兼容问题
# 2. 直接加载nvm脚本，不依赖.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    # 手动加载nvm环境（关键：直接指定nvm路径，不依赖bashrc）
    . $HOME/.nvm/nvm.sh && \
    # 安装指定版本Node.js
    nvm install 20.10.0 && \
    # 设置默认版本
    nvm alias default 20.10.0 && \
    # 验证安装
    node -v && npm -v && \
    # 清理nvm缓存，减小镜像体积
    nvm cache clear

# 配置环境变量，确保容器内任何环境都能找到node/npm（关键）
ENV NVM_DIR="/root/.nvm"
# 动态拼接node路径，避免硬编码版本号
ENV PATH="$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node)/bin:$PATH"

# 启动脚本可执行
RUN chmod +x /data/komari/start.sh

EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D"]
# CMD 指令指向 supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
