#!/bin/bash

# 自动赋予当前目录下所有脚本执行权限（屏蔽报错信息）
chmod +x -R ./* 2>/dev/null

# 定义终端颜色，让菜单更好看
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

while true; do
    clear
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${YELLOW}       🚀 服务器自动化运维总控台          ${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${GREEN}  1.${NC} 💬 部署 / 维护 Mattermost 聊天系统"
    echo -e "${GREEN}  2.${NC} 🌐 配置 Tailscale 虚拟局域网节点"
    echo -e "${GREEN}  3.${NC} 🤖 部署本地 AI 大模型 (Qwen/llama.cpp) 环境"
    echo -e "${GREEN}  4.${NC} 🔧 基础系统环境初始化"
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${RED}  0.${NC} 退出控制台"
    echo -e "${CYAN}==========================================${NC}"
    echo ""
    
    read -p "请输入对应序号 (0-4): " choice
    
    case $choice in
        1)
            echo -e "\n${YELLOW}>>> 准备进入 Mattermost 部署流程...${NC}"
            # 尝试进入目录并执行，如果找不到脚本会友好提示
            if [ -f "./docker/mattermost/deploy.sh" ]; then
                cd docker/mattermost && ./deploy.sh && cd ../..
            else
                echo -e "${RED}尚未创建对应的脚本: ./docker/mattermost/deploy.sh${NC}"
            fi
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;
        2)
            echo -e "\n${YELLOW}>>> 准备配置 Tailscale...${NC}"
            if [ -f "./network/tailscale_setup.sh" ]; then
                ./network/tailscale_setup.sh
            else
                echo -e "${RED}尚未创建对应的脚本: ./network/tailscale_setup.sh${NC}"
            fi
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;
        3)
            echo -e "\n${YELLOW}>>> 准备配置 AI 大模型运算环境...${NC}"
            if [ -f "./ai/setup_llm.sh" ]; then
                ./ai/setup_llm.sh
            else
                echo -e "${RED}尚未创建对应的脚本: ./ai/setup_llm.sh${NC}"
            fi
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;
        4)
            echo -e "\n${YELLOW}>>> 准备运行系统初始化...${NC}"
            if [ -f "./system/init.sh" ]; then
                ./system/init.sh
            else
                echo -e "${RED}尚未创建对应的脚本: ./system/init.sh${NC}"
            fi
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;
        0)
            echo -e "\n${GREEN}已安全退出控制台。${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}无效的输入，请重新选择！${NC}"
            sleep 1
            ;;
    esac
done
