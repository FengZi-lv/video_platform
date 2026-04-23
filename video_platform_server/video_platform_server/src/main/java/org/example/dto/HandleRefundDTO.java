package org.example.dto;

public class HandleRefundDTO extends UserPayloadDTO {
    private Integer order_id;
    private String action; // "approve" or "reject"

    public HandleRefundDTO() {}

    public Integer getOrder_id() { return order_id; }
    public void setOrder_id(Integer order_id) { this.order_id = order_id; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
}
