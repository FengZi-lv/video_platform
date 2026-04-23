package org.example.vo;


import java.util.List;

public class UserInfoVO extends ResultVO {
    private Integer id;
    private String nickname;
    private String bio;
    private Integer likes;
    private Integer earn_coins;
    private String status;
    private boolean is_followed;
    private List<VideoVO> videos;

    public UserInfoVO() {
    }

    public UserInfoVO(boolean success, String msg, Integer id, String nickname, String bio, Integer likes, Integer earn_coins, String status, boolean is_followed, List<VideoVO> videos) {
        super(success, msg);
        this.id = id;
        this.nickname = nickname;
        this.bio = bio;
        this.likes = likes;
        this.earn_coins = earn_coins;
        this.status = status;
        this.is_followed = is_followed;
        this.videos = videos;
    }

    public Integer getId() {
        return id;
    }

    public String getNickname() {
        return nickname;
    }

    public String getBio() {
        return bio;
    }

    public Integer getLikes() {
        return likes;
    }

    public Integer getEarn_coins() {
        return earn_coins;
    }

    public List<VideoVO> getVideos() {
        return videos;
    }

    public String getStatus() {
        return status;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public void setLikes(Integer likes) {
        this.likes = likes;
    }

    public void setEarn_coins(Integer earn_coins) {
        this.earn_coins = earn_coins;
    }

    public void setVideos(List<VideoVO> videos) {
        this.videos = videos;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isIs_followed() {
        return is_followed;
    }

    public void setIs_followed(boolean is_followed) {
        this.is_followed = is_followed;
    }
}
