#!/bin/bash

# ==========================================
# 颜色定义
# ==========================================
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}==========================================${NC}"
echo -e "${YELLOW}       🚀 服务器开机初始化一键脚本        ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. 强制检查是否为 root 用户执行
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[✘] 致命错误：修改 SSH 配置和系统密码需要最高权限！${NC}"
    echo -e "${YELLOW}请使用 'sudo -i' 切换到 root 用户，或者在执行命令前加 sudo。${NC}"
    exit 1
fi

echo -e "\n${CYAN}[阶段 1/3] 正在安装基础组件 (curl)...${NC}"
# 智能识别包管理器并执行对应安装命令
if command -v apt >/dev/null 2>&1; then
    echo -e "${GREEN}>>> 检测到 Debian/Ubuntu 系统，使用 apt 安装...${NC}"
    apt update -y && apt install -y curl
elif command -v yum >/dev/null 2>&1; then
    echo -e "${GREEN}>>> 检测到 CentOS/RedHat/Rocky 系统，使用 yum 安装...${NC}"
    yum update -y && yum install -y curl
elif command -v apk >/dev/null 2>&1; then
    echo -e "${GREEN}>>> 检测到 Alpine Linux 系统，使用 apk 安装...${NC}"
    apk update && apk add curl
else
    echo -e "${YELLOW}[!] 未识别到主流包管理器，跳过自动安装 curl。${NC}"
fi

echo -e "\n${CYAN}[阶段 2/3] 配置 Root 密码...${NC}"
# 交互式输入密码（-s 隐藏输入内容，防止旁人偷窥）
read -s -p "$(echo -e ${YELLOW}"请输入你要设置的 Root 密码 (输入时不显示字符): "${NC})" NEW_PASS
echo "" # 补充一个换行符

# 再次输入以防止手误打错
read -s -p "$(echo -e ${YELLOW}"请再次输入密码以确认: "${NC})" NEW_PASS_CONFIRM
echo "" # 补充一个换行符

# 判断两次密码是否一致
if [ "$NEW_PASS" != "$NEW_PASS_CONFIRM" ]; then
    echo -e "${RED}[✘] 致命错误：两次输入的密码不一致，脚本已安全中止！${NC}"
    exit 1
fi

# 确认无误，执行修改
echo "root:${NEW_PASS}" | chpasswd
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✔] Root 密码已成功修改。${NC}"
else
    echo -e "${RED}[✘] Root 密码修改失败！${NC}"
    exit 1
fi

echo -e "\n${CYAN}[阶段 3/3] 开启 Root SSH 登录权限...${NC}"
# 备份原配置文件以防万一
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改主配置：开启 Root 登录与密码验证
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 处理部分系统 (如 Ubuntu 22.04+) cloud-init 子配置覆盖问题
if [ -d /etc/ssh/sshd_config.d ]; then
    for conf in /etc/ssh/sshd_config.d/*.conf; do
        if [ -f "$conf" ]; then
            sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' "$conf"
        fi
    done
fi
echo -e "${GREEN}[✔] SSH 配置文件修改完成。${NC}"

# 重启 SSH 服务使配置生效
echo -e "${YELLOW}>>> 正在重启 SSH 服务...${NC}"
if systemctl is-active --quiet sshd; then
    systemctl restart sshd
elif systemctl is-active --quiet ssh; then
    systemctl restart ssh
elif service sshd status >/dev/null 2>&1; then
    service sshd restart
elif service ssh status >/dev/null 2>&1; then
    service ssh restart
else
    /etc/init.d/ssh restart || /etc/init.d/sshd restart
fi

echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}🎉 服务器初始化全部完成！${NC}"
echo -e "现在的登录账号: ${YELLOW}root${NC}"
echo -e "登录密码为您刚刚手动设置的密码。${NC}"
echo -e "${CYAN}==========================================${NC}"
echo -e "${YELLOW}建议您现在打开一个新的终端窗口，测试 root 登录是否正常。${NC}"
