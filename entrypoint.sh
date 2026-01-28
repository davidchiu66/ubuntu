#!/usr/bin/env sh
set -e

# ===============================
# 修改 root 密码（运行时）
# ===============================
if [ -n "$ROOT_PASSWORD" ]; then
    echo "[INFO] ROOT_PASSWORD detected, updating root password..."

    echo "root:${ROOT_PASSWORD}" | chpasswd

    # 可选：防止密码被打印或继承
    unset ROOT_PASSWORD
else
    echo "[INFO] ROOT_PASSWORD not set, skip root password update"
fi

# ===============================
# 启用 root SSH 登录（如果你需要）
# ===============================
if [ -f /etc/ssh/sshd_config ]; then
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
fi

useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
# echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# ===============================
# 启动原有服务
# ===============================
exec "$@"
