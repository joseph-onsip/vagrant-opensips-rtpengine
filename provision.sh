# http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -o errexit

# install OpenSIPS 1.10 as shown on http://apt.opensips.org/
sudo echo > /etc/apt/sources.list.d/opensips.list "deb http://apt.opensips.org/debian/stable-1.10/wheezy opensips-1.10-wheezy main"
# no https :(
sudo wget -qO - http://apt.opensips.org/key.asc | apt-key add -
sudo apt-get update
sudo apt-get install -y opensips

# install rtpengine from the rfuchs/socket-rework branch
sudo apt-get install -y git
rm -rf rtpengine
git clone https://github.com/sipwise/rtpengine.git
cd rtpengine
git checkout 16e5df722fe281170ded0a419c686c069821e859
./debian/flavors/no_ngcp
# install build dependencies
# https://github.com/sipwise/rtpengine/tree/16e5df722fe281170ded0a419c686c069821e859#manual-compilation
sudo apt-get install -y build-essential pkg-config libglib2.0-dev zlib1g-dev libssl-dev libpcre3-dev libcurl4-openssl-dev libxmlrpc-core-c3-dev
# install unlisted build dependencies
sudo apt-get install -y debhelper iptables-dev markdown
dpkg-buildpackage
sudo dpkg --purge ngcp-rtpengine{,-daemon,-iptables,-kernel-dkms}
sudo apt-get install -y linux-headers-3.2.0-4-amd64 # needed for ngcp-rtpengine-kernel-dkms
RTPENGINE_VERSION="4.0.0.0+0~mr4.0.0.0"
sudo dpkg -i /home/vagrant/ngcp-rtpengine-kernel-dkms_${RTPENGINE_VERSION}_all.deb
sudo dpkg -i /home/vagrant/ngcp-rtpengine-iptables_${RTPENGINE_VERSION}_amd64.deb
sudo dpkg -i /home/vagrant/ngcp-rtpengine-daemon_${RTPENGINE_VERSION}_amd64.deb
sudo dpkg -i /home/vagrant/ngcp-rtpengine_${RTPENGINE_VERSION}_all.deb
