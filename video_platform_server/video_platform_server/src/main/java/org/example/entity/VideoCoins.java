package org.example.entity;

import java.sql.Timestamp;

public class VideoCoins {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private Timestamp createDate;
    private Integer count;

    public VideoCoins(Integer id, Integer userId, Integer videoId, Timestamp createDate, Integer count) {
        this.id = id;
        this.userId = userId;
        this.videoId = videoId;
        this.createDate = createDate;
        this.count = count;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getVideoId() {
        return videoId;
    }

    public void setVideoId(Integer videoId) {
        this.videoId = videoId;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }
}
