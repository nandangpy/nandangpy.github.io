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

First, a **"disclaimer"**, so it would be clear what we're doing here, and why. Our general goal is to make the Controller method shorter, so it wouldn't contain any logic.

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

#### app/Services/UserService.php:

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

#### RegisteredUserController.php:

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

## [](header-2) Maybe Action Instead of Service

In recent years, the concept of Action classes got popular in the Laravel community. The logic is this: you have a separate class for just ONE action only. In our case, the action classes may be:

1. CreateNewUser
2. UpdateUserPassword
3. UpdateUserProfile
4. etc.

So, as you can see, the same multiple operations around users, just not in one UserService class, but rather divided into Action classes. It may make sense, looking from the Single Responsibility Principle point of view, but I do like to group methods into classes, instead of having a lot of separate classes. Again, that's a personal preference.

Now, let's take a look at how our code would look in the case of the Action class.

Again, there's no php artisan make:action, you just create a PHP class. For example, I will create app/Actions/CreateNewUser.php:

```php
namespace App\Actions;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class CreateNewUser
{
    public function handle(Request $request)
    {
        $avatar = ($request->hasFile('avatar'))
            ? $request->file('avatar')->store('avatars')
            : NULL;

        return User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'avatar' => $avatar
        ]);
    }
}
```

You are free to choose the method name for the Action class, I like **handle()**.

RegisteredUserController:

```php
public function store(StoreUserRequest $request, CreateNewUser $createNewUser)
{
    $user = $createNewUser->handle($request);

    // ...
```

In other words, we offload ALL the logic to the action class that then takes care of everything around both file upload and user creation. To be honest, I'm not even sure if it's the best example to illustrate the Action classes, as I'm personally not a big fan of them and haven't used them much. As another source of examples, you may take a look at the code of Laravel Fortify.

## [](header-2) Voucher Creation: Same or Different Service

Next, in the Controller method, we find three operations:

```php
    Auth::login($user);

    $voucher = Voucher::create([
        'code' => Str::random(8),
        'discount_percent' => 10,
        'user_id' => $user->id
    ]);

    $user->notify(new NewUserWelcomeNotification($voucher->code));
```

The login operation will remain unchanged here in the controller, because it is already calling an external class Auth, similar to a Service, and we don't need to know what is happening under the hood there.

But with Voucher, in this case, the Controller contains the logic of how the voucher should be created and sent to the user with the welcome email.

First, we need to move the voucher creation to a separate class: I'm hesitating between creating a VoucherService and putting it as a method within the same UserService. That's almost a philosophical debate: what this method is related to the vouchers system, the users' system, or both?

Since one of the features of Services is to contain multiple methods, I decided to not create a **"lonely"** VoucherService with one method. We'll do it in the UserService:

```php
    use App\Models\Voucher;
    use Illuminate\Support\Str;

    class UserService
    {
        // public function uploadAvatar() ...
        // public function createUser() ...

        public function createVoucherForUser(int $userId): string
        {
            $voucher = Voucher::create([
                'code' => Str::random(8),
                'discount_percent' => 10,
                'user_id' => $userId
            ]);

            return $voucher->code;
        }
    }
```

Then, in the Controller, we call it like this:

```php
public function store(StoreUserRequest $request, UserService $userService)
{
    // ...

    Auth::login($user);

    $voucherCode = $userService->createVoucherForUser($user->id);
    $user->notify(new NewUserWelcomeNotification($voucherCode));
```

Something else to consider here: maybe we should move both of those lines into a separate method of UserService that would be responsible for the welcome email, which would in turn call the voucher method?

Something like this:

```php
class UserService
{
    public function sendWelcomeEmail(User $user)
    {
        $voucherCode = $this->createVoucherForUser($user->id);
        $user->notify(new NewUserWelcomeNotification($voucherCode));
    }
```

Then, Controller will have only one line of code for this:

```php
$userService->sendWelcomeEmail($user);
```

## [](header-2) Notifying Admins: Queueable Jobs

Finally, we see this piece of code in the Controller:

```php
    foreach (config('app.admin_emails') as $adminEmail) {
        Notification::route('mail', $adminEmail)
            ->notify(new NewUserAdminNotification($user));
    }
```

It is sending potentially multiple emails, which may take time, so we need to put it into the queue, to run in the background. That's where we need Jobs.

Laravel Notification classes may be queueable, but for this example, let's imagine there may be something more complex than just sending a notification email. So let's create a Job for it.

In this case, Laravel provides the Artisan command for us:

```sh
    php artisan make:job NewUserNotifyAdminsJob
```

```php
app/Jobs/NewUserNotifyAdminsJob.php:

class NewUserNotifyAdminsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    private User $user;

    public function __construct(User $user)
    {
        $this->user = $user;
    }

    public function handle()
    {
        foreach (config('app.admin_emails') as $adminEmail) {
            Notification::route('mail', $adminEmail)
                ->notify(new NewUserAdminNotification($this->user));
        }
    }
}
```

Then, in the Controller, we need to call that Job with the parameter:

