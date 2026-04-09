package org.example.vo;

public class ReportVO {
    private int id;
    private int video_id;
    private String reason;
    private String reporter;
    private String status;

    public ReportVO(int id, int video_id, String reason, String reporter, String status) {
        this.id = id;
        this.video_id = video_id;
        this.reason = reason;
        this.reporter = reporter;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getVideo_id() {
        return video_id;
    }

    public void setVideo_id(int video_id) {
        this.video_id = video_id;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getReporter() {
        return reporter;
    }

    public void setReporter(String reporter) {
        this.reporter = reporter;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
