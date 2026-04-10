package org.example.vo;

import java.util.List;

public class VideoDetailVO extends ResultVO {
    private Integer id;
    private String description;
    private String src;
    private Integer uploader_id;
    private Boolean is_liked;
    private Boolean is_favorited;
    private List<CommentVO> comments;

    public VideoDetailVO() {
    }

    public VideoDetailVO(boolean success, String msg, Integer id, String description, String src,Integer uploader_id, Boolean is_liked, Boolean is_favorited, List<CommentVO> comments) {
        super(success, msg);

        this.id = id;
        this.description = description;
        this.src = src;
        this.uploader_id = uploader_id;
        this.is_liked = is_liked;
        this.is_favorited = is_favorited;
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

    public Integer getUploader_id() {
        return uploader_id;
    }

    public void setUploader_id(Integer uploader_id) {
        this.uploader_id = uploader_id;
    }

    public Boolean getIs_liked() {
        return is_liked;
    }

    public void setIs_liked(Boolean is_liked) {
        this.is_liked = is_liked;
    }

    public Boolean getIs_favorited() {
        return is_favorited;
    }

    public void setIs_favorited(Boolean is_favorited) {
        this.is_favorited = is_favorited;
    }
}