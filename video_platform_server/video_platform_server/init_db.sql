CREATE DATABASE video_platform_db;
USE video_platform_db;

CREATE TABLE users
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(255)                   NOT NULL UNIQUE,
    password   VARCHAR(255)                   NOT NULL,
    nickname   VARCHAR(255)                   NOT NULL,
    avatar_url     VARCHAR(500)                   NULL,
    status     ENUM ('active', 'ban','admin') NOT NULL DEFAULT 'active',
    bio        TEXT                           NOT NULL,
    coins      INT                            NOT NULL DEFAULT 0,
    earn_coins INT                            NOT NULL DEFAULT 0,
    likes      INT                            NOT NULL DEFAULT 0,
    invalidate_tokens_before TIMESTAMP        NULL DEFAULT NULL,

    UNIQUE KEY (username)
);

CREATE TABLE check_in
(
    id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT  NOT NULL,
    date    DATE NOT NULL DEFAULT (CURRENT_DATE), -- 无法直接使用函数

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, date)                    -- 防止重复签到
);



CREATE TABLE videos
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    uploader_id     INT          NOT NULL,
    title           VARCHAR(500) NOT NULL,
    intro           TEXT         NOT NULL,
    status          ENUM ('reviewing','reject','pass') DEFAULT 'reviewing',
    likes_count     INT          NOT NULL              DEFAULT 0,
    favorites_count INT          NOT NULL              DEFAULT 0,
    earn_coins      INT          NOT NULL              DEFAULT 0,
    video_url       VARCHAR(500) NOT NULL,
    create_date     TIMESTAMP                          DEFAULT CURRENT_TIMESTAMP(),
    thumbnail_url   VARCHAR(500) NOT NULL,

    FOREIGN KEY (uploader_id) REFERENCES users (id) ON DELETE CASCADE

);

CREATE TABLE video_like
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT       NOT NULL,
    video_id    INT       NOT NULL,
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE,

    UNIQUE KEY (user_id, video_id) -- 防止重复
);

CREATE TABLE video_favorites
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT       NOT NULL,
    video_id    INT       NOT NULL,
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, video_id) -- 防止重复
);

CREATE TABLE video_history
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT       NOT NULL,
    video_id        INT       NOT NULL,
    last_watch_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),-- ON UPDATE CURRENT_TIMESTAMP(),

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, video_id)                                 -- 防止重复
);

CREATE TABLE video_earn_coins
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NULL,
    video_id    INT NOT NULL,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    count       INT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL, -- 用户注销后不会删除投币
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE
);

CREATE TABLE comments
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT                 NULL,
    video_id    INT                 NOT NULL,
    status      ENUM ('del','none') NOT NULL DEFAULT 'none',        -- 设置为del即为删除，不影响下一个评论
    create_date TIMESTAMP                    DEFAULT CURRENT_TIMESTAMP(),
    likes       INT                 NOT NULL DEFAULT 0,

    parent_id   INT,
    context     TEXT                NOT NULL,
    image_url   VARCHAR(500)        NULL,                           -- 评论上传的照片

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL, -- 注销用户后无法查看id，但还可以看到评论
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE
);



CREATE TABLE comment_likes
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    comment_id INT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE,

    UNIQUE KEY (user_id, comment_id) -- 防重复
);

CREATE TABLE reports
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT                                NULL,
    video_id    INT                                NOT NULL,
    context     TEXT                               NOT NULL,
    status      ENUM ('reviewing','pass','reject') NOT NULL DEFAULT 'reviewing',
    create_date TIMESTAMP                          NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL, -- 注销用户后无法查看id，但还可以看到举报
    FOREIGN KEY (video_id) REFERENCES videos (id) ON DELETE CASCADE
);

CREATE TABLE user_follows
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    follower_id  INT NOT NULL,
    following_id INT NOT NULL,
    create_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),

    FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users (id) ON DELETE CASCADE,
    UNIQUE KEY (follower_id, following_id) -- 防止重复关注
);



CREATE TABLE exhibitions
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    cover       VARCHAR(500) NOT NULL,
    address     VARCHAR(500) NOT NULL,
    type        ENUM('展览', '演出', '赛事', '本地生活') NOT NULL,
    phone       VARCHAR(20),
    description TEXT,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE exhibition_sessions
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    exhibition_id INT NOT NULL,
    session_name  VARCHAR(100) NOT NULL,
    session_time  TIMESTAMP NOT NULL,
    FOREIGN KEY (exhibition_id) REFERENCES exhibitions (id) ON DELETE CASCADE
);

CREATE TABLE ticket_types
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    session_id   INT NOT NULL,
    type_name    VARCHAR(100) NOT NULL,
    price        DECIMAL(10, 2) NOT NULL,
    quantity     INT NOT NULL,
    remain_count INT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES exhibition_sessions (id) ON DELETE CASCADE,
    CHECK (remain_count >= 0) -- 防止超卖
);

CREATE TABLE orders
(
    order_no       VARCHAR(64) PRIMARY KEY,
    user_id        INT NOT NULL,
    exhibition_id  INT NOT NULL,
    session_id     INT NOT NULL,
    ticket_type_id INT NOT NULL,
    count          INT NOT NULL,
    total_amount   DECIMAL(10, 2) NOT NULL,
    status         ENUM('pending', 'paid', 'cancelled', 'refund_pending', 'refunded') DEFAULT 'pending',
    create_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    pay_time       TIMESTAMP NULL,

    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (exhibition_id) REFERENCES exhibitions (id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES exhibition_sessions (id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_type_id) REFERENCES ticket_types (id) ON DELETE CASCADE
);

CREATE TABLE tickets
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    order_no       VARCHAR(64) NOT NULL,
    user_id        INT NOT NULL,
    ticket_code    VARCHAR(100) NOT NULL UNIQUE,
    status         ENUM('valid', 'used', 'refunded') DEFAULT 'valid',
    verify_time    TIMESTAMP NULL,

    FOREIGN KEY (order_no) REFERENCES orders (order_no) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);


