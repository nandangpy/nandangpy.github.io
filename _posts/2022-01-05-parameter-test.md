---
layout: post
title:  "Parameter Top"
date:   2022-01-05 22:02:38 +0830
categories: Cheatsheet Bug-Hunter
description: Some top parameters that are often used to search for vulnerabilities.
thumbnail: https://www.kali.org/images/kali-everywhere-vm.svg
---

Parameters with the type of vulnerability that often occurs.

# Table of Contents:
   - <a href="#SQLi">SQL Injection (SQLi)</a>
   - <a href="#remote-code-execution">Remote Code Execution (RCE)</a>
   - <a href="#local-file-inclusion">Local File Inclusion (LFI)</a>
   - <a href="#cross-site-scripting">Cross Site Scripting (XSS)</a>
   - <a href="#server-side-request-forgery">Server Side Request Forgery (SSRF)</a>


## [](#header-2)SQL Injection

```powershell
?id={payload}
?page={payload}
?dir={payload}
?search={payload}
?category={payload}
?calss={payload}
?file={payload}
?url={payload}
?news={payload}
?item={payload}
?menu={payload}
?lang={payload}
?name={payload}
?ref={payload}
?title={payload}
?view={payload}
?topic={payload}
?thread={payload}
?type={payload}
?date={payload}
?form={payload}
?join={payload}
?main={payload}
?nav={payload}
?region={payload}
```

## [](#header-2)Remote Code Execution

```powershell
?cmd={payload}
?exec={payload}
?command={payload}
?execute={payload}
?ping={payload}
?query={payload}
?jump={payload}
?code={payload}
?reg={payload}
?do={payload}
?func={payload}
?arg={payload}
?option={payload}
?load={payload}
?process={payload}
?step={payload}
?read={payload}
?function={payload}
?req={payload}
?feature={payload}
?exe={payload}
?module={payload}
?payload={payload}
?run={payload}
?print={payload}
```

## [](#header-2)Local File Inclusion

```powershell
?cat={payload}
?dir={payload}
?action={payload}
?board={payload}
?date={payload}
?detail={payload}
?file={payload}
?download={payload}
?path={payload}
?folder={payload}
?prefix={payload}
?include={payload}
?page={payload}
?inc={payload}
?locate={payload}
?show={payload}
?doc={payload}
?site={payload}
?type={payload}
?view={payload}
?content={payload}
?document={payload}
?layout={payload}
?mod={payload}
?conf={payload}
```

## [](#header-2)Cross Site Scripting

```powershell
?q={payload}
?s={payload}
?search={payload}
?id={payload}
?lang={payload}
?keyword={payload}
?query={payload}
?page={payload}
?keywords={payload}
?year={payload}
?view={payload}
?email={payload}
?type={payload}
?name={payload}
?p={payload}
?moth={payload}
?imagine={payload}
?list_type={payload}
?url={payload}
?term={payload}
?categoryid={payload}
?key={payload}
?l={payload}
?begindate={payload}
?enddate={payload}
```

## [](#header-2)Server Side Request Forgery

```powershell
?dest={target}
?redirect={target}
?uri={target}
?path={target}
?continue={target}
?url={target}
?window={target}
?next={target}
?data={target}
?reference={target}
?site={target}
?html={target}
?val={target}
?validate={target}
?domain={target}
?callback={target}
?return={target}
?page={target}
?feed={target}
?host={target}
?port={target}
?to={target}
?out={target}
?view={target}
?dir={target}
```