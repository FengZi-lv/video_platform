package org.example.entity;

import java.sql.Timestamp;

public class Report {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private String context;
    private String status;
    private Timestamp createDate;
    private String reporterName;


    public Report(Integer id, Integer userId, Integer videoId, String context, String status, Timestamp createDate, String reporterName) {
        this.id = id;
        this.userId = userId;
        this.videoId = videoId;
        this.context = context;
        this.status = status;
        this.createDate = createDate;
        this.reporterName = reporterName;
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

    public Integer getVideoId() {
        return videoId;
    }

    public void setVideoId(Integer videoId) {
        this.videoId = videoId;
    }

    public String getContext() {
        return context;
    }

    public void setContext(String context) {
        this.context = context;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public String getReporterName() {
        return reporterName;
    }

    public void setReporterName(String reporterName) {
        this.reporterName = reporterName;
    }
}
