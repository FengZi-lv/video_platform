package org.example.entity;

import java.sql.Timestamp;

public class Video {
    private Integer id;
    private Integer uploaderId;
    private String title;
    private String intro;
    private String status;
    private Integer likesCount;
    private Integer favoritesCount;
    private Integer coinsCount;
    private String videoUrl;
    private Timestamp createDate;
    private String thumbnailUrl;


    public Video(Integer id, Integer uploaderId, String title, String intro, String status, Integer likesCount, Integer favoritesCount, Integer coinsCount, String videoUrl, String thumbnailUrl, Timestamp createDate) {
        this.id = id;
        this.uploaderId = uploaderId;
        this.title = title;
        this.intro = intro;
        this.status = status;
        this.likesCount = likesCount;
        this.favoritesCount = favoritesCount;
        this.coinsCount = coinsCount;
        this.videoUrl = videoUrl;
        this.thumbnailUrl = thumbnailUrl;
        this.createDate = createDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUploaderId() {
        return uploaderId;
    }

    public void setUploaderId(Integer uploaderId) {
        this.uploaderId = uploaderId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getLikesCount() {
        return likesCount;
    }

    public void setLikesCount(Integer likesCount) {
        this.likesCount = likesCount;
    }

    public Integer getFavoritesCount() {
        return favoritesCount;
    }

    public void setFavoritesCount(Integer favoritesCount) {
        this.favoritesCount = favoritesCount;
    }

    public Integer getCoinsCount() {
        return coinsCount;
    }

    public void setCoinsCount(Integer coinsCount) {
        this.coinsCount = coinsCount;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }
}