```php
use App\Jobs\NewUserNotifyAdminsJob;

class RegisteredUserController extends Controller
{
    public function store(StoreUserRequest $request, UserService $userService)
    {
        // ...

        NewUserNotifyAdminsJob::dispatch($user);
```

So, now, we've moved all the logic from the Controller to elsewhere, and let's recap what we have:

```php
    public function store(StoreUserRequest $request, UserService $userService)
    {
        $avatar = $userService->uploadAvatar($request);
        $user = $userService->createUser($request->validated() + ['avatar' => $avatar]);
        Auth::login($user);
        $userService->sendWelcomeEmail($user);
        NewUserNotifyAdminsJob::dispatch($user);

        return redirect(RouteServiceProvider::HOME);
    }
```

Shorter, separated into various files, and still readable, right? Again, will repeat once more, that it's only one way to accomplish this mission, you can decide to structure it in another way.

But that's not all. Let's also discuss the **"passive"** way.

## [](header-2) Events/Listeners

Philosophically speaking, we can divide all the operations in this Controller method, into two types: active and passive.

1. We're actively creating the user and logging them in
2. And then something with that user may (or may not) happen in the background. So we're passively waiting for those other operations: sending a welcome email and notifying the admins.
   So, as one way of separating the code, it should not be called in the Controller at all, but be fired automatically when some event happens.

You can use a combination of Events and Listeners for it:

```php
php artisan make:event NewUserRegistered
php artisan make:listener NewUserWelcomeEmailListener --event=NewUserRegistered
php artisan make:listener NewUserNotifyAdminsListener --event=NewUserRegistered
```

The event class should accept the User model, which is then passed to ANY listener of that event.

```php

app/Events/NewUserRegistered.php

use App\Models\User;

class NewUserRegistered
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public User $user;

    public function __construct(User $user)
    {
        $this->user = $user;
    }
}
```

Then, the Event is dispatched from the Controller, like this:

```php
public function store(StoreUserRequest $request, UserService $userService)
{
    $avatar = $userService->uploadAvatar($request);
    $user = $userService->createUser($request->validated() + ['avatar' => $avatar]);
    Auth::login($user);

    NewUserRegistered::dispatch($user);

    return redirect(RouteServiceProvider::HOME);
}
```

And, in the Listener classes, we repeat the same logic:

```php
use App\Events\NewUserRegistered;
use App\Services\UserService;

class NewUserWelcomeEmailListener
{
    public function handle(NewUserRegistered $event, UserService $userService)
    {
        $userService->sendWelcomeEmail($event->user);
    }
}
```

And, another one:

```php
use App\Events\NewUserRegistered;
use App\Notifications\NewUserAdminNotification;
use Illuminate\Support\Facades\Notification;

class NewUserNotifyAdminsListener
{
    public function handle(NewUserRegistered $event)
    {
        foreach (config('app.admin_emails') as $adminEmail) {
            Notification::route('mail', $adminEmail)
                ->notify(new NewUserAdminNotification($event->user));
        }
    }
}
```

What is the advantage of this approach, with events and listeners? They are used like **"hooks"** in the code, and anyone else in the future would be able to use that hook. In other words, you're saying to the future developers: "Hey, the user is registered, the event happened, and now if you want to add some other operation happening here, just create your listener for it".

## [](header-2) Observers: "Silent" Events/Listeners

A very similar "passive" approach could be also implemented with a Model Observer, in this case.

```sh
php artisan make:observer UserObserver --model=User
```

app/Observers/UserObserver.php:

```php
use App\Models\User;
use App\Notifications\NewUserAdminNotification;
use App\Services\UserService;
use Illuminate\Support\Facades\Notification;

class UserObserver
{
    public function created(User $user, UserService $userService)
    {
        $userService->sendWelcomeEmail($event->user);

        foreach (config('app.admin_emails') as $adminEmail) {
            Notification::route('mail', $adminEmail)
                ->notify(new NewUserAdminNotification($event->user));
        }
    }
}
```

In that case, you don't need to dispatch any events in the Controller, the Observer would be fired immediately after the Eloquent model is created.

Convenient, right?

But, in my personal opinion, this is a bit dangerous pattern. Not only the implementation logic is hidden from the Controller, but the mere existence of those operations is not clear. Imagine a new developer joining the team in a year, would they check all the possible observer methods when maintaining the User registration? Of course, it's possible to figure it out, but still, it's not obvious. And our goal is to make the code more maintainable, so the fewer **"surprises"**, the better. So, I'm not a big fan of Observers.

## Conclusion

Looking at this article now, I realize I've only scratched the surface of possible separations of the code, on a very simple example.
In fact, in this simple example, it may seem that we made the application more complex, creating many more PHP classes instead of just one.

But, in this example, those separate code parts are short. In real life, they may be much more complex, and by separating them, we made them more manageable, so every part may be handled by a separate developer, for example.

In general, I will repeat for the last time: you are in charge of your application, and only you decide where you place the code. The goal is so that you or your teammates will understand it in the future, and will not have trouble adding new features and maintaining/fixing the existing ones.
