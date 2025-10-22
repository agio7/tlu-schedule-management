# Firebase Postman Collection Guide

## 🔐 Firebase Authentication REST API

### Base URL
```
https://identitytoolkit.googleapis.com/v1/accounts
```

### Environment Variables
```
firebase_api_key: YOUR_FIREBASE_API_KEY
firebase_project_id: YOUR_PROJECT_ID
```

### 1. Sign In with Email/Password
```
POST {{base_url}}/accounts:signInWithPassword?key={{firebase_api_key}}

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "email": "admin@tlu.edu.vn",
  "password": "admin123",
  "returnSecureToken": true
}

Response:
{
  "kind": "identitytoolkit#VerifyPasswordResponse",
  "localId": "USER_UID",
  "email": "admin@tlu.edu.vn",
  "displayName": "Admin System",
  "idToken": "JWT_TOKEN",
  "registered": true,
  "refreshToken": "REFRESH_TOKEN",
  "expiresIn": "3600"
}
```

### 2. Sign Up with Email/Password
```
POST {{base_url}}/accounts:signUp?key={{firebase_api_key}}

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "email": "test@example.com",
  "password": "password123",
  "returnSecureToken": true
}
```

### 3. Get User Info
```
POST {{base_url}}/accounts:lookup?key={{firebase_api_key}}

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "idToken": "{{id_token}}"
}
```

### 4. Refresh Token
```
POST {{base_url}}/token?key={{firebase_api_key}}

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "grant_type": "refresh_token",
  "refresh_token": "{{refresh_token}}"
}
```

### 5. Sign Out
```
POST {{base_url}}/accounts:signOut?key={{firebase_api_key}}

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "idToken": "{{id_token}}"
}
```

## 📊 Cloud Firestore REST API

### Base URL
```
https://firestore.googleapis.com/v1/projects/{{firebase_project_id}}/databases/(default)/documents
```

### 1. Create Document
```
POST {{base_url}}/users

Headers:
Authorization: Bearer {{id_token}}
Content-Type: application/json

Body (raw JSON):
{
  "fields": {
    "email": {
      "stringValue": "admin@tlu.edu.vn"
    },
    "fullName": {
      "stringValue": "Admin System"
    },
    "role": {
      "stringValue": "admin"
    },
    "createdAt": {
      "timestampValue": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 2. Get Document
```
GET {{base_url}}/users/USER_DOCUMENT_ID

Headers:
Authorization: Bearer {{id_token}}
```

### 3. Update Document
```
PATCH {{base_url}}/users/USER_DOCUMENT_ID

Headers:
Authorization: Bearer {{id_token}}
Content-Type: application/json

