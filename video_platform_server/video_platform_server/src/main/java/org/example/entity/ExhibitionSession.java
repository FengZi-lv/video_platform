package org.example.entity;

import java.sql.Timestamp;

public class ExhibitionSession {
    private Integer id;
    private Integer exhibitionId;
    private String sessionName;
    private Timestamp sessionTime;

    public ExhibitionSession() {}

    public ExhibitionSession(Integer id, Integer exhibitionId, String sessionName, Timestamp sessionTime) {
        this.id = id;
        this.exhibitionId = exhibitionId;
        this.sessionName = sessionName;
        this.sessionTime = sessionTime;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getExhibitionId() { return exhibitionId; }
    public void setExhibitionId(Integer exhibitionId) { this.exhibitionId = exhibitionId; }

    public String getSessionName() { return sessionName; }
    public void setSessionName(String sessionName) { this.sessionName = sessionName; }

    public Timestamp getSessionTime() { return sessionTime; }
    public void setSessionTime(Timestamp sessionTime) { this.sessionTime = sessionTime; }
}