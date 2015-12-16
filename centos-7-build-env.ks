install
text
sshpw --username=root setup --plaintext
url --url=http://mirror.centos.org/centos/7/os/x86_64/
repo --name=updates --baseurl=http://mirror.centos.org/centos/7/updates/x86_64/
repo --name=extras --baseurl=http://mirror.centos.org/centos/7/extras/x86_64/
repo --name=plus --baseurl=http://mirror.centos.org/centos/7/centosplus/x86_64/

keyboard us
lang en_US.UTF8

timezone --utc Europe/Amsterdam

auth --enableshadow --passalgo=sha512 --enablefingerprint
rootpw --iscrypted $6$y4oi7guFydjyif96$9bm7hVh/D5DxqAF1vEAPCZKSUdF3GiLFP2lcui9uGZ6tCKYr30c20gIBtU8jO08IYmG9Frrz1d.XmMktmYoPp.

group --name=mock
user --name=homer --groups=wheel,mock

firewall --disabled

network --noipv6

ignoredisk --only-use=sda
clearpart --drives=sda --all --initlabel
zerombr

part /boot --size=1024 --ondrive=sda --asprimary --fstype=ext4
part pv.01 --size=1    --ondrive=sda --grow

volgroup vg_main pv.01
logvol swap  --vgname=vg_main --size=1024   --name=swap --label=SWAP --fstype=swap
logvol /     --vgname=vg_main --size=2048   --name=root --label=ROOT --fstype=ext4 --fsoptions="defaults,sync,relatime"
logvol /home --vgname=vg_main --size=1024   --name=home --label=HOME --fstype=ext4 --fsoptions="defaults,nodev"
logvol /usr  --vgname=vg_main --size=4096   --name=usr  --label=USR  --fstype=ext4 --fsoptions="defaults"
logvol /var  --vgname=vg_main --size=1      --name=var  --label=VAR  --fstype=ext4 --fsoptions="defaults,nodev,nosuid,relatime" --grow
bootloader --location=mbr

%packages
@Core
@Development
epel-release
git

%end

%post —log=/mnt/sysimage/var/log/ks-post.log

mkdir -p /mnt/sysimage/root/.ssh

systemctl enable sshd.service

/bin/sh -c "cd /mnt/sysimage/usr/src ; \
git clone -b homer5 https://github.com/sipcapture/homer.git; \
chown homer:homer -R /mnt/sysimage/usr/src/homer; \
cd /mnt/sysimage/usr/src/homer; \
git submodule init; \
git submodule update"
sudo -u homer -g homer /bin/sh -c "cd /mnt/sysimage/usr/src/homer; \
autoreconf -if; \
mkdir -p /mnt/sysimage/usr/src/homer/build; \
cd /mnt/sysimage/usr/src/homer/build; \
../configure --enable-rpm; \
make setup.sh"
export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/root/bin;
sudo ./setup.sh

%end

reboot
