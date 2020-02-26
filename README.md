# README
https://dpl-sheets.netlify.com/debug
# Rails Migration
https://edgeguides.rubyonrails.org/active_record_migrations.html

## UP/DOWN VS Change
>The change method is pretty standard when it comes to migrations partly because it’s a newer addition to Rails. Just like up and down, the change method is defined on the ActiveRecord::Migration class
```ruby
class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.integer :year

      t.timestamps null: false
    end
  end
end
```

```ruby
class CreateBooks < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string :title
      t.integer :year
    end
  end

  def down
    drop_table :books
  end
end
```

## using rollback
`rails  db:migrate:status` 
> show status

`rails db:rollback` 
> notice schema changes with rollback

`db:rollback STEP=3` 
> go back 3 migrations

# Routes
https://guides.rubyonrails.org/routing.html
> routes.rb example
```ruby
#http  url                  action
 get   '/patients/:id', to: 'patients#show'
```

> in patients_controller show method
```ruby
@patient = Patient.find(params[:id])
```
>nested routes
```ruby
resources :artists do
  resources :songs
end
```
![Test Image 4](https://miro.medium.com/max/1576/1*p0bSk96YELjIIGzR_d7ALg.png)
```ruby
#http  url                                  action               helper
 get "/wwwwhaaat/:is_this/:franks_red", to: "static_pages#boom", as: "hell_yeah"
```
> Let's look at this in code

# Models
  `rails generate scaffold post title body:text published:boolean` 

  ```ruby 
# t.string "title"
# t.text "body"
# t.boolean "published"

class Post < ApplicationRecord
  validates :title, presence: true, length: { in: 6..20 }
  before_save :normalize_title, on: :create
  # p1 = Post.create(title:nil)
  # p1.errors
  # p1.errors.messages
  # => {:title=>["can't be blank", "is too short (minimum is 6 characters)"]}

  # instance methods
  def about
    if self.published
      "#{self.title} is a published book"
    else
      "#{self.title} is a unpublished book"
    end
  end

  # class methods
  def self.unpublished
    Post.where(published: false)
  end
  def self.published
    Post.where(published: true)
  end

  private

  def normalize_title
    self.title = title.downcase.titleize
    # 'tItle herE'.downcase.titleize => "Title Here"
  end
end
  ```

## Validations
https://guides.rubyonrails.org/active_record_validations.html

# Associations
source https://dzone.com/articles/rails-associations

An **association** is a connection between two **Active Record models**. It makes it much _easier_ to perform various operations on the records in your code. We will divide associations into four categories:

1.  One-to-One
2.  One-to-Many
3.  Many-to-Many
4.  Polymorphic One-to-Many

If you are new to Ruby on Rails, be sure to get up your [rails project](https://kolosek.com/ruby-programming-beginners-guide/) ready and check how to [create models](https://kolosek.com/rails-scaffold/) in Rails.

One-to-One
----------

When you set up **one-to-one** relations you are saying that a record contains exactly one instance of another model. For example, if each user in your application has only one profile, you can describe your models as:
```ruby
class User < ApplicationRecord       class Profile < ApplicationRecord

 has_one :profile                     belongs_to :user

end                                  end
```

One of the models in the given relation will have the `has_one` method invocation and another one will have `belongs_to`. It is used to describe which model contains **a foreign key** reference to the other one, in our case, it is the profiles model.

![](https://storage.kraken.io/kk8yWPxzXVfBD3654oMN/dd9c653b0c0005b92cdf4a6bdcc10a3e/one-to-one.png)


One-to-Many
-----------

A **one-to-many** association is the most common used relation. This association indicates that each instance of the model A can have **zero or more** instances of another model B and model B belongs to **only one** model A.

Let's check it out via an example. We want to create an application where users can write multiple stories, our models should look like this:
```ruby
class User < ApplicationRecord       class Story < ApplicationRecord

 has_many :stories                     belongs_to :user

end                                  end
```

Here, deciding which model will have `has_many` and which will have `belongs_to` is more important than in **one-to-one** relations, because it changes the logic of your application. In both cases, the second model contains one reference to the first model in form of a **foreign key**.

The second model doesn't know about the first model's relation to it - it is not aware if the first model has a reference to more than one of them or just to one.

![](https://storage.kraken.io/kk8yWPxzXVfBD3654oMN/ec6c6326b0948276a487af75a13ee4c9/one-to-many.png)  
The tests for associations get more complex to write the more relations you create. You should check out how to create your own [association factories](https://kolosek.com/factory-girl-associations/) to make your testing life easier.

Many-to-Many
------------

**Many-to-many** associations are a bit more complex and can be handled in two ways, **"has and belongs to many"** and **"has many through"** relations.

### Has and Belongs to Many

A `has_and_belongs_to_many` association creates a direct **many-to-many** connection with another model. It is simpler than the other one, as it only requires calling `has_and_belongs_to_many` from both models.

![](https://storage.kraken.io/kk8yWPxzXVfBD3654oMN/6e59bce7bc11d74d4f3b42aa264f0db8/has-and-belongs-to-many.png)

_Example:_ Let's say, a user can have many different roles and the same role may contain many users, our models would be like this:
```ruby
class User < ApplicationRecord       class Role < ApplicationRecord

 has_and_belongs_to_many :roles       has_and_belongs_to_many :users

end                                  end
```

You will need to create a **join table** for this association to work. It is a table that connects two different models. The join table is created with rails function `create_join_table :user, :role` in a separate [migration](https://kolosek.com/rake-db-commands/).

```ruby
class CreateUserRoles < ActiveRecord::Migration
 def change
 create_table :user_roles, id: false do |t|
  # t.references is the same as t.belongs_to
 t.references :user, index: true, foreign_key: true
 t.references :role, index: true, foreign_key: true
 end
 end
end
```

This is a very simple approach, but you don't have the direct access to related objects, you can only hold references to two models and nothing else.

# Has Many Through

Another way to define a **many-to-many** association is to use the **has many through** association type. Here we define a **separate model**, to handle that connection between two different ones.

![](https://storage.kraken.io/kk8yWPxzXVfBD3654oMN/78cbb30deb837728cb6d6153b31c6fb3/has_many_through.png)

Instead of putting down a new example, you should check [this one out](https://kolosek.com/rails-join-table/)! It explains everything you should know about this association.

Using the example of `has_and_belongs_to_many` association, this time the three models should be written like this:
```ruby
class User < ApplicationRecord
 has_many :user_roles
 has_many :roles, through: :user_roles
end

class UserRoles < ApplicationRecord
 belongs_to :user
 belongs_to :role
end

class Role < ApplicationRecord
 has_many :user_roles
 has_many :users, through: :user_roles
end
```
This **association** will enable you to do things like `user.role` and to get a list of all connected second model instances. It will also enable you to get access to data specific to the relation between first and second models.

Polymorphic
-----------

**Polymorphic associations** are the most advanced associations available to us. You can use it when you have a model that may belong to many different models on a single association.

![](https://storage.kraken.io/kk8yWPxzXVfBD3654oMN/6058d06ae05bb5c5ea77ebbc9fa1aabf/polymorphic.png)

Let's imagine you want to be able to write comments for users and stories. You want both models to be commentable. Here's how this could be declared:

``` ruby
class Comment < ApplicationRecord
 belongs_to :commentable, polymorphic: true
end

class Employee < ApplicationRecord
 has_many :comment, as: :commentable
end

class Product < ApplicationRecord
 has_many :comment, as: :commentable
end
```
You can think of a polymorphic `belongs_to` declaration as **setting up an interface** that any other model can use. To declare the **polymorphic interface** you need to declare both a foreign key column and a type column in the model. You should [run the migration](https://kolosek.com/rake-db-commands/) once you are done.

```ruby
class CreateComments < ActiveRecord::Migration
 def change
  create_table :comments do |t|
  t.text :body
  t.integer :commentable_id
  t.string :commentable_type
  t.timestamps
 end

 add_index :comments, :commentable_id

 end

end
```
```ruby
This migration can be simplified by using **references**:

class CreateComments < ActiveRecord::Migration
  def change
  create_table :comments do |t|
    t.text :body
    # t.references is the same as t.belongs_to
    t.references :commentable, polymorphic: true, index: true
    t.timestamps
  end
 end

end
```

Additional Options
-----------------

There are a few additional options you can use when defining **relations between models**, we will cover two most commonly used ones.

### dependent

You can use this option when you want to get rid of **orphaned records** since they can lead to various problems. Orphaned records are created when we **delete or destroy** model A that was associated with model B, but model B wasn't removed in the process.

class User < ApplicationRecord

 has_many :stories, dependent: :destroy

end

_Example:_ Suppose, a user called Maria wrote a lot of stories. Then, we deleted Maria from the database, but the stories still have the `user_id`column set to Maria's id. These stories are called **orphaned records**.

Thank you for reading!

## Devise
gem "devise"

`rails g devise:install`

>Actually install devise in our app. Gives us instructions to follw

`rails g devise user`
>This will create a migration file for our Users table. We can add any other columns here and we can comment out any of the Devise columns if we want them.

`rails db:migrate`
>Now we have a Users table with email and password columns. Plus any other columns we may have wanted.

```ruby
# in routes.rb
devise_for :users
```

`before_action :authenticate_user!`
> in any controller we can use this

```ruby
  def index
    @accounts = current_user.accounts
  end
```
> using current_user to access models

## Flash Messages
```ruby
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
```

## Has Many through

### 1. Create your app

    rails new demo_yo
    cd demo_yo
    

### 2. Generate scaffolding

We’ll need a model for Physicians, Patients, and Appointments. Create them as follows:

```
    rails generate scaffold Physician name:string
    rails generate scaffold Patient name:string
    rails generate scaffold Appointment physician:belongs_to patient:belongs_to appointment_date:datetime
  ```

  Migrations Files

  ```ruby
class CreatePhysicians < ActiveRecord::Migration[6.0]
  def change
    create_table :physicians do |t|
      t.string :name

      t.timestamps
    end
  end
end
class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :name

      t.timestamps
    end
  end
end
  class CreateAppointments < ActiveRecord::Migration[6.0]
  def change
    create_table :appointments do |t|
      t.belongs_to :physician, null: false, foreign_key: true
      t.belongs_to :patient, null: false, foreign_key: true
      t.datetime :appointment_date

      t.timestamps
    end
  end
end
``` 

Finally, migrate the database

    rails db:migrate
    

### 3. Setup the model associations

Make your model/appointment.rb file look like this:
``` ruby
    class Appointment < ActiveRecord::Base
      # attr_accessible :appointment_date, :patient_id, :physician_id
      belongs_to :physician
      belongs_to :patient
    end
```

Make your model/physician.rb file look like this:
``` ruby
    class Physician < ActiveRecord::Base
      # attr_accessible :name
      has_many :appointments
      has_many :patients, :through => :appointments
    end
 ```   

Make your model/patient.rb file look like this:
```ruby 
    class Patient < ActiveRecord::Base
      # attr_accessible :name
      has_many :appointments
      has_many :physicians, :through => :appointments
    end
```    

### 4. Create some records

Now, you can go to the URLs below and create records for each of the models. Create some Physicians and some Patients first. For the Appointments, simply enter the ID number of the respective Physicians and Patients. The URLs are:
```
    localhost:3000/patients
    localhost:3000/physicians
    localhost:3000/appointment
```   

### 5. View the associations via console

Once you do this, you can view the associations via console. First go into console by typing:
```
    rails c
```   

Now, if you set a Patient into a variable like this:
```
    p = Patient.find(1)
```   

…You can then view all of that Patient’s appointments or physicians by typing this:
```
    p.appointments
    p.physicians
```    

The commands above let me view a patient’s appointments, and a patient’s physicians. But wait, there’s more – I can take this a step further. Suppose I want to view a patient’s physician’s appointments, OR a patient’s appointment’s physician. You can do these as follows:
```
    # Set a patient into the variable 'p'
    p = Patient.find(1)
    
    # Show the patient's physician for a certain appointment
    p.appointments.find(1).physician
    
    # Show the appointments belonging to one of the patient's physicians
    p.physicians.find(1).appointments
```   

The main point here is when models are associated, you can use jump up/down the chain in a single line of code – and Ruby is able to understand what you’re looking for.