Body (raw JSON):
{
  "fields": {
    "updatedAt": {
      "timestampValue": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 4. Delete Document
```
DELETE {{base_url}}/users/USER_DOCUMENT_ID

Headers:
Authorization: Bearer {{id_token}}
```

### 5. List Documents
```
GET {{base_url}}/users

Headers:
Authorization: Bearer {{id_token}}
```

### 6. Query Documents
```
POST {{base_url}}/users:runQuery

Headers:
Authorization: Bearer {{id_token}}
Content-Type: application/json

Body (raw JSON):
{
  "structuredQuery": {
    "where": {
      "fieldFilter": {
        "field": {
          "fieldPath": "role"
        },
        "op": "EQUAL",
        "value": {
          "stringValue": "admin"
        }
      }
    }
  }
}
```

## 🏗️ Firebase Functions REST API

### Base URL
```
https://us-central1-{{firebase_project_id}}.cloudfunctions.net
```

### 1. Call Function
```
POST {{base_url}}/functionName

Headers:
Authorization: Bearer {{id_token}}
Content-Type: application/json

Body (raw JSON):
{
  "data": {
    "param1": "value1",
    "param2": "value2"
  }
}
```

## 🧪 Testing Examples

### Test Authentication Flow
1. **Sign In** → Get `idToken` và `refreshToken`
2. **Get User Info** → Verify user data
3. **Refresh Token** → Get new `idToken`
4. **Sign Out** → Clear session

### Test Firestore CRUD
1. **Create Document** → Test create operation
2. **Get Document** → Test read operation
3. **Update Document** → Test update operation
4. **Delete Document** → Test delete operation
5. **List Documents** → Test query operation

### Test Error Handling
1. **Invalid Credentials** → Test authentication errors
2. **Invalid Token** → Test authorization errors
3. **Invalid Document ID** → Test not found errors
4. **Permission Denied** → Test security rules

## 🔧 Postman Collection Setup

### 1. Create New Collection
- Name: "Firebase API Tests"
- Description: "Complete Firebase REST API testing"

### 2. Set Environment Variables
```
firebase_api_key: AIzaSyBxxxxxxxxxxxxxxxxxxxxxxx
firebase_project_id: your-project-id
base_url: https://identitytoolkit.googleapis.com/v1/accounts
firestore_url: https://firestore.googleapis.com/v1/projects/your-project-id/databases/(default)/documents
id_token: (will be set automatically after sign in)
refresh_token: (will be set automatically after sign in)
```

### 3. Create Pre-request Scripts
```javascript
// Auto-set id_token from response
if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.idToken) {
        pm.environment.set("id_token", response.idToken);
    }
    if (response.refreshToken) {
        pm.environment.set("refresh_token", response.refreshToken);
    }
}
```

### 4. Create Tests
```javascript
// Test response status
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Test response structure
pm.test("Response has required fields", function () {
    const response = pm.response.json();
    pm.expect(response).to.have.property('kind');
});

// Test authentication
pm.test("User is authenticated", function () {
    const response = pm.response.json();
    pm.expect(response).to.have.property('idToken');
});
```

## 📋 Complete Postman Collection Structure

```
Firebase API Tests/
├── Authentication/
│   ├── Sign In
│   ├── Sign Up
│   ├── Get User Info
│   ├── Refresh Token
│   └── Sign Out
├── Firestore/
│   ├── Users/
│   │   ├── Create User
│   │   ├── Get User
│   │   ├── Update User
│   │   ├── Delete User
│   │   └── List Users
│   ├── Departments/
│   │   ├── Create Department
│   │   ├── Get Department
│   │   ├── Update Department
│   │   ├── Delete Department
│   │   └── List Departments
│   ├── Subjects/
│   │   ├── Create Subject
│   │   ├── Get Subject
│   │   ├── Update Subject
│   │   ├── Delete Subject
│   │   └── List Subjects
│   └── Query Tests/
│       ├── Query by Role
│       ├── Query by Department
│       └── Complex Queries
├── Functions/
│   ├── Call Function
│   └── Test Function Response
└── Error Handling/
    ├── Invalid Credentials
    ├── Invalid Token
    ├── Permission Denied
    └── Network Errors
```

## 🎯 Benefits of Using Postman with Firebase

### ✅ Advantages:
- **Visual Testing**: Easy to see requests/responses
- **Environment Management**: Switch between dev/prod
- **Automated Testing**: Run tests in sequence
- **Documentation**: Built-in API documentation
- **Team Collaboration**: Share collections
- **CI/CD Integration**: Run tests in pipelines

### ⚠️ Limitations:
- **SDK Features**: Some Firebase features only available in SDK
- **Real-time Updates**: Can't test real-time listeners
- **Offline Support**: Can't test offline capabilities
- **Platform-specific**: Some features are platform-specific

## 🚀 Getting Started

1. **Install Postman**
2. **Import Collection** (from this guide)
3. **Set Environment Variables**
4. **Run Authentication Tests**
5. **Run Firestore Tests**
6. **Create Custom Tests**

## 📝 Notes

- **Firebase API Key**: Get from Firebase Console > Project Settings
- **Project ID**: Get from Firebase Console > Project Settings
- **Security Rules**: Make sure Firestore rules allow your requests
- **Rate Limits**: Firebase has rate limits, don't spam requests
- **Token Expiry**: `idToken` expires in 1 hour, use `refreshToken` to get new one
