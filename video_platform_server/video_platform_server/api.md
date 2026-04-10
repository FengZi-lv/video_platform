# 认证服务 (AuthService)

每次身份验证请求带上Bearer JWT，未登录即带上`Bearer guest`
`username` 表示登录名，`nickname` 表示用户名称。

## 登录

`POST /api/auth/login`

请求

```json
{
  "username": "登录名",
  "password": "密码"
}
```

返回

```json
{
  "success": true,
  "token": "JWT",
}
```

```json
{
  "success": false,
  "msg": "登录失败，用户名或密码错误"
}
```

## 注册

`POST /api/auth/register`

请求

```json
{
  "username": "111@qqqq.com",
  "password": "密码",
  "nickname": "显示名称",
  "bio": "个人简介"
}
```

返回

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

## 修改密码

`POST /api/auth/change-password`

请求

```json
{
  "oldPassword": "旧密码",
  "newPassword": "新密码"
}
```

返回

```json
{
  "success": true,
  "msg": "修改密码成功"
}
```

```json
{
  "success": false,
  "msg": "修改密码失败，旧密码错误"
}
```

## 注销账号

`POST /api/auth/delete-account`

请求

```json
{
  "password": "密码"
}
```

返回

```json
{
  "success": true,
  "msg": "注销账号成功"
}
```

```json
{
  "success": false,
  "msg": "注销账号失败"
}
```

# 用户服务 (UserService)

## 修改个人信息

`POST /api/users/profile`
请求

```json
{
  "nickname": "新显示名称"
}
```

```json
{
  "bio": "新个人简介"
}
```

返回

```json
{
  "success": true,
  "msg": "修改个人信息成功"
}
```

```json
{
  "success": false,
  "msg": "修改个人信息失败"
}
```

## 用户信息

`GET /api/users/{id}`

直接传入相应目标用户的id

返回

```json
{
  "id": 1,
  "nickname": "用户名称",
  "bio": "个人简介",
  "likes": 100,
  "earn_coins": 100,
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "earn_coins": 50
    }
  ]
}
```

## 查看所有用户

`GET /api/admin/users`

返回

```json
{
  "users": [
    {
      "id": 1,
      "nickname": "用户名称",
      "role": "user"
      // admin , banned
    }
  ]
}
```

## 封禁账号

`POST /api/admin/users/ban`

请求

```json
{
  "user_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "封禁账号成功"
}
```

```json
{
  "success": false,
  "msg": "封禁账号失败"
}
```

# 签到服务 (CheckInService)

## 签到

`POST /api/users/sign-in`

返回

```json
{
  "success": true,
  "msg": "签到成功，获得10个硬币"
}
```

```json
{
  "success": false,
  "msg": "签到失败，今天已经签到过了"
}
```

## 签到记录

`GET /api/users/sign-in/history`

返回

```json
{
  "records": [
    "2024-06-01"
  ]
}
```

# 视频服务 (VideoService)

## 视频列表

`GET /api/videos`

返回

```json
{
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "coins": 50
    }
  ]
}
```

## 搜索视频

`GET /api/videos/search?q=关键字&page=页码`

返回

```json
{
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "coins": 50
    }
  ],
  "total_pages": 10
}
```

## 视频详情

`GET /api/videos/{id}`

返回

```json
{
  "id": 1,
  "description": "视频描述",
  "src": "视频URL",
  "uploader_id": 1,
  "is_liked": true,
  "is_favorited": false,
  "comments": [
    {
      "id": 1,
      "content": "评论内容",
      "likes": 10,
      "parent_id": null,
      "is_liked": true,
      "user_id": 2
    },
    {
      "id": 2,
      "content": "回复内容",
      "likes": 5,
      "parent_id": 1,
      "is_liked": false,
      "user_id": 3
    }
  ]
}
```

## 发布视频

`POST /api/videos/publish`

请求

```json
{
  "title": "视频标题",
  "description": "视频描述",
  "src": "视频URL",
  "thumbnail": "缩略图URL"
}
```

## 上传视频

`POST /api/videos/upload`

使用`multipart/form-data`上传数据

返回

```json
{
  "success": true,
  "msg": "上传视频成功",
  "video_url": "视频URL",
  "thumbnail_url": "缩略图URL"
}
```

```json
{
  "success": false,
  "msg": "上传视频失败"
}
```

