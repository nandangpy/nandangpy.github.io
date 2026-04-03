---
layout: post
title: "Secure Handbook"
date: 2026-04-03 09:12:00 +0700
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
- <a href="#cross-site-request-forgery-(CSRF)">Cross-Site Request Forgery (CSRF)</a>

## [](#header-2)SQL Injections (SQLi)

### 1. Introduction

SQL Injections happen when developers create **dynamic database queries** that include **user-supplied input**. For this reason, developers have to:

1. Stop writing **dynamic queries** for their applications.
2. **Filter and escape the user-supplied input**.

The techniques presented here technically apply to most other programming languages and/ or types of databases.

### 2. Typical Vulnerable Code

```php
<?php
$email = $POST['email'];
$password = $POST['password'];

$stmt = mysql_query("SELECT * FROM users WHERE (email='$email' 
                    AND password='$password') LIMIT 0,1"
                    );

$count = mysql_fetch_array($stmt);
if($count > 0) {
    session_start();
    // Auth successful
}
else
{
    // Auth failure
}
?>
```

```python
def authenticate(request):
    email = request.POST['email']
    password = request.POST['password']
    sql = "select * from users where (email ='" 
        + email 
        + "' and password ='" + password + "')"
    
    cursor = connection.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    if row:
        loggedIn = "Auth successful"
    else:
        loggedIn = "Auth failure"
    return HttpResponse("Logged In Status: " + loggedIn)
```

```jsx
function authenticate(req, res, next) {
    var email = req.query.email,
        password = req.query.password,
        sqlRequest = new sql.Request(),
        sqlQuery = "select * from users where (email='" 
        + "' and password = '" + password + "')";
    
    sqlRequest.query(sqlQuery)
        .then(function (recordset) {
            if (recordset.length == 1) {
                loggedIn = true;
                // Auth successful
            } else {
                // Auth failure
            }
        })
        .catch(next);
}
```

**`sqlQuery`** executes an **SQL Query** without any input validation whatsoever. (i.e. no checking of legal characters, minimum/maximum string lengths, or removal of "malicious" characters).

The attacker can inject raw **SQL syntax** within both the username and the password input fields to alter the meaning of the underlying **SQL query** responsible for authentication, resulting in a bypass of the application's authentication mechanism. An example of such bypass could be the query: `' or 1=1)#`

### 3. Mitigation

### 3.1. Prepared Statements

Prepared statements ensure that an attacker is not able to change the **intent** of a query, even if SQL commands are inserted by an attacker. If an attacker were to enter the email `' or 1=1)#`, the parameterized query would look for an email that literally matched the entire string `' or 1=1)#`.

```php
<?php
$email = $_POST['email'];
$password = $_POST['password'];

$stmt = $dbConnection->prepare('SELECT * FROM users WHERE (email = ? AND password = ?) LIMIT 0,1');
$stmt->bind_param('ss', $email, $password);
$stmt->execute();

$result = $stmt->get_result();
if ($result->num_rows > 0) {
    session_start();
    // Auth successful
} else {
    // Auth failure
}
?>
```

```python
def authenticate(request):
    email = request.POST['email']
    password = request.POST['password']
    
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM users WHERE (email = %s AND password = %s)",
            [email, password]
        )
        row = cursor.fetchone()
    
    if row:
        loggedIn = "Auth successful"
    else:
        loggedIn = "Auth failure"
    return HttpResponse("Logged In Status: " + loggedIn)
```

```jsx
function authenticate(req, res, next) {
    var email = req.query.email,
        password = req.query.password;
    
    var preparedStatement = new sql.PreparedStatement();
    preparedStatement.input('email', sql.NVarChar);
    preparedStatement.input('password', sql.NVarChar);
    
    preparedStatement.prepare(
        "SELECT * FROM users WHERE (email = @email AND password = @password)"
    ).then(function () {
        return preparedStatement.execute({ email: email, password: password });
    }).then(function (recordset) {
        if (recordset.length === 1) {
            loggedIn = true;
            // Auth successful
        } else {
            // Auth failure
        }
        preparedStatement.unprepare();
    }).catch(next);
}
```

### 3.2. Stored Procedures

Stored procedures are similar to prepared statements, only the SQL code for the stored procedure is **defined and stored in the database itself**, and then called from the application. Both of these techniques have the same effectiveness in preventing SQL injection.

