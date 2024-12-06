---
layout: post
title: "Laravel REST API Best Practices"
date: 2024-15-7 18:50:00 +0540
categories: API Code Laravel
description: Building a RESTful API CRUD application in Laravel following best practices involves several key steps.
thumbnail: https://laravel.com/img/logomark.min.svg
---

Building a RESTful API CRUD application in Laravel following best practices involves several key steps. This includes setting up the Laravel application, defining routes, implementing validation, working with models, utilizing resources, creating controllers, applying the Repository design pattern, and integrating models with the database. Here is a step-by-step guide to achieving this:

# Table of Contents:

- <a href="#setting-up-aravel">Setting up Laravel</a>
- <a href="#mysql-database-configuration">Mysql Database Configuration</a>
- <a href="#create-the-product-model-with-migration">Create the Product Model with migration</a>
- <a href="#migration">Migration</a>
- <a href="#create-product-interface">Create Product Interface</a>
- <a href="#create-product-respository-class">Create Product Respository Class</a>
- <a href="#bind-the-interface-and-the-implementation">Bind The Interface and The Implementation</a>
- <a href="#request-validation">Request Validation</a>
- <a href="#common-apiResponseClass-create">Common ApiResponseClass Create</a>
- <a href="#create-product-resource">Create Product Resource</a>
- <a href="#productcontroller-class">Productcontroller Class</a>
- <a href="#route-api">Route Api</a>

## [](#header-2)Setting up Laravel

Step carefully to install the Laravel application using Composer.
```sh
    composer create-project --prefer-dist laravel/laravel rest-api-crud
```

## [](#header-2)Mysql Database Configuration

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

## [](#header-2)Create the Product Model with migration

Here are the artisan commands that must be executed.

```sh
    php artisan make:model Product -a
```

## [](#header-2)Migration

In database/migrations/YYYY_MM_DD_HHMMSS_create_products_table.php, update the up function to match the following.
```php
     public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('details');
            $table->timestamps();
        });
    }
```

## [](#header-2)Create Product Interface

Create a repository interface for the Product model. This separation allows for cleaner and more maintainable code.
```sh
    php artisan make:interface /Interfaces/ProductRepositoryInterface
```

in the Interfaces, create a new file called ProductRepositoryInterface.php and add the following code to it.
```php
    <?php

    namespace App\Interfaces;

    interface ProductRepositoryInterface
    {
        public function index();
        public function getById($id);
        public function store(array $data);
        public function update(array $data,$id);
        public function delete($id);
    }
```

## [](#header-2)Create Product Respository Class

Next, create a repository class for the Product model.
```sh
    php artisan make:class /Repositories/ProductRepository
```

in the classes, create a new file called ProductRepository.php and add the following code to it.
```php
    <?php
    namespace App\Repository;
    use App\Models\Product;
    use App\Interfaces\ProductRepositoryInterface;

    class ProductReposiotry implements ProductRepositoryInterface
    {
        public function index(){
            return Product::all();
        }

        public function getById($id){
        return Product::findOrFail($id);
        }

        public function store(array $data){
        return Product::create($data);
        }

        public function update(array $data,$id){
        return Product::whereId($id)->update($data);
        }

        public function delete($id){
        Product::destroy($id);
        }
    }
```

## [](#header-2)Bind The Interface And The Implementation

Note that all we need to do is bind the ProductRepository to the ProductRepositoryInterface. We do this via a Service Provider. Create one using the following command.
```sh
    php artisan make:provider RepositoryServiceProvider
```

Open app/Providers/RepositoryServiceProvider.php and update the register function to match the following
```php
    <?php
    namespace App\Providers;

    use Illuminate\Support\ServiceProvider;
    use App\Interfaces\ProductRepositoryInterface;
    use App\Repository\ProductReposiotry;

    class RepositoryServiceProvider extends ServiceProvider
    {
        /**
         * Register services.
         */
        public function register(): void
        {
            $this->app->bind(ProductRepositoryInterface::class,ProductReposiotry::class);
        }

        /**
         * Bootstrap services.
         */
        public function boot(): void
        {
            //
        }
    }
```

## [](#header-2)Request Validation

We have to make two requests namely StoreProductRequest and UpdateProductRequest, add the following code to it. For the input validation process.

#### File StoreProductRequest.php

```php
    <?php
    namespace App\Http\Requests;

    use Illuminate\Foundation\Http\FormRequest;
    use Illuminate\Http\Exceptions\HttpResponseException;
    use Illuminate\Contracts\Validation\Validator;

    class StoreProductRequest extends FormRequest
    {
        /**
         * Determine if the user is authorized to make this request.
         */
        public function authorize(): bool
        {
            return true;
        }

        /**
         * Get the validation rules that apply to the request.
         *
         * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
         */
        public function rules(): array
        {
            return [
                'name' => 'required',
                'details' => 'required'
            ];
        }

        public function failedValidation(Validator $validator)
        {
            throw new HttpResponseException(response()->json([
                'success'   => false,
                'message'   => 'Validation errors',
                'data'      => $validator->errors()
            ]));
        }
    }
```

#### File UpdateProductRequest.php

