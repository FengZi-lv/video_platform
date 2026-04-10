package org.example.vo;

public class CommentVO extends ResultVO {
    private int id;
    private String content;
    private int likes;
    private Integer parentId;
    private String status;
    private Boolean is_liked;

    public CommentVO() {
    }

    public CommentVO(boolean success, String msg, int id, String content, int likes, Integer parentId, String status) {
        super(success, msg);

        this.id = id;
        this.content = content;
        this.likes = likes;
        this.parentId = parentId;
        this.status = status;
        this.is_liked = false;
    }

    public CommentVO(boolean success, String msg, int id, String content, int likes, Integer parentId, String status, Boolean is_liked) {
        super(success, msg);

        this.id = id;
        this.content = content;
        this.likes = likes;
        this.parentId = parentId;
        this.status = status;
        this.is_liked = is_liked;
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
}