```sql
-- Create the stored procedure in the database
CREATE PROCEDURE AuthenticateUser
    @email NVARCHAR(255),
    @password NVARCHAR(255)
AS
BEGIN
    SELECT * FROM users 
    WHERE email = @email AND password = @password;
END
```

```php
<?php
$email = $_POST['email'];
$password = $_POST['password'];

$stmt = $dbConnection->prepare('CALL AuthenticateUser(?, ?)');
$stmt->bind_param('ss', $email, $password);
$stmt->execute();

$result = $stmt->get_result();
if ($result->num_rows > 0) {
    session_start();
    // Auth successful
} else {
    // Auth failure
}
?>
```

```python
def authenticate(request):
    email = request.POST['email']
    password = request.POST['password']
    
    with connection.cursor() as cursor:
        cursor.callproc('AuthenticateUser', [email, password])
        row = cursor.fetchone()
    
    if row:
        loggedIn = "Auth successful"
    else:
        loggedIn = "Auth failure"
    return HttpResponse("Logged In Status: " + loggedIn)
```

> **Note:** Stored procedures can still introduce SQL injection if they use **dynamic SQL generation** internally. When building stored procedures, use parameterized queries inside them as well.

### 3.3. Input Validation

Input validation can be used to detect unauthorized input **before** it is passed to the SQL query. For example, you can validate that the input matches expected patterns.

```php
<?php
$email = $_POST['email'];
$password = $_POST['password'];

// Whitelist validation: only allow valid email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die("Invalid email format");
}

// Enforce password policy
if (strlen($password) < 8 || strlen($password) > 64) {
    die("Password must be between 8 and 64 characters");
}

// Still use prepared statements as primary defense!
$stmt = $dbConnection->prepare('SELECT * FROM users WHERE (email = ? AND password = ?) LIMIT 0,1');
$stmt->bind_param('ss', $email, $password);
$stmt->execute();
?>
```

```python
import re

def authenticate(request):
    email = request.POST['email']
    password = request.POST['password']
    
    # Whitelist validation
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_pattern, email):
        return HttpResponse("Invalid email format", status=400)
    
    if len(password) < 8 or len(password) > 64:
        return HttpResponse("Invalid password length", status=400)
    
    # Still use parameterized queries as primary defense!
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM users WHERE (email = %s AND password = %s)",
            [email, password]
        )
        row = cursor.fetchone()
    
    if row:
        loggedIn = "Auth successful"
    else:
        loggedIn = "Auth failure"
    return HttpResponse("Logged In Status: " + loggedIn)
```

> **Important:** Input validation should be used as a **secondary defense**. It should NOT be used as the primary method to prevent SQL injection. Always use **prepared statements** as your primary defense.

### 3.4. Escaping User-Supplied Input

This technique should only be used as a **last resort**, when none of the above are feasible. Input escaping works by escaping all user-supplied input so that the database treats it as data rather than as SQL code.

```php
<?php
$email = $_POST['email'];
$password = $_POST['password'];

// Escape special characters
$email = mysqli_real_escape_string($dbConnection, $email);
$password = mysqli_real_escape_string($dbConnection, $password);

$stmt = mysqli_query($dbConnection, 
    "SELECT * FROM users WHERE (email='$email' AND password='$password') LIMIT 0,1"
);
?>
```

```python
from django.utils.html import escape
import MySQLdb

def authenticate(request):
    email = request.POST['email']
    password = request.POST['password']
    
    # Escape user input
    email = MySQLdb.escape_string(email).decode('utf-8')
    password = MySQLdb.escape_string(password).decode('utf-8')
    
    sql = "SELECT * FROM users WHERE (email ='%s' AND password ='%s')" % (email, password)
    
    cursor = connection.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    
    if row:
        loggedIn = "Auth successful"
    else:
        loggedIn = "Auth failure"
    return HttpResponse("Logged In Status: " + loggedIn)
```

> **Warning:** Escaping is **not foolproof** and is database-specific. It can be bypassed in some edge cases (e.g., character set mismatches). **Always prefer prepared statements** over escaping.

### 4. Takeaways

| Defense Technique | Effectiveness | Recommended |
|---|---|---|
| **Prepared Statements** | ✅ Highly effective | ✅ Primary defense |
| **Stored Procedures** | ✅ Highly effective | ✅ Alternative to prepared statements |
| **Input Validation** | ⚠️ Partial defense | ✅ Use as secondary layer |
| **Escaping Input** | ⚠️ Database-specific | ⚠️ Last resort only |

