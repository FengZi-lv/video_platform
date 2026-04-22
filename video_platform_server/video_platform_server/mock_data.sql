USE video_platform_db;

-- --------------------------------------------------------
-- 1. 插入用户数据 (Users)
-- 密码统一使用: AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko
-- --------------------------------------------------------
INSERT INTO users (id, username, password, nickname, avatar_url, status, bio, coins, earn_coins, likes)
VALUES (1, 'admin', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '超级管理员', 'https://example.com/avatar/admin.png',
        'admin', '我是管理员，负责维护平台秩序。', 9999, 0, 0),
       (2, 'alice_gamer', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'AliceGaming',
        'https://example.com/avatar/alice.png', 'active', '永劫无间重度爱好者', 500, 120, 45),
       (3, 'bob_smith', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Bob', 'https://example.com/avatar/bob.png',
        'active', '随缘更新，佛系玩家。', 150, 30, 12),
       (4, 'bad_user', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', '违规用户', NULL, 'ban', '被封禁的测试账号', 0, 0,
        0);

-- --------------------------------------------------------
-- 2. 插入签到数据 (Check_in)
-- --------------------------------------------------------
INSERT INTO check_in (user_id, date)
VALUES (2, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)),
       (2, CURRENT_DATE),
       (3, CURRENT_DATE);

-- --------------------------------------------------------
-- 3. 插入视频数据 (Videos)
-- URL和缩略图使用指定值
-- --------------------------------------------------------
INSERT INTO videos (id, uploader_id, title, intro, status, likes_count, favorites_count, earn_coins, video_url,
                    thumbnail_url)
VALUES (1, 2, '【永劫无间】迦南天秀单排集锦', '今天打出的一些高光操作，希望大家喜欢！', 'pass', 10, 5, 2,
        '/b9f14c8f-d990-4c70-a722-eb0503b69b6b-Naraka-highlight-20260102-10-17-04.mp4',
        '/7b5bcd67-f20f-4e9e-b233-7eb9fb40dba4-63904778535297.png'),
       (2, 3, '宁红夜连招教学', '新手向，简单易学的连招。', 'pass', 25, 12, 5,
        '/b9f14c8f-d990-4c70-a722-eb0503b69b6b-Naraka-highlight-20260102-10-17-04.mp4',
        '/7b5bcd67-f20f-4e9e-b233-7eb9fb40dba4-63904778535297.png'),
       (3, 2, '新赛季上分实录', '正在审核中的视频测试。', 'reviewing', 0, 0, 0,
        '/b9f14c8f-d990-4c70-a722-eb0503b69b6b-Naraka-highlight-20260102-10-17-04.mp4',
        '/7b5bcd67-f20f-4e9e-b233-7eb9fb40dba4-63904778535297.png'),
       (4, 4, '违规测试视频', '涉嫌违规的内容，已被拒绝。', 'reject', 0, 0, 0,
        '/b9f14c8f-d990-4c70-a722-eb0503b69b6b-Naraka-highlight-20260102-10-17-04.mp4',
        '/7b5bcd67-f20f-4e9e-b233-7eb9fb40dba4-63904778535297.png');

-- --------------------------------------------------------
-- 4. 插入点赞、收藏、历史记录、投币
-- --------------------------------------------------------
INSERT INTO video_like (user_id, video_id)
VALUES (1, 1),
       (3, 1),
       (1, 2),
       (2, 2);

INSERT INTO video_favorites (user_id, video_id)
VALUES (3, 1),
       (1, 2);

INSERT INTO video_history (user_id, video_id)
VALUES (1, 1),
       (3, 1),
       (2, 2),
       (1, 2),
       (1, 3);

INSERT INTO video_earn_coins (user_id, video_id, count)
VALUES (3, 1, 2),
       (1, 2, 5);

-- --------------------------------------------------------
-- 5. 插入评论及评论点赞
-- --------------------------------------------------------
INSERT INTO comments (id, user_id, video_id, status, likes, parent_id, context, image_url)
VALUES (1, 3, 1, 'none', 5, NULL, '太强了博主！求出教学！', NULL),
       (2, 2, 1, 'none', 2, 1, '感谢支持，下期就出。', NULL),
       (3, 1, 2, 'none', 10, NULL, '讲得很详细，适合新手。', NULL),
       (4, 4, 1, 'del', 0, NULL, '这条评论被删除了。', NULL);

INSERT INTO comment_likes (user_id, comment_id)
VALUES (1, 1),
       (2, 1),
       (3, 2),
       (2, 3);

-- --------------------------------------------------------
-- 6. 插入举报 (Reports)
-- --------------------------------------------------------
INSERT INTO reports (user_id, video_id, context, status)
VALUES (1, 4, '包含不适宜内容', 'pass'),
       (3, 3, '视频画质太模糊，疑似搬运', 'reviewing');

-- --------------------------------------------------------
-- 7. 插入用户关注 (User Follows)
-- --------------------------------------------------------
INSERT INTO user_follows (follower_id, following_id)
VALUES (3, 2), -- Bob 关注了 Alice
       (1, 2);
-- Admin 关注了 Alice

-- --------------------------------------------------------
-- 8. 插入展会票务相关系统数据
-- --------------------------------------------------------
-- 8.1 展会信息 (Exhibitions)
INSERT INTO exhibitions (id, title, cover, address, type, phone, description)
VALUES (1, '11111111', 'https://example.com/cover1.jpg', '上海市浦东新区梅赛德斯奔驰文化中心',
        '赛事', '400-123-4567', '年度电竞盛会，顶尖高手对决。'),
       (2, '国风二次元漫展', 'https://example.com/cover2.jpg', '广州市保利世贸博览馆', '展览', '020-88888888',
        '集结各大Coser与同人创作者的狂欢节。');

-- 8.2 场次信息 (Exhibition Sessions)
INSERT INTO exhibition_sessions (id, exhibition_id, session_name, session_time)
VALUES (1, 1, '总决赛 DAY 1', '2026-11-15 14:00:00'),
       (2, 1, '总决赛 DAY 2', '2026-11-16 14:00:00'),
       (3, 2, '全天通票场', '2026-05-01 09:00:00');

-- 8.3 票种信息 (Ticket Types)
INSERT INTO ticket_types (id, session_id, type_name, price, quantity, remain_count)
VALUES (1, 1, '内场VIP票', 888.00, 200, 199),
       (2, 1, '看台普通票', 388.00, 1000, 1000),
       (3, 3, '早鸟票', 68.00, 500, 0), -- 模拟售罄
       (4, 3, '现场正价票', 98.00, 2000, 1500);

-- 8.4 订单信息 (Orders)
INSERT INTO orders (order_no, user_id, exhibition_id, session_id, ticket_type_id, count, total_amount, status, pay_time)
VALUES ('ORDER2026042210001', 2, 1, 1, 1, 1, 888.00, 'paid', CURRENT_TIMESTAMP()),
       ('ORDER2026042210002', 3, 2, 3, 3, 2, 136.00, 'cancelled', NULL),
       ('ORDER2026042210003', 1, 2, 3, 4, 1, 98.00, 'pending', NULL);

-- 8.5 实体/电子票据 (Tickets)
-- 只为已支付(paid)的订单生成实体票据
INSERT INTO tickets (id, order_no, user_id, ticket_code, status, verify_time)
VALUES (1, 'ORDER2026042210001', 2, 'TICKET-NB2026-XYZ987', 'valid', NULL);