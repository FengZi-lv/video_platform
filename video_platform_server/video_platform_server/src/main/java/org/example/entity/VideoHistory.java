package org.example.entity;

import java.sql.Timestamp;

public class VideoHistory {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private Timestamp lastWatchDate;

    public VideoHistory(Integer id, Integer userId, Integer videoId, Timestamp lastWatchDate) {
        this.id = id;
        this.userId = userId;
        this.videoId = videoId;
        this.lastWatchDate = lastWatchDate;
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

    public Timestamp getLastWatchDate() {
        return lastWatchDate;
    }

    public void setLastWatchDate(Timestamp lastWatchDate) {
        this.lastWatchDate = lastWatchDate;
    }
}
