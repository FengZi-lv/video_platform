package org.example.dto;

public class HandleReportDTO extends UserPayloadDTO {
    private Integer report_id;
    private String action;
    private Integer video_id;

    public HandleReportDTO() {
    }

    public Integer getReport_id() {
        return report_id;
    }

    public void setReport_id(Integer report_id) {
        this.report_id = report_id;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public Integer getVideo_id() {
        return video_id;
    }

    public void setVideo_id(Integer id) {
        video_id = id;
    }
}

