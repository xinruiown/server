#!/bin/bash
# 自动创建应用目录并进入
mkdir -p /root/docker/rocketchat && cd /root/docker/rocketchat

# 写入 docker-compose.yml 配置文件 (一键编排数据库与主应用)
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  rocketchat:
    image: registry.rocket.chat/rocketchat/rocket.chat:latest
    command: >
      bash -c
        "for i in \`seq 1 30\`; do
          node main.js &&
          s=\$$? && break || s=\$$?;
          echo \"Tried \$$i times. Waiting 5 secs...\";
          sleep 5;
        done; (exit \$$s)"
    restart: always
    environment:
      - PORT=3000
      - ROOT_URL=http://localhost:3000
      - MONGO_URL=mongodb://mongo:27017/rocketchat?replicaSet=rs0
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local?replicaSet=rs0
    depends_on:
      - mongo
    ports:
      - "3000:3000"

  mongo:
    image: mongo:5.0
    restart: always
    command: mongod --replSet rs0 --oplogSize 128
    volumes:
      - ./data/db:/data/db
EOF

# 启动服务
docker compose up -d

# 自动初始化 MongoDB 副本集 (替代了原网页繁琐的手动初始化)
echo "等待数据库启动..."
sleep 10
docker exec -it rocketchat-mongo-1 mongosh --eval "rs.initiate({_id: 'rs0', members: [{ _id: 0, host: 'mongo:27017' }]})"

echo "🎉 Rocket.Chat 部署完成！请访问 http://服务器IP:3000"
