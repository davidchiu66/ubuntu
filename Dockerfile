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
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 配置nvm环境变量，并安装指定版本Node.js（示例：v20.10.0）
# 注意：需要先加载nvm，再安装Node.js
RUN echo "source $HOME/.nvm/nvm.sh" >> $HOME/.bashrc && \
    /bin/bash -c "source $HOME/.bashrc && \
    nvm install 20.10.0 && \
    nvm alias default 20.10.0 && \
    # 验证安装
    node -v && npm -v"

# 确保容器启动时nvm生效（可选，若启动脚本需要Node.js）
ENV NVM_DIR="/root/.nvm"
ENV PATH="$NVM_DIR/versions/node/v20.10.0/bin:$PATH"

# 创建必要目录
RUN mkdir -p /data/logs

# 启动脚本可执行
RUN chmod +x /data/komari/start.sh

EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D"]
# CMD 指令指向 supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
