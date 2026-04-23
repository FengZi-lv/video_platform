package org.example.entity;

import java.sql.Timestamp;

public class Ticket {
    private Integer id;
    private Integer orderNo;
    private Integer userId;
    private String ticketCode;
    private String status;
    private Timestamp verifyTime;

    public Ticket() {}

    public Ticket(Integer id, Integer orderNo, Integer userId, String ticketCode, String status, Timestamp verifyTime) {
        this.id = id;
        this.orderNo = orderNo;
        this.userId = userId;
        this.ticketCode = ticketCode;
        this.status = status;
        this.verifyTime = verifyTime;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrderNo() { return orderNo; }
    public void setOrderNo(Integer orderNo) { this.orderNo = orderNo; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getTicketCode() { return ticketCode; }
    public void setTicketCode(String ticketCode) { this.ticketCode = ticketCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getVerifyTime() { return verifyTime; }
    public void setVerifyTime(Timestamp verifyTime) { this.verifyTime = verifyTime; }
}