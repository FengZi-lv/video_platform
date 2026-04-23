package org.example.dto;

public class RefundTicketDTO extends UserPayloadDTO {
    private Integer order_id;

    public RefundTicketDTO() {}

    public Integer getOrder_id() {
        return order_id;
    }

    public void setOrder_id(Integer order_id) {
        this.order_id = order_id;
    }
}
