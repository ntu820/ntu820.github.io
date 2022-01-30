# 卸载旧版本
yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine


# 设置 yum repository
yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo



# 安装并启动 docker
yum install -y docker-ce-19.03.8 docker-ce-cli-19.03.8 containerd.io

systemctl enable docker
systemctl start docker


# 安装 nfs-utils
# 必须先安装 nfs-utils 才能挂载 nfs 网络存储
yum install -y nfs-utils
yum install -y wget
yum install -y net-tools

# 时间同步
yum install -y ntpdate
ntpdate time.windows.com

# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld


# 关闭 SeLinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config


# 关闭 swap
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab


# 修改 /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
# 可能没有，追加
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
# 执行命令以应用
sysctl -p

# 配置镜像加速器
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://j54517kd.mirror.aliyuncs.com","http://f1361db2.m.daocloud.io","https://mirror.ccs.tencentyun.com","http://hub-mirror.c.163.com"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

docker info
