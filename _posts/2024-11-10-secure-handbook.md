---
layout: post
title: "Secure Handbook"
date: 2024-12-20 18:50:00 +0540
categories: Code Pentest Handbook
description: A Secure Handbook is typically a comprehensive guide designed to provide information and best practices for ensuring security in specific contexts, such as cybersecurity, physical security, or organizational safety.
thumbnail: https://www.hackthebox.com/images/landingv3/crisis-control-blog.svg
---

Welcome to the Secure Coding Handbook! Here, you will find everything that I have found on secure coding: best practices, analyzing, and, of course, patching code-related vulnerabilities. All of the enumerated attacks and defensive techniques are strictly related to web applications. for now :)

# Table of Contents:

- <a href="#sql-injections-(SQLi)">SQL Injections (SQLi)</a>
- <a href="#xml-external-entity-injections-(XXE)">XML External Entity Injections (XXE)</a>
- <a href="#clickjacking">Clickjacking</a>
- <a href="#vulerable-dependency-management">Vulerable Dependency Management</a>

## [](#header-2)SQL Injections (SQLi)

Step carefully to install the Laravel application using Composer.

```sh
    composer create-project --prefer-dist laravel/laravel rest-api-crud
```

## [](#header-2)XML External Entity Injections (XXE)

Laravel 11 default DB_CONNECTION=sqlite.you have to change this DB_CONNECTION=mysql this is in env file.

```sh
    LOG_CHANNEL=stack
    LOG_DEPRECATIONS_CHANNEL=null
    LOG_LEVEL=debug

    DB_CONNECTION=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=your_database
    DB_USERNAME=root
    DB_PASSWORD=
```

That's probably the main message you should take home from this article. I will emphasize it for you, in bold and caps.

YOU ARE FREE TO STRUCTURE YOUR PROJECT HOWEVER YOU WANT.

## [](#header-2)Clickjacking

Step carefully to install the Laravel application using Composer.

```sh
    php artisan make:model Product -a
```

## [](#header-2)Vulerable Dependency Management

Install the Laravel application using Composer.

```sh
    php artisan make:controller Product -r
```
