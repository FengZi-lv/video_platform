USE video_platform_db;

INSERT INTO users (id, username, password, nickname, status, bio, coins, earn_coins) VALUES
(1, 'admin@test.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Administrator', 'admin', 'I am the admin.', 9999, 0),
(2, 'banned@test.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'BadGuy', 'ban', 'I broke the rules.', 0, 0),
(3, 'user1@test.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Alice', 'active', 'Hello, I am Alice.', 100, 50),
(4, 'user2@test.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Bob', 'active', 'Tech enthusiast.', 50, 10),
(5, 'user3@test.com', 'AR4fHuQgPbWbNiU0rs5CNXGCzcPb60KbU53PIIqapko', 'Charlie', 'active', 'Love peace.', 200, 150);

INSERT INTO videos (id, uploader_id, title, intro, status, likes_count, favorites_count, earn_coins, video_url, thumbnail_url) VALUES
(1, 1, 'Platform Introduction', 'Welcome to our platform', 'pass', 2, 1, 2, 'http://example.com/v1.mp4', 'http://example.com/t1.jpg'),
(2, 3, 'My first vlog', 'A day in my life', 'pass', 1, 1, 0, 'http://example.com/v2.mp4', 'http://example.com/t2.jpg'),
(3, 3, 'Cooking tutorial', 'How to make a cake', 'pass', 0, 0, 0, 'http://example.com/v3.mp4', 'http://example.com/t3.jpg'),
(4, 4, 'Tech Review 2024', 'Reviewing latest gadgets', 'pass', 1, 0, 1, 'http://example.com/v4.mp4', 'http://example.com/t4.jpg'),
(5, 5, 'Travel to Japan', 'Amazing trip', 'pass', 0, 1, 0, 'http://example.com/v5.mp4', 'http://example.com/t5.jpg'),
(6, 1, 'Site Rules', 'Please read these rules', 'pass', 0, 0, 0, 'http://example.com/v6.mp4', 'http://example.com/t6.jpg'),
(7, 4, 'Unboxing new phone', 'It looks great', 'reviewing', 0, 0, 0, 'http://example.com/v7.mp4', 'http://example.com/t7.jpg'),
(8, 2, 'Spam video', 'Buy my stuff', 'reject', 0, 0, 0, 'http://example.com/v8.mp4', 'http://example.com/t8.jpg'),
(9, 3, 'Cat compilation', 'Cute cats', 'pass', 1, 1, 2, 'http://example.com/v9.mp4', 'http://example.com/t9.jpg'),
(10, 5, 'Piano cover', 'Classical music', 'pass', 1, 0, 0, 'http://example.com/v10.mp4', 'http://example.com/t10.jpg'),
(11, 4, 'Programming in Java', 'Java basics', 'pass', 0, 0, 0, 'http://example.com/v11.mp4', 'http://example.com/t11.jpg'),
(12, 3, 'Workout routine', 'Stay fit', 'pass', 0, 0, 0, 'http://example.com/v12.mp4', 'http://example.com/t12.jpg'),
(13, 5, 'Daily news', 'What happened today', 'reviewing', 0, 0, 0, 'http://example.com/v13.mp4', 'http://example.com/t13.jpg'),
(14, 1, 'Future Updates', 'What to expect', 'pass', 0, 0, 0, 'http://example.com/v14.mp4', 'http://example.com/t14.jpg'),
(15, 4, 'Gaming stream highlights', 'Epic moments', 'pass', 0, 0, 0, 'http://example.com/v15.mp4', 'http://example.com/t15.jpg'),
(16, 3, 'Painting tutorial', 'Bob Ross style', 'pass', 0, 0, 0, 'http://example.com/v16.mp4', 'http://example.com/t16.jpg'),
(17, 5, 'History of Rome', 'Documentary', 'pass', 0, 0, 0, 'http://example.com/v17.mp4', 'http://example.com/t17.jpg'),
(18, 4, 'How to build a PC', 'Step by step', 'pass', 0, 0, 0, 'http://example.com/v18.mp4', 'http://example.com/t18.jpg'),
(19, 3, 'Funny jokes', 'Laugh together', 'pass', 0, 0, 0, 'http://example.com/v19.mp4', 'http://example.com/t19.jpg'),
(20, 2, 'Another spam', 'Click here', 'reject', 0, 0, 0, 'http://example.com/v20.mp4', 'http://example.com/t20.jpg');

INSERT INTO check_in (user_id, date) VALUES
(1, '2024-01-01'), (3, '2024-01-01'), (4, '2024-01-01'), (5, '2024-01-02');

INSERT INTO video_like (user_id, video_id) VALUES
(3, 1), (4, 1), (5, 2), (3, 4), (1, 9), (4, 10);

INSERT INTO video_favorites (user_id, video_id) VALUES
(3, 1), (5, 2), (1, 5), (4, 9);

INSERT INTO video_history (user_id, video_id) VALUES
(3, 1), (4, 1), (5, 2), (3, 4), (1, 5), (4, 9), (5, 10);

INSERT INTO video_earn_coins (user_id, video_id, count) VALUES
(3, 1, 2), (4, 4, 1), (5, 9, 2);

INSERT INTO comments (id, user_id, video_id, status, parent_id, context) VALUES
(1, 4, 1, 'none', NULL, 'Great introduction!'),
(2, 5, 2, 'none', NULL, 'Nice vlog!'),
(3, 3, 2, 'none', 2, 'Thanks!'),
(4, 1, 4, 'none', NULL, 'Very informative.'),
(5, 2, 9, 'del', NULL, 'Some toxic comment');

INSERT INTO comment_likes (user_id, comment_id) VALUES
(1, 1), (3, 1), (4, 2);

INSERT INTO reports (user_id, video_id, context, status) VALUES
(3, 8, 'Spam content', 'pass'),
(4, 20, 'Also spam', 'reviewing');
