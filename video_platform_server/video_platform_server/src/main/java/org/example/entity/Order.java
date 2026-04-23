package org.example.entity;

import java.sql.Timestamp;

public class Order {
    private Integer orderNo;
    private Integer userId;
    private Integer exhibitionId;
    private Integer sessionId;
    private Integer ticketTypeId;
    private Integer count;
    private Double totalAmount;
    private String status;
    private Timestamp createTime;
    private Timestamp payTime;

    public Order() {}

    public Order(Integer orderNo, Integer userId, Integer exhibitionId, Integer sessionId, Integer ticketTypeId, Integer count, Double totalAmount, String status, Timestamp createTime, Timestamp payTime) {
        this.orderNo = orderNo;
        this.userId = userId;
        this.exhibitionId = exhibitionId;
        this.sessionId = sessionId;
        this.ticketTypeId = ticketTypeId;
        this.count = count;
        this.totalAmount = totalAmount;
        this.status = status;
        this.createTime = createTime;
        this.payTime = payTime;
    }

    public Integer getOrderNo() { return orderNo; }
    public void setOrderNo(Integer orderNo) { this.orderNo = orderNo; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getExhibitionId() { return exhibitionId; }
    public void setExhibitionId(Integer exhibitionId) { this.exhibitionId = exhibitionId; }

    public Integer getSessionId() { return sessionId; }
    public void setSessionId(Integer sessionId) { this.sessionId = sessionId; }

    public Integer getTicketTypeId() { return ticketTypeId; }
    public void setTicketTypeId(Integer ticketTypeId) { this.ticketTypeId = ticketTypeId; }

    public Integer getCount() { return count; }
    public void setCount(Integer count) { this.count = count; }

    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreateTime() { return createTime; }
    public void setCreateTime(Timestamp createTime) { this.createTime = createTime; }

    public Timestamp getPayTime() { return payTime; }
    public void setPayTime(Timestamp payTime) { this.payTime = payTime; }
}