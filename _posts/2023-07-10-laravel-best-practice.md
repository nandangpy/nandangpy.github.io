---
layout: post
title: "Laravel Best Practice"
date: 2023-11-7 21:50:00 +0540
categories: Code Laravel Pentest
description: Laravel offers flexibility in structuring projects—both a strength and a challenge. Since the official documentation doesn’t provide specific guidelines, let’s explore various options using a specific example.
thumbnail: https://laravel.com/img/logomark.min.svg
---

One of the common questions about Laravel is, 'How should I structure my project?' More specifically, 'If logic doesn’t belong in the Controller, where should it go?' There’s no single answer. Laravel offers flexibility in structuring projects—both a strength and a challenge. Since the official documentation doesn’t provide specific guidelines, let’s explore various options using a specific example.

Note: Because there’s no one-size-fits-all method, this article will include many 'what ifs' and exceptions. It’s recommended to read it fully to understand the best practices that suit your needs.

Imagine you have a Controller method for user registration that handles multiple tasks:

```php
    public function store(Request $request)
    {
        // 1. Validation
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        // 2. Create user
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // 3. Upload the avatar file and update the user
        if ($request->hasFile('avatar')) {
            $avatar = $request->file('avatar')->store('avatars');
            $user->update(['avatar' => $avatar]);
        }

        // 4. Login
        Auth::login($user);

        // 5. Generate a personal voucher
        $voucher = Voucher::create([
            'code' => Str::random(8),
            'discount_percent' => 10,
            'user_id' => $user->id
        ]);

        // 6. Send that voucher with a welcome email
        $user->notify(new NewUserWelcomeNotification($voucher->code));

        // 7. Notify administrators about the new user
        foreach (config('app.admin_emails') as $adminEmail) {
            Notification::route('mail', $adminEmail)
                ->notify(new NewUserAdminNotification($user));
        }

        return redirect()->route('dashboard');
    }
```

Seven things, to be precise. You will all probably agree that it's too much for one controller method, we need to separate the logic and move the parts somewhere. But where exactly?

Services?
Jobs?
Events/listeners?
Action classes?
Something else?

That's probably the main message you should take home from this article. I will emphasize it for you, in bold and caps.

YOU ARE FREE TO STRUCTURE YOUR PROJECT HOWEVER YOU WANT.

There, I said it. In other words, if you see some structure recommended somewhere, it doesn't mean that you have to jump and apply it everywhere. The choice is always yours. You need to choose the structure that would be comfortable for yourself and your future team to maintain the code later.

With that, I probably could even end the article right now. But you probably want some "meat", right? Ok, fine, let's play around with the code above.

# General Refactoring Strategy

First, a "disclaimer", so it would be clear what we're doing here, and why. Our general goal is to make the Controller method shorter, so it wouldn't contain any logic.

Controller methods need to do three things:

Accept the parameters from routes or other inputs
Call some logic classes/methods, passing those parameters
Return the result: view, redirect, JSON return, etc.
So, controllers are calling the methods, not implementing the logic inside the controller itself.

Also, keep in mind, that my suggested changes are only ONE way of doing it, there are dozens of other ways which would also work. I will just provide you with my suggestions, from personal experience.

# Table of Contents:

- <a href="#validation:-Form-Request-classes">Validation: Form Request classes</a>
- <a href="#Create-User:-Service-Class">Create User: Service Class</a>

## [](#header-2)Validation: Form Request classes

It's a personal preference, but I like to keep the validation rules separately, and Laravel has a great solution for it: Form Requests

So, we generate:

```sh
    php artisan make:request StoreUserRequest
```

We move our validation rules from the controller to that class. Also, we need to add the Password class on top and change the authorize() method to return true:

```php
    use Illuminate\Validation\Rules\Password;

    class StoreUserRequest extends FormRequest
    {
        public function authorize()
        {
            return true;
        }

        public function rules()
        {
            return [
                'name' => ['required', 'string', 'max:255'],
                'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
                'password' => ['required', 'confirmed', Password::defaults()],
            ];
        }
    }
```

Finally, in our Controller method, we replace Request $request with StoreUserRequest $request and remove the validation logic from the Controller:

