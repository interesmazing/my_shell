#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "此脚本需要以 root 权限运行，请使用 sudo 执行。"
  exit 1
fi

# 更新软件包并升级系统
echo "正在更新软件包列表并升级系统..."
apt update && apt upgrade -y
if [ $? -ne 0 ]; then
  echo "更新软件包失败，请检查网络连接或系统状态。"
  exit 1
fi

# 安装构建 Python 所需的依赖项
echo "正在安装构建 Python 所需的依赖项..."
apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git
if [ $? -ne 0 ]; then
  echo "安装依赖项失败，请检查软件包源。"
  exit 1
fi

# 下载 Python 3.10.13 源代码
echo "正在下载 Python 3.10.13 源代码..."
wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz
if [ $? -ne 0 ]; then
  echo "下载 Python 源代码失败，请检查网络连接。"
  exit 1
fi

# 解压缩下载的文件
echo "正在解压缩 Python 源代码..."
tar xvf Python-3.10.13.tgz
if [ $? -ne 0 ]; then
  echo "解压缩失败，请检查下载的文件是否完整。"
  exit 1
fi

# 进入解压缩后的目录
cd Python-3.10.13 || {
  echo "进入 Python 源代码目录失败。"
  exit 1
}

# 配置并编译 Python
echo "正在配置并编译 Python 3.10.13（可能需要一些时间）..."
./configure --enable-optimizations
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo "编译 Python 失败，请检查环境或依赖项。"
  exit 1
fi

# 安装 Python
echo "正在安装 Python 3.10.13..."
make altinstall
if [ $? -ne 0 ]; then
  echo "安装 Python 失败，请检查前面的步骤。"
  exit 1
fi

# 清理源代码和压缩包
echo "正在清理源代码和压缩包..."
cd ..
rm -rf Python-3.10.13 Python-3.10.13.tgz

# 安装 pip
echo "正在安装 pip..."
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
if [ $? -ne 0 ]; then
  echo "下载 pip 安装脚本失败，请检查网络连接。"
  exit 1
fi

python3.10 get-pip.py
if [ $? -ne 0 ]; then
  echo "安装 pip 失败，请检查 Python 安装是否正常。"
  exit 1
fi

rm -f get-pip.py

# 验证安装
echo "Python 3.10.13 和 pip 安装完成！"
python3.10 --version
pip3.10 --version

echo "安装过程已完成！"