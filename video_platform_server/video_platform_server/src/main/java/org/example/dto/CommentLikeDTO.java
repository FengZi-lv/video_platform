package org.example.dto;

public class CommentLikeDTO extends UserPayloadDTO {
    private Integer comment_id;

    public CommentLikeDTO() {
    }

    public Integer getComment_id() {
        return comment_id;
    }

    public void setComment_id(Integer comment_id) {
        this.comment_id = comment_id;
    }
}

