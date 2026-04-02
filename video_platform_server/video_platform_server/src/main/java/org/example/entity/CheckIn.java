package org.example.entity;

import java.sql.Date;

public class CheckIn {
    private Integer id;
    private Integer userId;
    private Date date;

    public CheckIn(Integer id, Integer userId, Date date) {
        this.id = id;
        this.userId = userId;
        this.date = date;
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

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
