# Firebase Configuration Guide for AyamSegar

To ensure the application works correctly with Firestore and Storage, please apply the following security rules in your Firebase Console.

## 1. Cloud Firestore Rules
Go to **Firestore Database** > **Rules** and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Allow sellers to read all users (for viewing order customer names)
    match /users/{userId} {
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'seller';
    }
    // Products are readable by everyone, but only sellers can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'seller';
    }
    // Orders and Notifications
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 2. Firebase Storage Rules
Go to **Storage** > **Rules** and paste this:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Allow read/write if the user is authenticated
      allow read, write: if request.auth != null;
    }
  }
}
```

## 3. Important Note on Seller Role
The app is configured to automatically assign the `seller` role to the email `indra020204@gmail.com`. If you use a different email for testing the seller dashboard, you must manually change the `role` field to `seller` in the Firestore `users` collection for that specific user document.
