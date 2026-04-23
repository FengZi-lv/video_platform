package org.example.vo;

public class CommentVO extends ResultVO {
    private int id;
    private String content;
    private int likes;
    private Integer parentId;
    private String status;
    private Boolean is_liked;
    private Integer user_id;
    private String image_url;

    public CommentVO() {
    }

    public CommentVO(boolean success, String msg, int id, String content, int likes, Integer parentId, String status, Boolean is_liked, Integer user_id, String image_url) {
        super(success, msg);

        this.id = id;
        this.content = content;
        this.likes = likes;
        this.parentId = parentId;
        this.status = status;
        this.is_liked = is_liked;
        this.user_id = user_id;
        this.image_url = image_url;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getIs_liked() {
        return is_liked;
    }

    public void setIs_liked(Boolean is_liked) {
        this.is_liked = is_liked;
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }

    public String getImage_url() {
        return image_url;
    }

    public void setImage_url(String image_url) {
        this.image_url = image_url;
    }
}