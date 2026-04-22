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
  "nickname": "新显示名称",
  "bio": "新个人简介",
  "avatar": "新头像URL"
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
  "avatar": "头像URL",
  "followers_count": 10,
  "following_count": 5,
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

# 关注服务 (FollowService)

## 关注用户

`POST /api/users/follow`

请求

```json
{
  "user_id": 2
}
```

返回

```json
{
  "success": true,
  "msg": "关注成功"
}
```

## 取消关注

`POST /api/users/unfollow`

请求

```json
{
  "user_id": 2
}
```

返回

```json
{
  "success": true,
  "msg": "取消关注成功"
}
```

## 查看关注列表

`GET /api/users/{id}/following`

返回

```json
{
  "users": [
    {
      "id": 2,
      "nickname": "用户名称",
      "avatar": "头像URL",
      "bio": "个人简介"
    }
  ]
}
```

## 查看粉丝列表

`GET /api/users/{id}/followers`

返回与关注列表相同。

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
  "parent_id": null,
  "image_url": "上传的照片URL，非必填"
}
```

返回

```json
{
  "success": true,
  "msg": "评论成功",
  "id": 1,
  "content": "评论内容",
  "image_url": "上传的照片URL",
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

## 上传图片（头像/评论图）

`POST /api/files/upload/image`

使用`multipart/form-data`上传数据

返回

```json
{
  "success": true,
  "image_url": "照片URL"
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
  "video_id": 1,
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

# 漫展演出系统 (ExhibitionService TicketService)

## 获取漫展演出列表

`GET /api/exhibitions`

- `page`: 页码
- `type`: 展览，演出，赛事，本地生活
- `time`: 全部时间，本周，本月

返回

```json
{
  "total": 100,
  "exhibitions": [
    {
      "id": 1,
      "title": "漫展名称",
      "cover": "封面URL",
      "address": "漫展地址",
      "type": "展览",
      "start_time": "2024-07-01",
      "end_time": "2024-07-05",
      "price_min": "100.00"
    }
  ]
}
```

## 漫展展览详情

`GET /api/exhibitions/{id}`

返回

```json
{
  "id": 1,
  "title": "漫展名称",
  "cover": "封面URL",
  "address": "漫展地址",
  "type": "展览",
  "phone": "联系电话",
  "description": "介绍详情",
  "sessions": [
    {
      "id": 1,
      "name": "首发日 7月1日",
      "time": "2024-07-01 09:00:00",
      "tickets": [
        {
          "id": 1,
          "type_name": "VIP票",
          "price": "299.00",
          "remain_count": 50
        },
        {
          "id": 2,
          "type_name": "普通票",
          "price": "99.00",
          "remain_count": 1000
        }
      ]
    }
  ]
}
```

## 用户购票

`POST /api/tickets/buy`

请求

```json
{
  "exhibition_id": 1,
  "session_id": 1,
  "ticket_type_id": 1,
  "count": 1
}
```

返回

```json
{
  "success": true,
  "msg": "下单成功",
  "order_id": "ORDER20240601xxxxx"
}
```

## 历史订单/退票查询

`GET /api/tickets/orders`

返回历史所有票务订单记录及状态。

## 用户退票

`POST /api/tickets/refund`

请求

```json
{
  "order_id": "ORDER20240601xxxxx"
}
```

返回

```json
{
  "success": true,
  "msg": "已申请退票，等待管理员同意"
}
```

## 管理端 - 发布漫展演出

`POST /api/admin/exhibitions`

请求

```json
{
  "title": "漫展名称",
  "cover": "封面URL",
  "address": "展会地址",
  "phone": "联系电话",
  "type": "演出",
  "sessions": [
    {
      "name": "第一场",
      "time": "2024-06-15",
      "tickets": [
        { "name": "VIP票", "price": "199", "quantity": 100 }
      ]
    }
  ]
}
```

## 管理端 - 修改漫展演出

`PUT /api/admin/exhibitions/{id}`

请求

```json
{
  "title": "漫展名称",
  "cover": "封面URL",
  "address": "展会地址",
  "phone": "联系电话",
  "type": "演出",
  "sessions": [
    {
      "name": "第一场",
      "time": "2024-06-15",
      "tickets": [
        { "name": "VIP票", "price": "199", "quantity": 100 }
      ]
    }
  ]
}
```

## 管理端 - 查看所有订单信息

`GET /api/admin/tickets/orders`

获取平台所有用户的订单，可附加筛选查询。

## 管理端 - 同意用户退票

`POST /api/admin/tickets/refund/handle`

请求

```json
{
  "order_id": "ORDER20240601xxxxx",
  "action": "approve" 
  // approve or reject
}
```

## 管理端 - 线下核销

`POST /api/admin/tickets/verify`

用户带电子票进行核销。

请求

```json
{
  "ticket_code": "用户的电子票核销码"
}
```

返回

```json
{
  "success": true,
  "session_name": "场次信息",
  "ticket_type": "门票种类"
}
```

## 管理端 - 数据统计

`GET /api/admin/exhibitions/{id}/stats`

返回

```json
{
  "total_revenue": "150000.00",
  "total_tickets_sold": 1000,
  "total_tickets_verified": 800,
  "sessions_stats": [
    {
      "session_id": 1,
      "session_name": "首日场",
      "revenue": "80000.00",
      "sold": 600,
      "verified": 400
    }
  ]
}
```