```php
    use App\Http\Requests\StoreUserRequest;

    class RegisteredUserController extends Controller
    {
        public function store(StoreUserRequest $request)
        {
            // No $request->validate needed here

            // Create user
            $user = User::create([...]) // ...
        }
    }
```

Ok, the first shortening of the controller is done. Let's move on.

## [](#header-2)Create User: Service Class

Next, we need to create a user and upload the avatar for them:

```php
    // Create user
    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
    ]);

    // Avatar upload and update user
    if ($request->hasFile('avatar')) {
        $avatar = $request->file('avatar')->store('avatars');
        $user->update(['avatar' => $avatar]);
    }
```

If we follow the recommendations, that logic should not be in a Controller. Controllers shouldn't know anything about the DB structure of the user, or where to store the avatars. It just needs to call some class method that would take care of everything.

A pretty common place to put such logic is to create a separate PHP Class around one Model's operations. It is called a Service class, but that's just a "fancy" official name for a PHP class that "provides a service" for the Controller.

That's why there's no command like php artisan make:service because it's just a PHP class, with whatever structure you want, so you can create it manually within your IDE, in whatever folder you want.

Typically, Services are created when there are more than one method around the same entity or model. So, by creating a UserService here, we assume there will be more methods here in the future, not just to create the user.

Also, Services typically have methods that return something (so, "provides the service"). In comparison, Actions or Jobs are called typically without expecting anything back.

In my case, I will create the app/Services/UserService.php class, with one method, for now.

```php
    namespace App\Services;

    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Hash;

    class UserService
    {
        public function createUser(Request $request): User
        {
            // Create user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);

            // Avatar upload and update user
            if ($request->hasFile('avatar')) {
                $avatar = $request->file('avatar')->store('avatars');
                $user->update(['avatar' => $avatar]);
            }

            return $user;
        }
    }
```

Then, in the Controller, we can just type-hint this Service class as a parameter of the method, and call the method inside.

```php
use App\Services\UserService;

    class RegisteredUserController extends Controller
    {
        public function store(StoreUserRequest $request, UserService $userService)
        {
            $user = $userService->createUser($request);

            // Login and other operations...
```

Yes, we don't need to call new UserService() anywhere. Laravel allows you to type-hint any class like this in the Controllers, you can read more about Method Injection here in the docs.

### [](#header-3) Service Class with Single Responsibility Principle

Now, the Controller is much shorter, but this simple copy-paste separation of code is a bit problematic.

The first problem is that the Service method should act like a "black box" that just accepts the parameters and doesn't know where those come from. So this method would be possible to be called from a Controller, from Artisan command, or a Job, in the future.

Another problem is that the Service method violates the Single Responsibility principle: it creates the user and uploads the file.

So, we need two more "layers": one for file upload, and one for the transformation from the $request to the parameters for the function. And, as always, there are various ways to implement it.

In my case, I will create a second service method that will upload the file.

app/Services/UserService.php:

```php
class UserService
{
    public function uploadAvatar(Request $request): ?string
    {
        return ($request->hasFile('avatar'))
            ? $request->file('avatar')->store('avatars')
            : NULL;
    }

    public function createUser(array $userData): User
    {
        return User::create([
            'name' => $userData['name'],
            'email' => $userData['email'],
            'password' => Hash::make($userData['password']),
            'avatar' => $userData['avatar']
        ]);
    }
}
```

RegisteredUserController.php:

```php
public function store(StoreUserRequest $request, UserService $userService)
{
    $avatar = $userService->uploadAvatar($request);
    $user = $userService->createUser($request->validated() + ['avatar' => $avatar]);

    // ...
```

Again, I will repeat: it's only one way of separating the things, you may do it differently.

But my logic is this:

1. The method createUser() now doesn't know anything about the Request, and we may call it from any Artisan command or elsewhere
2. The avatar upload is separated from the user creation operation.
   You may think that the Service methods are too small to separate them, but this is a very simplified example: in real-life projects, the file upload method may be much more complex, as well as the User creation logic.

In this case, we moved away a bit from the sacred rule "make a controller shorter" and added the second line of code, but for the right reasons, in my opinion.
