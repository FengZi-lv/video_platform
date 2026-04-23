package org.example.vo;

import org.example.entity.Order;
import java.util.List;

public class OrderListVO extends ResultVO {
    private List<Order> orders;

    public OrderListVO() {}

    public OrderListVO(boolean success, String msg, List<Order> orders) {
        super(success, msg);
        this.orders = orders;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public void setOrders(List<Order> orders) {
        this.orders = orders;
    }
}
