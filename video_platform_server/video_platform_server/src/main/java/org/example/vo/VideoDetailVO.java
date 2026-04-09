package org.example.vo;

import java.util.List;

public class VideoDetailVO extends ResultVO {
    private Integer id;
    private String description;
    private String src;
    private List<CommentVO> comments;

    public VideoDetailVO() {
    }

    public VideoDetailVO(boolean success, String msg, Integer id, String description, String src, List<CommentVO> comments) {
        super(success, msg);

        this.id = id;
        this.description = description;
        this.src = src;
        this.comments = comments;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSrc() {
        return src;
    }

    public void setSrc(String src) {
        this.src = src;
    }

    public List<CommentVO> getComments() {
        return comments;
    }

    public void setComments(List<CommentVO> comments) {
        this.comments = comments;
    }
}