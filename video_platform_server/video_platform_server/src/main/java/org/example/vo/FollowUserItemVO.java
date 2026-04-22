package org.example.vo;

public class FollowUserItemVO {
    private Integer id;
    private String nickname;
    private String avatar;
    private String bio;

    public FollowUserItemVO() {
    }

    public FollowUserItemVO(Integer id, String nickname, String avatar, String bio) {
        this.id = id;
        this.nickname = nickname;
        this.avatar = avatar;
        this.bio = bio;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }
}
