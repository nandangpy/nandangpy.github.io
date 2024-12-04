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
