set -e

# 检查必须环境变量
if [ -z "$DOCKER_REGISTRY" ] || [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "错误：未配置环境变量 DOCKER_REGISTRY, DOCKER_USERNAME, DOCKER_PASSWORD" >&2
    exit 1
fi

# 切换目录

WORKSPACE_DIR="$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )"
cd $WORKSPACE_DIR

# 检查配置文件
if [ ! -f "src.yaml" ]; then
    echo "错误：配置文件src.yaml不存在" >&2
    exit 1
fi

# 登录到目标仓库
echo "正在登录到 ${DOCKER_REGISTRY}..." >&2
skopeo login \
  --username="${DOCKER_USERNAME}" \
  --password-stdin \
  "${DOCKER_REGISTRY}" <<< "${DOCKER_PASSWORD}" || {
  echo "登录失败" >&2
  exit 1
}

# 执行镜像同步
echo "开始同步镜像到 ${DOCKER_REGISTRY}..." >&2
skopeo sync --scoped \
  --src yaml \
  --dest docker \
  ./src.yaml \
  "${DOCKER_REGISTRY}" || {
  echo "镜像同步失败" >&2
  exit 1
}

echo "镜像同步成功完成" >&2
