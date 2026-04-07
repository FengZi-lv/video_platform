CREATE DATABASE video_platform_db;
USE video_platform_db;

CREATE TABLE users
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(255)                   NOT NULL UNIQUE,
    password   VARCHAR(255)                   NOT NULL,
    nickname   VARCHAR(255)                   NOT NULL,
    status     ENUM ('active', 'ban','admin') NOT NULL DEFAULT 'active',
    bio        TEXT                           NOT NULL,
    coins      INT                            NOT NULL DEFAULT 0,
    earn_coins INT                            NOT NULL DEFAULT 0,
    likes      INT                            NOT NULL DEFAULT 0,

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

    parent_id   INT,
    context     TEXT                NOT NULL,

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