**Key points to remember:**

1. **Use Prepared Statements** — This is the most effective and recommended defense against SQL injection.
2. **Layer your defenses** — Combine prepared statements with input validation for defense in depth.
3. **Never trust user input** — Always treat user-supplied data as untrusted, regardless of the source.
4. **Avoid dynamic queries** — Never concatenate user input directly into SQL strings.
5. **Keep dependencies updated** — Ensure your database drivers and ORM libraries are up to date with the latest security patches.

## [](#header-2)XML External Entity Injections (XXE)

### 1. Introduction

This attack occurs when untrusted XML input containing a **reference to an external entity is processed by a weakly configured XML parser**.

It may lead to the disclosure of confidential data, denial of service, [Server Side Request Forgery](https://owasp.org/www-community/attacks/Server_Side_Request_Forgery) (SSRF), port scanning from the perspective of the machine where the parser is located, and other system impacts.

### 2. Typical Vulnerable Code

```jsx
var parserOptions = {
    noblanks: true,
    noent: true,
    nocdata: true
};

try {
    var doc = libxml.parseXmlString(data, parserOptions);
} catch (e) {
    return Promise.reject('XML parse error');
}
```

```python
from django.http import HttpResponse
from lxml import etree

def authenticate(content):
    parser = etree.XMLParser(resolve_entities=True)
    try:
        document = etree.fromstring(content, parser)
    except etree.XMLSyntaxError:
        return None
```

```php
class Loader
{
    /**
    * @param string $path
    * @return DOMDocument
    */
    public function load($path)
    {
         $dom = new DOMDocument();
         $dom->loadXML(file_get_contents($path));
         return $dom;
    }
}
```

An XXE attack works by taking advantage of a feature in XML, namely **XML** e**X**ternal **Entities** (XXE) that allows external XML resources to be loaded within an XML document.

By submitting an XML file that defines an external entity with a `file://` URI, an attacker can effectively trick the **application's SAX (Simple API parser for XML) parser** into reading the contents of the arbitrary file(s) that reside on the server-side filesystem.

Finally, we use the XML declaration `ENTITY` to load additional data from an external resource. The syntax for the `ENTITY` declaration is `ENTITY name SYSTEM URI` where `URI` is the full path to a remote URL or local file. In our example, we define the `ENTITY` tag to load the contents of `"file:///etc/passwd"`

This is an example of how the XML "payload" file can look like.

```xml
<!DOCTYPE foo [<!ELEMENT foo ANY >
<!ENTITY bar SYSTEM "file:///etc/passwd" >]>
<?xml version="1.0" encoding="UTF-8"?>

<trades>
    <metadata>
        <name>Apple Inc</name>
        <stock>AAPL</stock>
        <trader>
            <foo>&bar;</foo>
            <name>B.Bobi</name>
        </trader>
        <units>1500</units>
        <price>130</price>
        <name>Google</name>
        <stock>GOOGL</stock>
        <trader>
            <name>B.Bobi</name>
        </trader>
        <units>1500</units>
        <price>130</price>
    </metadata>
</trades>
```

When this XML document is processed by a vulnerable parser, such as the one presented above, any instances of `&bar;` will get replaced by the contents of `/etc/passwd` file.

Simply put **the XML parser was tricked into accessing a resource** that the application developers **did not intend to be accessible**, in this case, **a file on the local file system of the remote server**. Because of this vulnerability, **any file on the remote server** (or more precisely, any file that the web server has read access to) could be obtained.

Unfortunately, the **SAX parser has not been configured to deny the loading** of external entities (`DOCTYPE` declarations), which when specified within our modified `payload.xml` file can be **abused by an attacker to read arbitrary system files** on the remote server.

> ℹ️ Because user-supplied XML input comes from an "untrusted source" (namely, the client) **it is very difficult to properly validate the XML document** to **prevent this type of attack**.

### 3. Mitigation

### 3.1. Disabling Inline DTD

Since **we know that the parser should technically not allow loading external entities** (any kind of `DOCTYPE` declaration), we can **have the XML parser configured to only use a locally defined Document Type Definition (DTD)** and **disallow any inline DTD** that is specified within a user-supplied XML document(s).

Due to the fact that there are **numerous XML parsing engines available**, each has its own mechanism for disabling inline DTD to prevent XXE. You may need to search your XML parser's documentation for how to "disable inline DTD" specifically.

Here are some examples of how you may disable the inline **DTD parsing**.

```jsx
var parserOptions = {
    noblanks: true,
    noent: false, // doesn't allow DOCTYPE declarations
    nocdata: true
};

try {
    var doc = libxml.parseXmlString(data, parserOptions);
} catch (e) {
    return Promise.reject('XML parse error');
}
```

```python
from django.http import HttpResponse
from lxml import etree

def authenticate(content):
    parser = etree.XMLParser(resolve_entities=False)
    # False -> doesn't allow DOCTYPE declarations
    try:
        document = etree.fromstring(content, parser)
    except etree.XMLSyntaxError:
        return None
```

```php
class Loader
{
    /**
    * @param string $path
    * @return DOMDocument
    */
    public function load($path)
    {
        $old = libxml_disable_entity_loader(true);
        // disable entity loader -> does not allow DOCTYPE declarations
        $dom = new DOMDocument();
        $dom->loadXML(file_get_contents($path));
        libxml_disable_entity_loader($old);
        return $dom;
    }
}
```

### 3.2. Follow the Principle of Least Privilege

The threat of **XXE** attacks entirely illustrates the importance of **following the principle of least privilege**, which states that **software components and processes should be granted the minimal set of permissions** required to perform their tasks.

Since there are rarely good reasons for an XML parser to make outbound network requests, consider locking down outbound network requests for your web server as a whole. If you do need outbound network access — for example, if your server code calls third-party APIs — you should **whitelist the domains of those APIs in your firewall rules**.

### 4. Takeaways

It is common knowledge that DTDs are legacy technology, thus allowing for **inline DTDs** is **ALWAYS A BAD IDEA!** Modern XML parsers are hardened by default, and because of this, using such frameworks or parsers means that you might already be protected against attacks.

> ℹ️ You can find more details about this topic here:
> - [XML External Entity Prevention Cheatsheet [OWASP]](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)
> - [What is XXE?](https://portswigger.net/web-security/xxe)

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

## [](#header-2)Cross-Site Request Forgery (CSRF)

### 1. Introduction

Cross-site request forgery (also known as **CSRF**) is a web security vulnerability that allows an attacker to induce users to perform actions that they do not intend to perform. It enables an attacker to partly circumvent the same-origin policy, which is designed to prevent different websites from interfering with each other. In the usual attack scenario, a **`GET`** request that changes the state of the webserver is exploited.

You can read more about this type of vulnerability, from the attacker's perspective, [here](https://portswigger.net/web-security/csrf).

### 2. Defensive Methods

### 2.1. Following the REST Architecture

**REST** or **Representational State Transfer** states that **`GET`** requests should strictly be used when fetching data or other resources and that for any other actions that would essentially change the server state, you **should** use one of the appropriate protocols, such as **`PUT`**, **`POST`** and **`DELETE`**.

Since not all actions have an obvious corresponding HTTP method, such as fetching = **`GET`**, **updating** = **`POST`**, **creating** = **`PUT`**, **delete** = **`DELETE`**, there are other mitigations that can secure our application as much as possible, though for now, **it is important to remember** that **`GET`** should **strictly be used for fetching data**.

### 2.2. Working with CSRF Tokens

This is one of the most recommended methods to properly mitigate CSRF.

> **ℹ️ CSRF tokens prevent CSRF because**, without them, **an attacker cannot create any valid requests** to the **backend server**.

Listed below are a few techniques and use cases for those tokens.

#### 2.2.1. Synchronizer Token

Ideally, **a developer would store CSRF tokens** on the **server-side**. Depending on the implementation, those can either be **per-session** or **per-request** tokens.

**Per-request** tokens are typically more secure than the **per-session** one, as the time span that they are valid is rather limited; this comes with usability limitations, however, using the "back" browser button for example would not work since the session would have expired already.

Upon a request issued by the client, the server-side component should have checked the existence and validity of the token in the request compared to the token in the session. Should there either be no token at all or the request token mismatches the value in the session, the request should be aborted and even marked as a potential CSRF attack.

Upon designing the CSRF tokens, a developer should know that tokens have to:

- Be **unique** per user session.
- Be **secret**.
- Be **unpredictable** (typically done through a secure generating method).

> ⚠️ **CSRF tokens** should **NOT** be transmitted through cookies.

**CSRF** tokens can be added through hidden fields, headers, and can be used with forms, and AJAX calls. It is important to check for any possible leakages, such as the server logs or even in the URL. Here you have an example of applying the token to a form:

```html
<form action="/pay" method="post">
    <input type="hidden" name="CSRFtoken" value="ZjJkMzA3YWEyMzg2YTBjNzQzM2NlODUwMTllZTU2MTk=">
    [...]
</form>
```

#### 2.2.2. Double Submit Cookies

Maintaining a state for the CSRF tokens is sometimes problematic, and thus an alternative for the synchronizer token is the **double submit cookie** technique.

When a user visits (preferably before authentication) the website should securely generate a value and set that as a cookie on the user's browser. The application thus requires that any action request includes this value as a hidden **form** value. Thus, should both the hidden form value and this cookie match on the server-side, the server accepts the request as legitimate, otherwise, it rejects it.

> ℹ️ **Note:** This method is somewhat of a workaround and should preferably be used together with some way of encrypting those cookies, or working with [**HMAC**](https://www.nedmcclain.com/better-csrf-protection/).

### 2.3. Use of Custom Request Headers

Adding CSRF tokens, using the double submit cookie or other defense that involves changing the UI can frequently be complex or otherwise problematic. An alternative defense method that is particularly well suited for AJAX or API endpoints is the use of a **custom request header**. This relies on the [same-origin policy (SOP)](https://en.wikipedia.org/wiki/Same-origin_policy), which states that JavaScript can be used for adding a custom header, limited strictly within its origin. By default, however, browsers do not allow JavaScript to make any cross-origin requests with custom headers.

Because the **`POST`**, **`PUT`**, **`PATCH`**, and **`DELETE`** are state-changing methods, they should use a CSRF token attached to the request. The following guidance will demonstrate how to create overrides in JavaScript libraries to have CSRF tokens included automatically with every AJAX request for the state-changing methods mentioned above.

```jsx
<script type="text/javascript">
    var csrftoken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

    axios.defaults.headers.post['anti-csrf-token'] = csrftoken;
    axios.defaults.headers.put['anti-csrf-token'] = csrftoken;
    axios.defaults.headers.delete['anti-csrf-token'] = csrftoken;
    axios.defaults.headers.patch['anti-csrf-token'] = csrftoken;
</script>
```

### 2.4. Using a CSRF Protection Middleware

In the end, using a "battle-tested" method such as a module is one of the safest defensives. As a proof of concept, I will showcase how using [csurf](https://www.npmjs.com/package/csurf) will help you generate and manage CSRF tokens.

```jsx
// server.js
var cookieParser = require('cookie-parser')
var csrf = require('csurf')
var bodyParser = require('body-parser')
var express = require('express')
 
// setup route middlewares
var csrfProtection = csrf({ cookie: true })
var parseForm = bodyParser.urlencoded({ extended: false })
 
// create express app
var app = express()
 
// parse cookies
// we need this because "cookie" is true in csrfProtection
app.use(cookieParser())
 
app.get('/form', csrfProtection, function (req, res) {
  // pass the csrfToken to the view
  res.render('send', { csrfToken: req.csrfToken() })
})
 
app.post('/process', parseForm, csrfProtection, function (req, res) {
  res.send('data is being processed')
})
```

And now, set the csrfToken as the value of the hidden input field called `_csrf`.

```html
<form action="/process" method="POST">
  <input type="hidden" name="_csrf" value="{{csrfToken}}">
  
  Favorite color: <input type="text" name="favoriteColor">
  <button type="submit">Submit</button>
</form>
```

### 3. Takeaways

Defending against CSRF can be seen as a multi-level challenge, in the sense that the developer has to strictly follow the **REST architecture**, as well as coming up with mandatory CSRF tokens; as going the paved way is not always a wrong thing to do (especially in application security), a developer can also make use of **CSRF protection middleware**.

> ℹ️ You can find more details about this topic here:
> - [Should I use CSRF protection on Rest API endpoints?](https://security.stackexchange.com/questions/166724/should-i-use-csrf-protection-on-rest-api-endpoints/166798#166798)
> - [CSRF Protection Cheatsheet [OWASP]](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#javascript-guidance-for-auto-inclusion-of-csrf-tokens-as-an-ajax-request-header)
> - [Preventing CSRF](https://auth0.com/blog/cross-site-request-forgery-csrf/)
