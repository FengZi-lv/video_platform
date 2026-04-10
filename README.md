# Video Platform

`video_platform_flutter`为前端页面，使用`flutter build web --base-href /video_platform_server_war_exploded/`即可编译为静态页面

目前`video_platform_server\video_platform_server\src\main\webapp`已部署为编译后的静态页面



`video_platform_server`为后端服务

服务默认运行在`http://localhost:8080/video_platform_server_war_exploded`

接口可以在`api.md`中查看定义

- 可以在 [Zephyr 在 Apifox 邀请你加入项目 video_platform（7天有效）](https://app.apifox.com/invite/project?token=eRXinh4OFgXbnf2Zmv84h) 中测试接口
- 或者是查看[在线文档](https://s.apifox.cn/229a5b78-df62-41ac-bc0f-8107bcfa136f)


#### 运行前需要先进行如下操作：

- 视频上传路径需要更改`src\main\java\org\example\util\Config.java`中的`RES_BASE_PATH`
- 数据库连接需要更改`src\main\java\org\example\util\Config.java`中的`USERNAME`和`PASSWORD`
- 数据库初始化需要执行`init.sql`中的SQL语句
- 使用`mock_data.sql`中的SQL语句向数据库中插入一些测试数据，或者是插入一个管理员账号以便于测试