```php
    <?php

    namespace App\Http\Requests;

    use Illuminate\Foundation\Http\FormRequest;
    use Illuminate\Http\Exceptions\HttpResponseException;
    use Illuminate\Contracts\Validation\Validator;

    class UpdateProductRequest extends FormRequest
    {
        /**
         * Determine if the user is authorized to make this request.
         */
        public function authorize(): bool
        {
            return true;
        }

        /**
         * Get the validation rules that apply to the request.
         *
         * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
         */
        public function rules(): array
        {
            return [
                'name' => 'required',
                'details' => 'required'
            ];
        }

        public function failedValidation(Validator $validator)
        {
            throw new HttpResponseException(response()->json([
                'success'   => false,
                'message'   => 'Validation errors',
                'data'      => $validator->errors()
            ]));
        }
    }
```

## [](#header-2)Common ApiResponseClass Create

This common response class is the best practice thing. Because you can response send con function use. Create one using the following command
```sh
    php artisan make:class /Classes/ApiResponseClass
```

Add the following code to it.
```php
    <?php

    namespace App\Classes;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Http\Exceptions\HttpResponseException;
    use Illuminate\Support\Facades\Log;

    class ApiResponseClass
    {
        public static function rollback($e, $message ="Something went wrong! Process not completed"){
            DB::rollBack();
            self::throw($e, $message);
        }

        public static function throw($e, $message ="Something went wrong! Process not completed"){
            Log::info($e);
            throw new HttpResponseException(response()->json(["message"=> $message], 500));
        }

        public static function sendResponse($result , $message ,$code=200){
            $response=[
                'success' => true,
                'data'    => $result
            ];
            if(!empty($message)){
                $response['message'] =$message;
            }
            return response()->json($response, $code);
        }

    }
```

## [](#header-2)Create Product Resource

Create one using the following command.
```sh
    php artisan make:resource ProductResource
```

Add the following code to it.
```php
    <?php
    namespace App\Http\Resources;

    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\JsonResource;

    class ProductResource extends JsonResource
    {
        /**
         * Transform the resource into an array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'id' =>$this->id,
                'name' => $this->name,
                'details' => $this->details
            ];
        }
    }
```

## [](#header-2)Productcontroller Class

Run artisan as below
```sh
    php artisan make:controller ProductController -r
```

With our repository in place, let’s add some code to our controller. Open app/Http/Controllers/ProductController.php and update the code to match the following.
```php
    <?php

    namespace App\Http\Controllers;

    use App\Models\Product;
    use App\Http\Requests\StoreProductRequest;
    use App\Http\Requests\UpdateProductRequest;
    use App\Interfaces\ProductRepositoryInterface;
    use App\Classes\ResponseClass;
    use App\Http\Resources\ProductResource;
    use Illuminate\Support\Facades\DB;

    class ProductController extends Controller
    {

        private ProductRepositoryInterface $productRepositoryInterface;

        public function __construct(ProductRepositoryInterface $productRepositoryInterface)
        {
            $this->productRepositoryInterface = $productRepositoryInterface;
        }
        /**
         * Display a listing of the resource.
         */
        public function index()
        {
            $data = $this->productRepositoryInterface->index();

            return ResponseClass::sendResponse(ProductResource::collection($data),'',200);
        }

        /**
         * Show the form for creating a new resource.
         */
        public function create()
        {
            //
        }

        /**
         * Store a newly created resource in storage.
         */
        public function store(StoreProductRequest $request)
        {
            $details =[
                'name' => $request->name,
                'details' => $request->details
            ];
            DB::beginTransaction();
            try{
                $product = $this->productRepositoryInterface->store($details);

                DB::commit();
                return ResponseClass::sendResponse(new ProductResource($product),'Product Create Successful',201);

            }catch(\Exception $ex){
                return ResponseClass::rollback($ex);
            }
        }

        /**
         * Display the specified resource.
         */
        public function show($id)
        {
            $product = $this->productRepositoryInterface->getById($id);

            return ResponseClass::sendResponse(new ProductResource($product),'',200);
        }

        /**
         * Show the form for editing the specified resource.
         */
        public function edit(Product $product)
        {
            //
        }

        /**
         * Update the specified resource in storage.
         */
        public function update(UpdateProductRequest $request, $id)
        {
            $updateDetails =[
                'name' => $request->name,
                'details' => $request->details
            ];
            DB::beginTransaction();
            try{
                $product = $this->productRepositoryInterface->update($updateDetails,$id);

                DB::commit();
                return ResponseClass::sendResponse('Product Update Successful','',201);

            }catch(\Exception $ex){
                return ResponseClass::rollback($ex);
            }
        }

        /**
         * Remove the specified resource from storage.
         */
        public function destroy($id)
        {
            $this->productRepositoryInterface->delete($id);

            return ResponseClass::sendResponse('Product Delete Successful','',204);
        }
    }
```

## [](#header-2)Route Api

Executing the subsequent command allows you to publish the API route file:
```sh
php artisan install:api
```

To map each method defined in the controller to specific routes, add the following code to routes/api.php.
```php
    <?php

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Route;
    use App\Http\Controllers\ProductController;
    Route::get('/user', function (Request $request) {
        return $request->user();
    })->middleware('auth:sanctum');


    Route::apiResource('/products',ProductController::class);
```

