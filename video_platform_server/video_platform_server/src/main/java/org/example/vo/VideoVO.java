package org.example.vo;

public class VideoVO extends ResultVO {

    private int id;
    private String title;
    private String thumbnail;
    private int likes;
    private int earn_coins;


    public VideoVO() {
    }

    public VideoVO(boolean success, String msg, int id, String title, String thumbnail, int likes, int earn_coins) {
        super(success, msg);
        this.id = id;
        this.title = title;
        this.thumbnail = thumbnail;
        this.likes = likes;
        this.earn_coins = earn_coins;
    }

    public int getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getThumbnail() {
        return thumbnail;
    }

    public int getLikes() {
        return likes;
    }

    public int getEarn_coins() {
        return earn_coins;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setThumbnail(String thumbnail) {
        this.thumbnail = thumbnail;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public void setEarn_coins(int earn_coins) {
        this.earn_coins = earn_coins;
    }
}
