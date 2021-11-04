#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

chattr -i /www/server/panel/install/public.sh
chattr -i /www/server/panel/install/check.sh
echo -e "欢迎使用www.HostCli.com脚本..."
echo -e "若在使用中发现问题，请及时反馈！"
if [ ! -d /www/server/panel/BTPanel ];then
	echo "============================================="
	echo "错误, 5.x不可以使用此命令升级!"
	exit 0;
fi

public_file=/www/server/panel/install/public.sh

. $public_file

Centos8Check=$(cat /etc/redhat-release | grep ' 8.' | grep -iE 'centos|Red Hat')
if [ "${Centos8Check}" ];then
	if [ ! -f "/usr/bin/python" ] && [ -f "/usr/bin/python3" ] && [ ! -d "/www/server/panel/pyenv" ]; then
		ln -sf /usr/bin/python3 /usr/bin/python
	fi
fi

mypip="pip"
env_path=/www/server/panel/pyenv/bin/activate
if [ -f $env_path ];then
	mypip="/www/server/panel/pyenv/bin/pip"
fi

download_Url=$NODE_URL
downloader_Url=http://download.hostcli.com
setup_path=/www
version=$(curl -Ss --connect-timeout 5 -m 2 http://www.hostcli.com/api/get_version.php)
if [ "$version" = '' ];then
	version='7.4.5'
fi

wget -T 5 -O /tmp/panel.zip $downloader_Url/install/update/LinuxPanel-7.4.5.zip
sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
echo "127.0.0.1 www.bt.cn" >> /etc/hosts
sed -i 's/[0-9\.]\+[ ]\+www.bt.cn/127.0.0.1 www.bt.cn/g' /etc/hosts
wget -O /www/server/panel/data/plugin.json http://www.hostcli.com/api/panel/get_soft_list_test
dsize=$(du -b /tmp/panel.zip|awk '{print $1}')
if [ $dsize -lt 10240 ];then
	echo "获取更新包失败，请稍后再试"
	exit;
fi
unzip -o /tmp/panel.zip -d $setup_path/server/ > /dev/null
wget -O /www/server/panel/install/check.sh ${downloader_Url}/install/check.sh -T 10
chattr +i /www/server/panel/install/public.sh
chattr +i /www/server/panel/install/check.sh
rm -f /tmp/panel.zip
cd $setup_path/server/panel/
check_bt=`cat /etc/init.d/bt`
if [ "${check_bt}" = "" ];then
	rm -f /etc/init.d/bt
	wget -O /etc/init.d/bt $downloader_Url/install/src/bt6.init -T 20
	chmod +x /etc/init.d/bt
fi
rm -f /www/server/panel/*.pyc
rm -f /www/server/panel/class/*.pyc
#pip install flask_sqlalchemy
#pip install itsdangerous==0.24

pip_list=$($mypip list)
request_v=$(echo "$pip_list"|grep requests)
if [ "$request_v" = "" ];then
	$mypip install requests
fi
openssl_v=$(echo "$pip_list"|grep pyOpenSSL)
if [ "$openssl_v" = "" ];then
	$mypip install pyOpenSSL
fi

cffi_v=$(echo "$pip_list"|grep cffi|grep 1.12.)
if [ "$cffi_v" = "" ];then
	$mypip install cffi==1.12.3
fi

pymysql=$(echo "$pip_list"|grep pymysql)
if [ "$pymysql" = "" ];then
	$mypip install pymysql
fi

psutil=$(echo "$pip_list"|grep psutil|awk '{print $2}'|grep '5.7.')
if [ "$psutil" = "" ];then
	$mypip install -U psutil
fi

chattr -i /etc/init.d/bt
chmod +x /etc/init.d/bt
echo "====================================="

iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8888 -j ACCEPT
service iptables save

firewall-cmd --permanent --zone=public --add-port=8888/tcp > /dev/null 2>&1
firewall-cmd --reload

rm -f /dev/shm/bt_sql_tips.pl
kill $(ps aux|grep -E "task.pyc|main.py"|grep -v grep|awk '{print $2}')
/etc/init.d/bt start
echo 'True' > /www/server/panel/data/restart.pl
pkill -9 gunicorn &
echo "已成功升级到$version企业版";
echo "为了保障本机安全性，从现在起HostCli.Com版面板端口为:8888";
echo "若面板无法访问，请放行安全组，以及关闭机器的防火墙！";
echo "如果新端口还是无法访问，那可能你之前有变更端口，所以使用之前端口即可！";
echo -e "\033[31m该界面说明脚本已经执行完毕，欢迎使用！ \033[0m"  
rm -rf update6.sh
rm -rf update7.sh

