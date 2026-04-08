package org.example.dto;

public class VideoActionDTO extends UserPayloadDTO {
    private Integer video_id;

    public VideoActionDTO() {
        super(null, null, null, null, null);
    }

    public VideoActionDTO(Integer video_id) {
        super(null, null, null, null, null);
        this.video_id = video_id;
    }

    public Integer getVideo_id() {
        return video_id;
    }

    public void setVideo_id(Integer video_id) {
        this.video_id = video_id;
    }
}