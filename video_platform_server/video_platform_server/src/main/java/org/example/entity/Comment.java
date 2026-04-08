package org.example.entity;

import java.sql.Timestamp;

public class Comment {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private String status;
    private Timestamp createDate;
    private Integer parentId;
    private String context;
    private Integer likes;


    public Comment(Integer id, Integer userId, Integer likes, Integer videoId, String status, Timestamp createDate, Integer parentId, String context) {
        this.id = id;
        this.userId = userId;
        this.likes = likes;
        this.videoId = videoId;
        this.status = status;
        this.createDate = createDate;
        this.parentId = parentId;
        this.context = context;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getContext() {
        return context;
    }

    public void setContext(String context) {
        this.context = context;
    }

    public Integer getLikes() {
        return likes;
    }

    public void setLikes() {
        this.likes = likes;
    }
}
