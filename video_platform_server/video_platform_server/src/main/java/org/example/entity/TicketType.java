package org.example.entity;

public class TicketType {
    private Integer id;
    private Integer sessionId;
    private String typeName;
    private Double price;
    private Integer quantity;
    private Integer remainCount;

    public TicketType() {}

    public TicketType(Integer id, Integer sessionId, String typeName, Double price, Integer quantity, Integer remainCount) {
        this.id = id;
        this.sessionId = sessionId;
        this.typeName = typeName;
        this.price = price;
        this.quantity = quantity;
        this.remainCount = remainCount;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getSessionId() { return sessionId; }
    public void setSessionId(Integer sessionId) { this.sessionId = sessionId; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Integer getRemainCount() { return remainCount; }
    public void setRemainCount(Integer remainCount) { this.remainCount = remainCount; }
}