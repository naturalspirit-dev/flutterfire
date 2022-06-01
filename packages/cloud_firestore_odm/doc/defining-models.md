# Defining Models

> The Cloud Firestore ODM is currently in **alpha**. Expect breaking changes, API changes and more. The documentation is still a work in progress. See the [discussion](https://github.com/firebase/flutterfire/discussions/7475) for more details.

A model represents exactly what data we expect to both receive and mutate on Firestore. The ODM
ensures that all data is validated against a model, and if the model is not valid an error will be
thrown.

To get started, assume we have a collection on our Firestore database called "Users". The collection
contains many documents containing user information such as a name, age, email (and so on!). To
define a model for this data, create a class:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';

// This doesn't exist yet...! See "Next Steps"
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  });

  final String name;
  final int age;
  final String email;
}
```

The `User` model defines that a user must have a name and email as a `String` and age as an `int`.

If your model class is defined in a separate file than the Firestore reference,
you will need to explicitly specify `fromJson`/`toJson` functions as followed:

```dart
@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  });

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  final String name;
  final int age;
  final String email;

  Map<String, Object?> toJson() => _$UserToJson(this);
}
```

**Note**: `JsonSerializable(fieldRename: ...)` and `JsonKey(ignore: true)` are currently not supported

## Model validation

Defining a model with standard Dart types (e.g. `String`, `int` etc) works for many applications,
but what about more bespoke validation?

For example, a users age cannot be a negative value, so how do we validate against this?

The ODM provides some basic annotation validators which can be used on model properties. In this
example, we can take advantage of the `Min` validator:

```dart
@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  }) {
    // Apply the validator
    _$assertUser(this);
  }

  final String name;
  final String email;

  // Apply the `Min` validator
  @Min(0)
  final int age;
}
```

The `Min` annotation ensures that any value for the `age` property is always positive, otherwise an
error will be thrown.

To ensure validators are applied, the model instance is provided to the generated `$assertUser`
method. Note the name of this class is generated based on the model name (for example a model named
`Product` with validators would generate a `$assertProduct` method).

### Available validators

#### `int`

The following annotations are available for `int` properties:

| Annotation | Description                                        |
|------------|----------------------------------------------------|
| `Min`      | Validates a number is not less than this value.    |
| `Max`      | Validates a number is not greater than this value. |

### Custom validators

In some cases, you may wish to validate data against custom validation. For example, we may want to
ensure the string value provided to `email` is in-fact a valid email address.

To define a custom validator, create a class which implements `Validator`:

```dart
class EmailAddressValidator implements Validator<String> {
  const EmailAddressValidator();

  @override
  void validate(String value) {
    if (!value.endsWith("@google.com")) {
      throw Exception("Email address is not valid!");
    }
  }
}
```

Within the model, you can then apply the validator to the property:

```dart
@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  }) {
    // Apply the validator
    _$assertUser(this);
  }

  final String name;
  final int age;

  @EmailAddressValidator()
  final String email;
}
```

## Creating references

On their own, a model does not do anything. Instead we create a "reference" using a model.
A reference enables the ODM to interact with Firestore using the model.

To create a reference, we use the `Collection` annotation which is used as a pointer to a collection
within the Firestore database. For example, the `users` collection in the root of the database
corresponds to the `Users` model we defined previously:

```dart
@JsonSerializable(explicitToJson: true)
class User {
 // ...
}

@Collection<User>('users')
final usersRef = UserCollectionReference();
```

If you are looking to define a model as a reference on a Subcollection, read the [Working with Subcollections](./subcollections.md) documentation.

## Next Steps

Some of the code on this page is created via code generation
(e.g. `_$assertUser`, `UserCollectionReference`) - you can learn more about
how to generate this code via the [Code Generation](./code-generation.md) documentation!
