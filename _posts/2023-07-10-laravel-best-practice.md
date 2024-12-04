---
layout: post
title: "Laravel Best Practice"
date: 2023-11-7 21:50:00 +0540
categories: Code Laravel Pentest
description: Laravel offers flexibility in structuring projects—both a strength and a challenge. Since the official documentation doesn’t provide specific guidelines, let’s explore various options using a specific example.
thumbnail: https://laravel.com/img/logomark.min.svg
---

One of the common questions about Laravel is, 'How should I structure my project?' More specifically, 'If logic doesn’t belong in the Controller, where should it go?'

There’s no single answer. Laravel offers flexibility in structuring projects—both a strength and a challenge. Since the official documentation doesn’t provide specific guidelines, let’s explore various options using a specific example.

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
