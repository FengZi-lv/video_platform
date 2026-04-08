package org.example.dto;

public class ReportVideoDTO extends UserPayloadDTO {
    private Integer video_id;
    private String reason;

    public ReportVideoDTO() {
        super(null, null, null, null, null);
    }

    public ReportVideoDTO(Integer video_id, String reason) {
        super(null, null, null, null, null);
        this.video_id = video_id;
        this.reason = reason;
    }

    public Integer getVideo_id() {
        return video_id;
    }

    public void setVideo_id(Integer video_id) {
        this.video_id = video_id;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}