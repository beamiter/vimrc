# 使用官方Ubuntu 20.04 LTS版本作为基础镜像
FROM ubuntu:latest

# 设置工作目录
WORKDIR /app

# 安装Python和pip
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y python3 python3-pip && \
    apt-get install -y software-properties-common \
    apt-get install -y curl git wget zsh cargo && \
    add-apt-repository ppa:jonathonf/vim && \
    add-apt-repository ppa:neovim-ppa/unstable && \
    apt-get update && \
    apt-get install -y vim neovim && \
    pip install jill jupyter notebook jupyterlab && \
    cargo install bob-nvim


# 复制当前目录下的所有文件到容器中的/app目录
# COPY . /app

# 安装requirements.txt中指定的Python依赖
# RUN pip3 install --no-cache-dir -r requirements.txt

# 内部端口
EXPOSE 1234 1235 1236 1237 1238 1229 1240 8888 8889 8890 8891 8892

# 运行app.py时，容器启动
# CMD ["python3", "app.py"]
