---
title: Video Platform API
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - ruby: Ruby
  - python: Python
  - php: PHP
  - java: Java
  - go: Go
toc_footers: []
includes: []
search: true
code_clipboard: true
highlight_theme: darkula
headingLevel: 2
generator: "@tarslib/widdershins v4.0.30"

---

# Video Platform API

每次身份验证请求带上 Bearer JWT，未登录可带上 `Bearer guest`。

Base URLs:

# Authentication

- HTTP Authentication, scheme: bearer<br/>未登录访问可使用固定值 `guest` 作为 token。

- HTTP Authentication, scheme: bearer

# Auth

## POST 登录

POST /api/auth/login

> Body 请求参数

```json
{
  "username": "admin01",
  "password": "12345678"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[LoginRequest](#schemaloginrequest)| 是 |none|

> 返回示例

> 登录结果

```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiJ9.mock.user3"
}
```

```json
{
  "success": false,
  "msg": "登录失败，用户名或密码错误"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|登录结果|[LoginResponse](#schemaloginresponse)|

## POST 注册

POST /api/auth/register

> Body 请求参数

```json
{
  "username": "new_user@test.com",
  "password": "password123",
  "nickname": "NewUser",
  "bio": "Hello, I am new here."
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[RegisterRequest](#schemaregisterrequest)| 是 |none|

> 返回示例

> 注册结果

```json
{
  "success": true,
  "msg": "注册成功"
}
```

```json
{
  "success": false,
  "msg": "注册失败，用户名已存在"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|注册结果|[ResultVO](#schemaresultvo)|

## POST 修改密码

POST /api/auth/change-password

> Body 请求参数

```json
{
  "oldPassword": "123",
  "newPassword": "123456"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[ChangePasswordRequest](#schemachangepasswordrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|修改密码结果|[ResultVO](#schemaresultvo)|

## POST 注销账号

POST /api/auth/delete-account

当前用户由 Bearer JWT 的 payload 决定，请求体只提交账号密码。

> Body 请求参数

```json
{
  "password": "string"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[DeleteAccountRequest](#schemadeleteaccountrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|注销结果|[ResultVO](#schemaresultvo)|

# User

## POST 修改个人信息

POST /api/users/profile

当前用户由 Bearer JWT 的 payload 决定，请求体只提交要修改的新昵称或简介。

> Body 请求参数

```json
{
  "nickname": "阙建军",
  "bio": "作者，父母，电影爱好者🎮"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[UpdateProfileRequest](#schemaupdateprofilerequest)| 否 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|修改结果|[ResultVO](#schemaresultvo)|

## GET 用户信息

GET /api/users/1

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|query|string| 否 |none|

> 返回示例

> 200 Response

```json
{
  "id": 3,
  "nickname": "Alice",
  "bio": "Hello, I am Alice.",
  "likes": 2,
  "earn_coins": 50,
  "videos": [
    {
      "id": 2,
      "title": "My first vlog",
      "thumbnail": "http://example.com/t2.jpg",
      "likes": 1,
      "earn_coins": 0
    },
    {
      "id": 3,
      "title": "Cooking tutorial",
      "thumbnail": "http://example.com/t3.jpg",
      "likes": 0,
      "earn_coins": 0
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|当前用户信息|[UserMeResponse](#schemausermeresponse)|

# Admin

## GET 查看所有用户

GET /api/admin/users

> 返回示例

> 200 Response

```json
{
  "users": [
    {
      "id": 1,
      "nickname": "Administrator",
      "role": "admin"
    },
    {
      "id": 2,
      "nickname": "BadGuy",
      "role": "ban"
    },
    {
      "id": 3,
      "nickname": "Alice",
      "role": "active"
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|用户列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» users|[[AdminUserItem](#schemaadminuseritem)]|false|none||none|
|»» id|integer|false|none||none|
|»» nickname|string|false|none||用户名称|
|»» role|string|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|role|active|
|role|ban|
|role|admin|

## POST 封禁账号

POST /api/admin/users/ban

> Body 请求参数

```json
{
  "user_id": 2
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» user_id|body|integer| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|封禁结果|[ResultVO](#schemaresultvo)|

## GET 查看审核视频

GET /api/admin/videos/pending

> 返回示例

> 200 Response

```json
{
  "videos": [
    {
      "id": 7,
      "title": "Unboxing new phone",
      "thumbnail": "http://example.com/t7.jpg",
      "uploader": "Bob"
    },
    {
      "id": 13,
      "title": "Daily news",
      "thumbnail": "http://example.com/t13.jpg",
      "uploader": "Charlie"
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|待审核视频列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» videos|[object]|false|none||none|
|»» id|integer|false|none||none|
|»» title|string|false|none||none|
|»» thumbnail|string|false|none||none|
|»» uploader|string|false|none||none|

## POST 审核视频

POST /api/admin/videos/review

> Body 请求参数

```json
{
  "video_id": 3,
  "action": "reject"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» video_id|body|integer| 是 |none|
|» action|body|string| 是 |none|

#### 枚举值

|属性|值|
|---|---|
|» action|approve|
|» action|reject|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|审核结果|[ResultVO](#schemaresultvo)|

## GET 查看举报列表

GET /api/admin/reports

> 返回示例

> 200 Response

```json
{
  "reports": [
    {
      "id": 1,
      "video_id": 8,
      "reason": "Spam content",
      "reporter": "Alice"
    },
    {
      "id": 2,
      "video_id": 20,
      "reason": "Also spam",
      "reporter": "Bob"
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|举报列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» reports|[object]|false|none||none|
|»» id|integer|false|none||none|
|»» video_id|integer|false|none||none|
|»» reason|string|false|none||none|
|»» reporter|string|false|none||none|

## POST 处理举报

POST /api/admin/reports/handle

> Body 请求参数

```json
{
  "report_id": 1,
  "action": "approve"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» report_id|body|integer| 是 |none|
|» action|body|string| 是 |none|

#### 枚举值

|属性|值|
|---|---|
|» action|approve|
|» action|reject|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|处理举报结果|[ResultVO](#schemaresultvo)|

# CheckIn

## POST 签到

POST /api/users/sign-in

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|签到结果|[ResultVO](#schemaresultvo)|

## GET 签到记录

GET /api/users/sign-in/history

> 返回示例

> 200 Response

```json
{
  "records": [
    "2024-01-01",
    "2024-01-02"
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|签到日期列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» records|[string]|false|none||none|

# Video

## GET 视频列表

GET /api/videos

> 返回示例

> 200 Response

```json
{
  "videos": [
    {
      "id": 1,
      "title": "Platform Introduction",
      "thumbnail": "http://example.com/t1.jpg",
      "likes": 2,
      "coins": 2
    },
    {
      "id": 2,
      "title": "My first vlog",
      "thumbnail": "http://example.com/t2.jpg",
      "likes": 1,
      "coins": 0
    },
    {
      "id": 4,
      "title": "Tech Review 2024",
      "thumbnail": "http://example.com/t4.jpg",
      "likes": 1,
      "coins": 1
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|视频列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» videos|[[VideoCard](#schemavideocard)]|false|none||none|
|»» id|integer|true|none||none|
|»» title|string|true|none||none|
|»» thumbnail|string|true|none||none|
|»» likes|integer|true|none||none|
|»» coins|integer|true|none||none|

## GET 搜索视频

GET /api/videos/search

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|q|query|string| 是 |none|
|page|query|integer| 否 |none|

> 返回示例

> 200 Response

```json
{
  "videos": [
    {
      "id": 2,
      "title": "My first vlog",
      "thumbnail": "http://example.com/t2.jpg",
      "likes": 1,
      "coins": 0
    }
  ],
  "total_pages": 1
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|搜索结果|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» videos|[[VideoCard](#schemavideocard)]|false|none||none|
|»» id|integer|true|none||none|
|»» title|string|true|none||none|
|»» thumbnail|string|true|none||none|
|»» likes|integer|true|none||none|
|»» coins|integer|true|none||none|
|» total_pages|integer|false|none||none|

## GET 视频详情

GET /api/videos/{id}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer| 是 |none|

> 返回示例

> 200 Response

```json
{
  "id": 2,
  "description": "A day in my life",
  "src": "http://example.com/v2.mp4",
  "comments": [
    {
      "id": 2,
      "content": "Nice vlog!",
      "likes": 1,
      "parent_id": null
    },
    {
      "id": 3,
      "content": "Thanks!",
      "likes": 0,
      "parent_id": 2
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|视频详情|[VideoDetailResponse](#schemavideodetailresponse)|

## POST 发布视频

POST /api/videos/publish

> Body 请求参数

```json
{
  "title": "Cat compilation",
  "description": "Cute cats",
  "src": "/uploads/bd743e70-4b9a-4060-b9cf-50e2c81dac1a-Naraka-highlight-20260102-10-17-04.mp4",
  "thumbnail": "/uploads/6561240f-9eff-4909-a1d8-df3e16c44465-535.jpg"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[PublishVideoRequest](#schemapublishvideorequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|发布结果|[ResultVO](#schemaresultvo)|

## POST 上传视频

POST /api/videos/upload

> Body 请求参数

```yaml
video: file://C:\Users\fengz\Videos\NarakaBladepoint\Naraka-highlight-20260102-10-17-04.mp4
thumbnail:
  - file://C:\Users\fengz\Downloads\微信图片_2026-04-04_215057_044.jpg
  - file://C:\Users\fengz\Desktop\535.jpg

```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» video|body|string(binary)| 否 |none|
|» thumbnail|body|string(binary)| 否 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string",
  "video_url": "string",
  "thumbnail_url": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|上传结果|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» success|boolean|false|none||none|
|» msg|string|false|none||none|
|» video_url|string|false|none||none|
|» thumbnail_url|string|false|none||none|

# VideoLike

## POST 点赞视频

POST /api/videos/like

> Body 请求参数

```json
{
  "video_id": 1
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[VideoIdRequest](#schemavideoidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|点赞结果|[ResultVO](#schemaresultvo)|

## POST 取消点赞

POST /api/videos/unlike

> Body 请求参数

```json
{
  "video_id": 1
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[VideoIdRequest](#schemavideoidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|取消点赞结果|[ResultVO](#schemaresultvo)|

# VideoFavorites

## POST 收藏视频

POST /api/videos/favorite

> Body 请求参数

```json
{
  "video_id": 2
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[VideoIdRequest](#schemavideoidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|收藏结果|[ResultVO](#schemaresultvo)|

## POST 取消收藏

POST /api/videos/unfavorite

> Body 请求参数

```json
{
  "video_id": 2
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[VideoIdRequest](#schemavideoidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|取消收藏结果|[ResultVO](#schemaresultvo)|

## GET 收藏的视频

GET /api/videos/favorites

> 返回示例

> 200 Response

```json
{
  "videos": [
    {
      "id": 1,
      "title": "Platform Introduction",
      "thumbnail": "http://example.com/t1.jpg",
      "likes": 2,
      "coins": 2
    },
    {
      "id": 9,
      "title": "Cat compilation",
      "thumbnail": "http://example.com/t9.jpg",
      "likes": 1,
      "coins": 2
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|收藏列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» videos|[[VideoCard](#schemavideocard)]|false|none||none|
|»» id|integer|true|none||none|
|»» title|string|true|none||none|
|»» thumbnail|string|true|none||none|
|»» likes|integer|true|none||none|
|»» coins|integer|true|none||none|

# VideoHistory

## GET 历史浏览

GET /api/videos/history

> 返回示例

> 200 Response

```json
{
  "videos": [
    {
      "id": 1,
      "title": "Platform Introduction",
      "thumbnail": "http://example.com/t1.jpg",
      "likes": 2,
      "coins": 2
    },
    {
      "id": 4,
      "title": "Tech Review 2024",
      "thumbnail": "http://example.com/t4.jpg",
      "likes": 1,
      "coins": 1
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|历史浏览列表|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» videos|[[VideoCard](#schemavideocard)]|false|none||none|
|»» id|integer|true|none||none|
|»» title|string|true|none||none|
|»» thumbnail|string|true|none||none|
|»» likes|integer|true|none||none|
|»» coins|integer|true|none||none|

# VideoCoins

## POST 投币

POST /api/videos/coin

> Body 请求参数

```json
{
  "video_id": 1,
  "coins": 2
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[CoinRequest](#schemacoinrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|投币结果|[ResultVO](#schemaresultvo)|

# Comment

## POST 发表评论

POST /api/comments

> Body 请求参数

```json
{
  "video_id": 1,
  "content": "Great introduction!",
  "parent_id": 2
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[CreateCommentRequest](#schemacreatecommentrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|评论结果|[ResultVO](#schemaresultvo)|

## DELETE 删除评论

DELETE /api/comments/{id}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|删除结果|[ResultVO](#schemaresultvo)|

# CommentLikes

## POST 点赞评论

POST /api/comments/like

> Body 请求参数

```json
{
  "comment_id": 1
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[CommentIdRequest](#schemacommentidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|点赞评论结果|[ResultVO](#schemaresultvo)|

## POST 取消点赞评论

POST /api/comments/unlike

> Body 请求参数

```json
{
  "comment_id": 1
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[CommentIdRequest](#schemacommentidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|取消点赞评论结果|[ResultVO](#schemaresultvo)|

# Report

## POST 举报视频

POST /api/videos/report

> Body 请求参数

```json
{
  "video_id": 1,
  "reason": "anim amet mollit quis sunt"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» video_id|body|integer| 是 |none|
|» reason|body|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "success": true,
  "msg": "string"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|举报结果|[ResultVO](#schemaresultvo)|

# 数据模型

<h2 id="tocS_ResultVO">ResultVO</h2>

<a id="schemaresultvo"></a>
<a id="schema_ResultVO"></a>
<a id="tocSresultvo"></a>
<a id="tocsresultvo"></a>

```json
{
  "success": true,
  "msg": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|success|boolean|true|none||none|
|msg|string|false|none||none|

<h2 id="tocS_LoginResponse">LoginResponse</h2>

<a id="schemaloginresponse"></a>
<a id="schema_LoginResponse"></a>
<a id="tocSloginresponse"></a>
<a id="tocsloginresponse"></a>

```json
{
  "success": true,
  "token": "string"
}

```

### 属性

oneOf

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|*anonymous*|object|false|none||none|
|» success|boolean|true|none||none|
|» token|string|true|none||none|

xor

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|*anonymous*|object|false|none||none|
|» success|boolean|true|none||none|
|» msg|string|true|none||none|

#### 枚举值

|属性|值|
|---|---|
|success|true|
|success|false|

<h2 id="tocS_LoginRequest">LoginRequest</h2>

<a id="schemaloginrequest"></a>
<a id="schema_LoginRequest"></a>
<a id="tocSloginrequest"></a>
<a id="tocsloginrequest"></a>

```json
{
  "username": "string",
  "password": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|username|string|true|none||登录名|
|password|string|true|none||none|

<h2 id="tocS_RegisterRequest">RegisterRequest</h2>

<a id="schemaregisterrequest"></a>
<a id="schema_RegisterRequest"></a>
<a id="tocSregisterrequest"></a>
<a id="tocsregisterrequest"></a>

```json
{
  "username": "user@example.com",
  "password": "string",
  "nickname": "string",
  "bio": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|username|string(email)|true|none||登录名|
|password|string|true|none||none|
|nickname|string|true|none||用户名称|
|bio|string|true|none||none|

<h2 id="tocS_ChangePasswordRequest">ChangePasswordRequest</h2>

<a id="schemachangepasswordrequest"></a>
<a id="schema_ChangePasswordRequest"></a>
<a id="tocSchangepasswordrequest"></a>
<a id="tocschangepasswordrequest"></a>

```json
{
  "oldPassword": "string",
  "newPassword": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|oldPassword|string|true|none||none|
|newPassword|string|true|none||none|

<h2 id="tocS_DeleteAccountRequest">DeleteAccountRequest</h2>

<a id="schemadeleteaccountrequest"></a>
<a id="schema_DeleteAccountRequest"></a>
<a id="tocSdeleteaccountrequest"></a>
<a id="tocsdeleteaccountrequest"></a>

```json
{
  "password": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|password|string|true|none||none|

<h2 id="tocS_UpdateProfileRequest">UpdateProfileRequest</h2>

<a id="schemaupdateprofilerequest"></a>
<a id="schema_UpdateProfileRequest"></a>
<a id="tocSupdateprofilerequest"></a>
<a id="tocsupdateprofilerequest"></a>

```json
{
  "nickname": "string",
  "bio": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|nickname|string|false|none||用户名称|
|bio|string|false|none||none|

<h2 id="tocS_AdminUserItem">AdminUserItem</h2>

<a id="schemaadminuseritem"></a>
<a id="schema_AdminUserItem"></a>
<a id="tocSadminuseritem"></a>
<a id="tocsadminuseritem"></a>

```json
{
  "id": 0,
  "nickname": "string",
  "role": "active"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|id|integer|false|none||none|
|nickname|string|false|none||用户名称|
|role|string|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|role|active|
|role|ban|
|role|admin|

<h2 id="tocS_VideoCard">VideoCard</h2>

<a id="schemavideocard"></a>
<a id="schema_VideoCard"></a>
<a id="tocSvideocard"></a>
<a id="tocsvideocard"></a>

```json
{
  "id": 0,
  "title": "string",
  "thumbnail": "string",
  "likes": 0,
  "coins": 0
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|id|integer|true|none||none|
|title|string|true|none||none|
|thumbnail|string|true|none||none|
|likes|integer|true|none||none|
|coins|integer|true|none||none|

<h2 id="tocS_VideoDetailResponse">VideoDetailResponse</h2>

<a id="schemavideodetailresponse"></a>
<a id="schema_VideoDetailResponse"></a>
<a id="tocSvideodetailresponse"></a>
<a id="tocsvideodetailresponse"></a>

```json
{
  "id": 0,
  "description": "string",
  "src": "string",
  "uploader_id": 0,
  "is_liked": true,
  "is_favorited": true,
  "comments": [
    {
      "id": 0,
      "content": "string",
      "likes": 0,
      "parent_id": 0,
      "user_id": 0,
      "is_liked": true
    }
  ]
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|id|integer|true|none||none|
|description|string|true|none||none|
|src|string|true|none||none|
|uploader_id|integer|true|none||none|
|is_liked|boolean|true|none||none|
|is_favorited|boolean|true|none||none|
|comments|[object]|true|none||none|
|» id|integer|false|none||none|
|» content|string|false|none||none|
|» likes|integer|false|none||none|
|» parent_id|integer¦null|false|none||none|
|» user_id|integer|true|none||none|
|» is_liked|boolean|true|none||none|

<h2 id="tocS_PublishVideoRequest">PublishVideoRequest</h2>

<a id="schemapublishvideorequest"></a>
<a id="schema_PublishVideoRequest"></a>
<a id="tocSpublishvideorequest"></a>
<a id="tocspublishvideorequest"></a>

```json
{
  "title": "string",
  "description": "string",
  "src": "string",
  "thumbnail": "string"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|title|string|true|none||none|
|description|string|true|none||none|
|src|string|true|none||none|
|thumbnail|string|true|none||none|

<h2 id="tocS_UserMeResponse">UserMeResponse</h2>

<a id="schemausermeresponse"></a>
<a id="schema_UserMeResponse"></a>
<a id="tocSusermeresponse"></a>
<a id="tocsusermeresponse"></a>

```json
{
  "id": 0,
  "nickname": "string",
  "bio": "string",
  "likes": 0,
  "earn_coins": 0,
  "videos": [
    {
      "id": 0,
      "title": "string",
      "thumbnail": "string",
      "likes": 0,
      "earn_coins": 0
    }
  ]
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|id|integer|false|none||none|
|nickname|string|false|none||用户名称|
|bio|string|false|none||none|
|likes|integer|false|none||none|
|earn_coins|integer|false|none||none|
|videos|[object]|false|none||none|
|» id|integer|false|none||none|
|» title|string|false|none||none|
|» thumbnail|string|false|none||none|
|» likes|integer|false|none||none|
|» earn_coins|integer|false|none||none|

<h2 id="tocS_VideoIdRequest">VideoIdRequest</h2>

<a id="schemavideoidrequest"></a>
<a id="schema_VideoIdRequest"></a>
<a id="tocSvideoidrequest"></a>
<a id="tocsvideoidrequest"></a>

```json
{
  "video_id": 0
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|video_id|integer|true|none||none|

<h2 id="tocS_CoinRequest">CoinRequest</h2>

<a id="schemacoinrequest"></a>
<a id="schema_CoinRequest"></a>
<a id="tocScoinrequest"></a>
<a id="tocscoinrequest"></a>

```json
{
  "video_id": 0,
  "coins": 1
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|video_id|integer|true|none||none|
|coins|integer|true|none||none|

<h2 id="tocS_CreateCommentRequest">CreateCommentRequest</h2>

<a id="schemacreatecommentrequest"></a>
<a id="schema_CreateCommentRequest"></a>
<a id="tocScreatecommentrequest"></a>
<a id="tocscreatecommentrequest"></a>

```json
{
  "video_id": 0,
  "content": "string",
  "parent_id": 0
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|video_id|integer|true|none||none|
|content|string|true|none||none|
|parent_id|integer¦null|false|none||none|

<h2 id="tocS_CommentIdRequest">CommentIdRequest</h2>

<a id="schemacommentidrequest"></a>
<a id="schema_CommentIdRequest"></a>
<a id="tocScommentidrequest"></a>
<a id="tocscommentidrequest"></a>

```json
{
  "comment_id": 0
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|comment_id|integer|true|none||none|

