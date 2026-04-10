USE video_platform_db;

-- 1. 清理旧数据（可选，视情况执行）
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE comment_likes; TRUNCATE TABLE comments; TRUNCATE TABLE reports;
-- TRUNCATE TABLE video_earn_coins; TRUNCATE TABLE video_history; TRUNCATE TABLE video_favorites;
-- TRUNCATE TABLE video_like; TRUNCATE TABLE videos; TRUNCATE TABLE check_in; TRUNCATE TABLE users;
-- SET FOREIGN_KEY_CHECKS = 1;

-- 2. 批量插入用户 (不同角色和状态)
INSERT INTO users (username, password, nickname, status, bio, coins, earn_coins, likes) VALUES
                                                                                            ('tech_master@gmail.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '极客张三', 'active', '分享最新的科技资讯', 1000, 500, 200),
                                                                                            ('travel_vlog@163.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '环球小李', 'active', '带你看遍世界', 200, 1000, 450),
                                                                                            ('foodie_queen@outlook.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '美食达人阿珍', 'active', '唯有美食不可辜负', 50, 20, 15),
                                                                                            ('silent_watcher@qq.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '路人甲', 'active', '这个人很懒，什么都没留下', 10, 0, 0),
                                                                                            ('bad_user@spam.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '违规搬运工', 'ban', '账号已被封禁', 0, 0, 0),
                                                                                            ('system_mod@video.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '内容审核员01', 'admin', '负责维护社区环境', 9999, 0, 0);

-- 3. 批量插入视频 (复用 1.mp4, 2.mp4, 3.mp4)
INSERT INTO videos (uploader_id, title, intro, status, likes_count, favorites_count, earn_coins, video_url, thumbnail_url) VALUES
                                                                                                                               (1, '2024年最强显卡测评', '深度解析性能参数。', 'pass', 150, 45, 120, '1.mp4', '1.jpg'),
                                                                                                                               (1, '如何组装一台工作站', '从零开始的装机教程。', 'pass', 80, 20, 50, '2.mp4', '2.jpg'),
                                                                                                                               (2, '冰岛极光之旅', '极地美景实拍，震撼心灵。', 'pass', 300, 120, 400, '3.mp4', '3.jpg'),
                                                                                                                               (2, '京都的雨季', '漫步在古城小巷。', 'pass', 120, 30, 90, '1.mp4', '1.jpg'),
                                                                                                                               (3, '秘制红烧肉教程', '家常菜也能做出饭店味。', 'pass', 45, 15, 10, '2.mp4', '2.jpg'),
                                                                                                                               (3, '三分钟学会煎牛排', '新手必看系列。', 'pass', 20, 5, 2, '3.mp4', '3.jpg'),
                                                                                                                               (5, '搬运：火爆全网的短片', '未经许可的转载内容。', 'reject', 0, 0, 0, '1.mp4', '1.jpg'),
                                                                                                                               (1, '新项目预告', '下周将开启全新挑战。', 'reviewing', 0, 0, 0, '2.mp4', '2.jpg');

-- 4. 签到数据
INSERT INTO check_in (user_id, date) VALUES
                                         (1, '2024-03-20'), (1, '2024-03-21'), (2, '2024-03-21'), (3, '2024-03-21'), (4, '2024-03-21');

-- 5. 视频互动 (点赞、收藏、投币、历史)
-- 点赞
INSERT INTO video_like (user_id, video_id) VALUES (2, 1), (3, 1), (4, 1), (1, 3), (4, 3);
-- 收藏
INSERT INTO video_favorites (user_id, video_id) VALUES (4, 1), (4, 3), (2, 1);
-- 历史记录
INSERT INTO video_history (user_id, video_id) VALUES (4, 1), (4, 2), (4, 3), (1, 3), (2, 5);
-- 投币记录 (用户投给视频)
INSERT INTO video_earn_coins (user_id, video_id, count) VALUES (1, 3, 5), (4, 1, 2), (2, 1, 10);

-- 6. 评论系统 (包含父子评论)
-- 视频1的评论
INSERT INTO comments (user_id, video_id, status, likes, parent_id, context) VALUES
                                                                                (2, 1, 'none', 15, NULL, '测评很专业，已经下单了。'),
                                                                                (1, 1, 'none', 5, 1, '感谢支持，记得分享使用体验哦！'),
                                                                                (4, 1, 'none', 0, NULL, '求问这款显卡的功耗是多少？'),
-- 视频3的评论
                                                                                (3, 3, 'none', 50, NULL, '景色太美了，简直是人间仙境。'),
                                                                                (4, 3, 'none', 2, 4, '同意！我也想去这里旅游。');

-- 7. 评论点赞
INSERT INTO comment_likes (user_id, comment_id) VALUES (1, 1), (4, 1), (2, 4);

-- 8. 举报数据
INSERT INTO reports (user_id, video_id, context, status) VALUES
                                                             (1, 7, '此视频疑似侵权搬运，请核实。', 'pass'),
                                                             (4, 5, '简介里有错别字。', 'reject'),
                                                             (2, 8, '等待审核中...', 'reviewing');