## 播放视频流

`GET /api/video/play?name=xxxx.mp4`


## 获取视频缩略图

`GET /api/video/thumbnail?name=xx.jpg`


## 查看审核视频

`GET /api/admin/videos/pending`

返回

```json
{
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "earn_coins": 50
    }
  ]
}
```

## 审核视频

`POST /api/admin/videos/review`

请求

```json
{
  "video_id": 1,
  "action": "approve"
  // approve or reject
}
```

返回

```json
{
  "success": true,
  "msg": "审核成功"
}
```

```json
{
  "success": false,
  "msg": "审核失败"
}
```

# 视频点赞服务 (VideoLikeService)

## 点赞视频

`POST /api/videos/like`

请求

```json
{
  "video_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "点赞成功"
}
```

```json
{
  "success": false,
  "msg": "已点赞过"
}
```

## 取消点赞

`POST /api/videos/unlike`

请求

```json
{
  "video_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "取消点赞成功"
}
```

```json
{
  "success": false,
  "msg": "未点赞过"
}
```

# 视频收藏服务 (VideoFavoritesService)

## 收藏视频

`POST /api/videos/favorite`

请求

```json
{
  "video_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "收藏成功"
}
```

```json
{
  "success": false,
  "msg": "已收藏过"
}
```

## 取消收藏

`POST /api/videos/unfavorite`

请求

```json
{
  "video_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "取消收藏成功"
}
```

```json
{
  "success": false,
  "msg": "未收藏过"
}
```

## 收藏的视频

`GET /api/videos/favorites`

返回

```json
{
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "coins": 50
    }
  ]
}
```

# 视频历史服务 (VideoHistoryService)

## 历史浏览

`GET /api/videos/history`

返回

```json
{
  "videos": [
    {
      "id": 1,
      "title": "视频标题",
      "thumbnail": "缩略图URL",
      "likes": 100,
      "coins": 50
    }
  ]
}
```

# 视频投币服务 (VideoCoinsService)

## 投币

`POST /api/videos/coin`

请求

```json
{
  "video_id": 1,
  "coins": 2
}
```

返回

```json
{
  "success": true,
  "msg": "投币成功"
}
```

```json
{
  "success": false,
  "msg": "投币失败，硬币不足"
}
```

# 评论服务 (CommentService)

## 发表评论

`POST /api/comments`

请求

```json
{
  "video_id": 1,
  "content": "评论内容",
  "parent_id": null
}
```

返回

```json
{
  "success": true,
  "msg": "评论成功",
  "id": 1,
  "content": "评论内容",
  "likes": 0,
  "parentId": null,
  "status": "true",
  "is_liked": false,
  "user_id": 2
}
```

## 删除评论

`DELETE /api/comments/{id}`

返回

```json
{
  "success": true,
  "msg": "删除评论成功"
}
```

```json
{
  "success": false,
  "msg": "删除评论失败"
}
```

# 评论点赞服务 (CommentLikesService)

## 点赞评论

`POST /api/comments/like`

请求

```json
{
  "comment_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "点赞评论成功"
}
```

```json
{
  "success": false,
  "msg": "已点赞过"
}
```

## 取消点赞评论

`POST /api/comments/unlike`

请求

```json
{
  "comment_id": 1
}
```

返回

```json
{
  "success": true,
  "msg": "取消点赞评论成功"
}
```

```json
{
  "success": false,
  "msg": "未点赞过"
}
```

# 举报服务 (ReportService)

## 举报视频

`POST /api/videos/report`

请求

```json
{
  "video_id": 1,
  "reason": "举报理由"
}
```

返回

```json
{
  "success": true,
  "msg": "举报成功"
}
```

```json
{
  "success": false,
  "msg": "举报失败，已举报过"
}
```

## 查看举报列表

`GET /api/admin/reports`

返回

```json
{
  "reports": [
    {
      "id": 1,
      "video_id": 1,
      "reason": "举报理由",
      "reporter": "举报者昵称",
      "status": "pending"
    }
  ]
}
```

## 处理举报

`POST /api/admin/reports/handle`

请求

```json
{
  "report_id": 1,
  "action": "approve"
  // approve or reject or reviewing
}
```

返回

```json
{
  "success": true,
  "msg": "处理举报成功"
}
```

```json
{
  "success": false,
  "msg": "处理举报失败"
}
```