package org.example.entity;

public class CommentLikes {
    private Integer id;
    private Integer userId;
    private Integer commentId;


    public CommentLikes(Integer id, Integer userId, Integer commentId) {
        this.id = id;
        this.userId = userId;
        this.commentId = commentId;
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

    public Integer getCommentId() {
        return commentId;
    }

    public void setCommentId(Integer commentId) {
        this.commentId = commentId;
    }
}
