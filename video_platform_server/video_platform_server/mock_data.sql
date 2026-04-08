USE video_platform_db;

-- --------------------------------------------------------
-- 1. 插入用户数据 (Users)
-- 包含一个管理员，三个正常活跃用户，以及一个被封禁的用户
-- --------------------------------------------------------
INSERT INTO users (username, password, nickname, status, bio, coins, earn_coins, likes) VALUES
                                                                                            ('admin01', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '超级管理员', 'admin', '我是这个平台的管理员。', 9999, 5000, 1000),
                                                                                            ('alice_vlog', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Alice的生活', 'active', '分享日常Vlog和美食。', 500, 120, 350),
                                                                                            ('tech_bob', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '极客Bob', 'active', '硬核科技产品评测。', 800, 450, 890),
                                                                                            ('gamer_carol', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Carol玩游戏', 'active', '单机游戏实况主。', 150, 30, 80),
                                                                                            ('bad_guy', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '违规用户', 'ban', '发广告的。', 0, 0, 0);

-- --------------------------------------------------------
-- 2. 插入签到数据 (Check_in)
-- 模拟过去几天的签到记录
-- --------------------------------------------------------
INSERT INTO check_in (user_id, date) VALUES
                                         (2, DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY)),
                                         (2, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)),
                                         (2, CURRENT_DATE),
                                         (3, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)),
                                         (3, CURRENT_DATE),
                                         (4, CURRENT_DATE);

-- --------------------------------------------------------
-- 3. 插入视频数据 (Videos)
-- 包含已通过、审核中和被拒绝的视频
-- --------------------------------------------------------
INSERT INTO videos (uploader_id, title, intro, status, likes_count, favorites_count, earn_coins, video_url, thumbnail_url) VALUES
                                                                                                                               (2, '我的周末Vlog：探索城市隐藏咖啡馆', '和大家分享我这周末发现的宝藏咖啡厅！环境超级棒！', 'pass', 2, 1, 2, 'https://example.com/video1.mp4', 'https://example.com/thumb1.jpg'),
                                                                                                                               (3, '2024最新旗舰手机横评', '花了半个月时间做的硬核评测，希望能帮到大家。', 'pass', 1, 1, 5, 'https://example.com/video2.mp4', 'https://example.com/thumb2.jpg'),
                                                                                                                               (4, '只狼 完美无伤BOSS战合集', '太肝了，求三连！', 'reviewing', 0, 0, 0, 'https://example.com/video3.mp4', 'https://example.com/thumb3.jpg'),
                                                                                                                               (5, '点击链接领取免费皮肤!!!', '不要错过这个免费拿皮肤的机会！', 'reject', 0, 0, 0, 'https://example.com/video4.mp4', 'https://example.com/thumb4.jpg');

-- --------------------------------------------------------
-- 4. 插入视频点赞数据 (Video_like)
-- 对应视频表的 likes_count (注意：此处数据应该与视频表的统计相符，模拟业务逻辑已更新状态)
-- --------------------------------------------------------
INSERT INTO video_like (user_id, video_id) VALUES
                                               (3, 1), -- Bob点赞了Alice的Vlog
                                               (4, 1), -- Carol点赞了Alice的Vlog
                                               (2, 2); -- Alice点赞了Bob的评测

-- --------------------------------------------------------
-- 5. 插入视频收藏数据 (Video_favorites)
-- --------------------------------------------------------
INSERT INTO video_favorites (user_id, video_id) VALUES
                                                    (4, 1), -- Carol收藏了Alice的Vlog
                                                    (1, 2); -- 管理员收藏了Bob的评测

-- --------------------------------------------------------
-- 6. 插入历史观看记录 (Video_history)
-- --------------------------------------------------------
INSERT INTO video_history (user_id, video_id) VALUES
                                                  (3, 1),
                                                  (4, 1),
                                                  (2, 2),
                                                  (1, 4); -- 管理员观看了违规视频进行审核

-- --------------------------------------------------------
-- 7. 插入投币数据 (Video_earn_coins)
-- --------------------------------------------------------
INSERT INTO video_earn_coins (user_id, video_id, count) VALUES
                                                            (3, 1, 2), -- Bob给Alice投了2个币
                                                            (2, 2, 2), -- Alice给Bob投了2个币
                                                            (4, 2, 3); -- Carol给Bob投了3个币

-- --------------------------------------------------------
-- 8. 插入评论数据 (Comments)
-- 包含父子评论(楼层)和已删除的评论
-- --------------------------------------------------------
INSERT INTO comments (user_id, video_id, status, likes, parent_id, context) VALUES
                                                                                (3, 1, 'none', 1, NULL, '咖啡厅看起来好棒，求地址！'),           -- id: 1
                                                                                (2, 1, 'none', 0, 1, '在中山路那边，改天我把详细地址私发你哈~'), -- id: 2 (回复上一条)
                                                                                (4, 2, 'none', 2, NULL, '评测得很详细，打算入手了！'),         -- id: 3
                                                                                (5, 1, 'del', 0, NULL, '加微信带你赚钱...');                   -- id: 4 (垃圾评论，状态为已删除)

-- --------------------------------------------------------
-- 9. 插入评论点赞数据 (Comment_likes)
-- --------------------------------------------------------
INSERT INTO comment_likes (user_id, comment_id) VALUES
                                                    (2, 1), -- Alice点赞了Bob的评论
                                                    (3, 3), -- Bob点赞了Carol的评论
                                                    (2, 3); -- Alice点赞了Carol的评论

-- --------------------------------------------------------
-- 10. 插入举报记录 (Reports)
-- --------------------------------------------------------
INSERT INTO reports (user_id, video_id, context, status) VALUES
                                                             (2, 4, '这个视频是个骗局链接，请处理。', 'pass'),
                                                             (3, 4, '广告引流，涉嫌诈骗。', 'reviewing');