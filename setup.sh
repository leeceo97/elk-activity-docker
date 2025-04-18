#!/bin/bash

# 디렉토리 생성
mkdir -p elastic-stack
cd elastic-stack

# docker-compose.yml 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.1
    container_name: elasticsearch
    environment:
      - node.name=elasticsearch
      - cluster.name=es-docker-cluster
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=true
      - ELASTIC_PASSWORD=admin
      - ELASTIC_USERNAME=admin
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - elastic
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200"]
      interval: 30s
      timeout: 10s
      retries: 5

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.1
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - ELASTICSEARCH_USERNAME=admin
      - ELASTICSEARCH_PASSWORD=admin
    ports:
      - "5601:5601"
    networks:
      - elastic
    depends_on:
      - elasticsearch
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5601"]
      interval: 30s
      timeout: 10s
      retries: 5

networks:
  elastic:
    driver: bridge

volumes:
  elasticsearch-data:
    driver: local
EOF

# 시스템 설정 최적화 (Elasticsearch용)
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Docker Compose 실행
docker-compose up -d

echo "- Elasticsearch: http://localhost:9200"
echo "- Kibana: http://localhost:5601"
echo "- 사용자 이름: admin"
echo "- 비밀번호: admin"
