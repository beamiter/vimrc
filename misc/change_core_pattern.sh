# 设置 core dump 模式为 /tmp/core-%e-%p-%t
sudo sysctl kernel.core_pattern="/tmp/core-%e-%p-%t"

# 验证设置
cat /proc/sys/kernel/core_pattern

# 编辑 sysctl 配置文件
sudo nano /etc/sysctl.conf

# 添加以下行
kernel.core_pattern=/tmp/core-%e-%p-%t

# 应用配置
sudo sysctl -p
