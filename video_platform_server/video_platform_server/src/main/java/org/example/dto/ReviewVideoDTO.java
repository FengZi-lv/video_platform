package org.example.dto;

public class ReviewVideoDTO extends UserPayloadDTO {
    private Integer video_id;
    private String action;

    public ReviewVideoDTO() {
    }

    public Integer getVideo_id() {
        return video_id;
    }

    public void setVideo_id(Integer video_id) {
        this.video_id = video_id;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }
}

