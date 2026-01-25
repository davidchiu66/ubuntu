# 基础镜像
FROM ubuntu:22.04

# 核心环境变量（解决交互式安装、时区等问题）
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR="/root/.nvm"
# 注意：这个敏感信息建议用secret管理，仅保留适配你的原有配置
ENV SSH_PASSWORD="ubuntu123"  
ENV TZ=Asia/Shanghai

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY reboot.sh /usr/local/sbin/reboot
COPY index.js /index.js
COPY app.js /app.js
COPY package.json /package.json
COPY app.py /app.py
COPY requirements.txt /requirements.txt

# 安装所有基础依赖（整合你日志里的所有依赖）
RUN apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 python3.10 pip --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    chmod +x index.js; \
    chmod +x app.py; \
    chmod +x app.js; \
    chmod +x app.sh; \
    chmod +x /data/komari/start.sh; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
     echo $TZ > /etc/timezone

# 安装nvm + Node.js 20.10.0（核心：无任何嵌套shell，全程在同一个shell执行）
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash;  \
    # 直接加载nvm（. 等同于source，在当前shell生效）
    . "$NVM_DIR/nvm.sh" ;  \
    # 安装指定版本Node.js
    nvm install 20.10.0 ;  \
    # 设置默认版本
    nvm alias default 20.10.0 ;  \
    # 验证安装（此时能执行说明nvm生效）
    node -v && npm -v ;  \
    # 清理nvm缓存，减小镜像体积
    nvm cache clear

# 全局配置PATH（关键：确保容器内所有进程都能找到node/npm）
ENV PATH="$NVM_DIR/versions/node/v20.10.0/bin:$PATH"

# 二次验证：确保全局PATH生效（非必需，但能提前发现问题）
RUN node -v && npm -v

EXPOSE 22/tcp

# 容器启动命令
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
