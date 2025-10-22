# Postman với Firebase - Hướng dẫn sử dụng

## 🎯 **CÓ THỂ DÙNG POSTMAN VỚI FIREBASE**

### **✅ Firebase cung cấp REST APIs:**
- **Firebase Authentication** - REST API
- **Cloud Firestore** - REST API  
- **Firebase Storage** - REST API
- **Firebase Functions** - HTTP endpoints

### **❌ Không thể test:**
- **Real-time listeners** (chỉ có trong SDK)
- **Offline capabilities** (chỉ có trong SDK)
- **Platform-specific features** (chỉ có trong SDK)

## 🚀 **CÁCH SỬ DỤNG POSTMAN VỚI FIREBASE**

### **BƯỚC 1: Cài đặt Postman**
1. **Download** Postman từ [postman.com](https://postman.com)
2. **Install** và tạo account
3. **Mở** Postman

### **BƯỚC 2: Import Collection**
1. **Click** "Import" trong Postman
2. **Chọn** file `firebase_postman_collection.json`
3. **Import** collection

### **BƯỚC 3: Setup Environment**
1. **Click** "Environments" trong Postman
2. **Import** file `firebase_postman_environment.json`
3. **Chọn** environment "Firebase API Tests Environment"
4. **Cập nhật** các giá trị:
   - `firebase_api_key`: API Key từ Firebase Console
   - `firebase_project_id`: Project ID từ Firebase Console

### **BƯỚC 4: Test Authentication**
1. **Mở** request "Sign In"
2. **Click** "Send"
3. **Kiểm tra** response có `idToken` và `refreshToken`
4. **Tokens** sẽ được tự động lưu vào environment

### **BƯỚC 5: Test Firestore**
1. **Mở** request "Create User"
2. **Click** "Send"
3. **Kiểm tra** response có document ID
4. **Test** các CRUD operations khác

## 🔧 **CÁC REQUEST QUAN TRỌNG**

### **1. Authentication Requests**

#### **Sign In**
```
POST https://identitytoolkit.googleapis.com/v1/accounts/accounts:signInWithPassword?key=YOUR_API_KEY

Body:
{
  "email": "admin@tlu.edu.vn",
  "password": "admin123",
  "returnSecureToken": true
}
```

#### **Get User Info**
```
POST https://identitytoolkit.googleapis.com/v1/accounts/accounts:lookup?key=YOUR_API_KEY

Body:
{
  "idToken": "YOUR_ID_TOKEN"
}
```

### **2. Firestore Requests**

#### **Create Document**
```
POST https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users

Headers:
Authorization: Bearer YOUR_ID_TOKEN
Content-Type: application/json

Body:
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
    }
  }
}
```

#### **Get Document**
```
GET https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users/DOCUMENT_ID

Headers:
Authorization: Bearer YOUR_ID_TOKEN
```

#### **Update Document**
```
PATCH https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users/DOCUMENT_ID

Headers:
Authorization: Bearer YOUR_ID_TOKEN
Content-Type: application/json

Body:
{
  "fields": {
    "updatedAt": {
      "timestampValue": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### **Delete Document**
```
DELETE https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users/DOCUMENT_ID

Headers:
Authorization: Bearer YOUR_ID_TOKEN
```

#### **List Documents**
```
GET https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users

Headers:
Authorization: Bearer YOUR_ID_TOKEN
```

#### **Query Documents**
```
POST https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/users:runQuery

Headers:
Authorization: Bearer YOUR_ID_TOKEN
Content-Type: application/json

Body:
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

## 🧪 **TESTING WORKFLOW**

### **1. Authentication Flow**
1. **Sign In** → Get `idToken` và `refreshToken`
2. **Get User Info** → Verify user data
3. **Refresh Token** → Get new `idToken`
4. **Sign Out** → Clear session

### **2. Firestore CRUD Flow**
1. **Create Document** → Test create operation
2. **Get Document** → Test read operation
3. **Update Document** → Test update operation
4. **Delete Document** → Test delete operation
5. **List Documents** → Test query operation

### **3. Error Handling Flow**
1. **Invalid Credentials** → Test authentication errors
2. **Invalid Token** → Test authorization errors
3. **Invalid Document ID** → Test not found errors
4. **Permission Denied** → Test security rules

## 🔍 **KIỂM TRA KẾT QUẢ**

### **Successful Response Examples**

#### **Sign In Success**
```json
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

#### **Create Document Success**
```json
{
  "name": "projects/YOUR_PROJECT_ID/databases/(default)/documents/users/DOCUMENT_ID",
  "fields": {
    "email": {
      "stringValue": "admin@tlu.edu.vn"
    },
    "fullName": {
      "stringValue": "Admin System"
    },
    "role": {
      "stringValue": "admin"
    }
  },
  "createTime": "2024-01-01T00:00:00Z",
  "updateTime": "2024-01-01T00:00:00Z"
}
```

### **Error Response Examples**

#### **Authentication Error**
```json
{
  "error": {
    "code": 400,
    "message": "INVALID_PASSWORD",
    "errors": [
      {
        "message": "INVALID_PASSWORD",
        "domain": "global",
        "reason": "invalid"
      }
    ]
  }
}
```

#### **Permission Denied Error**
```json
{
  "error": {
    "code": 403,
    "message": "Permission denied",
    "status": "PERMISSION_DENIED"
  }
}
```

## 🎯 **LỢI ÍCH CỦA POSTMAN VỚI FIREBASE**

### **✅ Advantages:**
- **Visual Testing**: Dễ dàng xem requests/responses
- **Environment Management**: Chuyển đổi giữa dev/prod
- **Automated Testing**: Chạy tests theo sequence
- **Documentation**: API documentation tích hợp
- **Team Collaboration**: Chia sẻ collections
- **CI/CD Integration**: Chạy tests trong pipelines

### **⚠️ Limitations:**
- **SDK Features**: Một số tính năng chỉ có trong SDK
- **Real-time Updates**: Không thể test real-time listeners
- **Offline Support**: Không thể test offline capabilities
- **Platform-specific**: Một số tính năng chỉ có trên platform cụ thể

## 🚀 **GETTING STARTED**

### **1. Setup Firebase Project**
1. **Vào** Firebase Console
2. **Chọn** project của bạn
3. **Vào** Project Settings
4. **Copy** API Key và Project ID

### **2. Import Postman Collection**
1. **Download** file `firebase_postman_collection.json`
2. **Import** vào Postman
3. **Setup** environment variables

### **3. Run Tests**
1. **Chọn** environment "Firebase API Tests Environment"
2. **Chạy** request "Sign In"
3. **Kiểm tra** response
4. **Chạy** các tests khác

### **4. Customize Tests**
1. **Tạo** requests mới
2. **Thêm** tests scripts
3. **Chia sẻ** với team

## 📝 **NOTES**

- **Firebase API Key**: Lấy từ Firebase Console > Project Settings
- **Project ID**: Lấy từ Firebase Console > Project Settings
- **Security Rules**: Đảm bảo Firestore rules cho phép requests
- **Rate Limits**: Firebase có rate limits, không spam requests
- **Token Expiry**: `idToken` hết hạn sau 1 giờ, dùng `refreshToken` để lấy mới

## 🎉 **KẾT LUẬN**

**Postman rất phù hợp với Firebase** để test:
- ✅ **Authentication APIs**
- ✅ **Firestore CRUD operations**
- ✅ **Error handling**
- ✅ **API documentation**
- ✅ **Team collaboration**

**Không thể test:**
- ❌ **Real-time features**
- ❌ **Offline capabilities**
- ❌ **Platform-specific features**

**Postman là công cụ tuyệt vời để test Firebase REST APIs!** 🚀
