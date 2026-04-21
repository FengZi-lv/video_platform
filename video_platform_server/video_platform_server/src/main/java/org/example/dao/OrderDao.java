package org.example.dao;

import org.example.entity.Order;

import java.sql.SQLException;

public class OrderDao extends BaseDao {

    public OrderDao() throws SQLException {
        super();
    }

    public int createOrder(Order order) throws SQLException {
        var sql = "INSERT INTO orders (order_no, user_id, exhibition_id, session_id, ticket_type_id, count, total_amount, status, timeout_time) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, order.getOrderNo());
            stmt.setInt(2, order.getUserId());
            stmt.setInt(3, order.getExhibitionId());
            stmt.setInt(4, order.getSessionId());
            stmt.setInt(5, order.getTicketTypeId());
            stmt.setInt(6, order.getCount());
            stmt.setDouble(7, order.getTotalAmount());
            stmt.setTimestamp(8, order.getTimeoutTime());
            return stmt.executeUpdate();
        }
    }

    public int updateOrderStatus(String orderNo, String status) throws SQLException {
        var sql = "UPDATE orders SET status = ? WHERE order_no = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, orderNo);
            return stmt.executeUpdate();
        }
    }

    public int lockTicketInventoryForUpdate(int ticketTypeId, int count) throws SQLException {
        // 用数据库锁
        var sql = "UPDATE ticket_types SET remain_count = remain_count - ? WHERE id = ? AND remain_count >= ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, count);
            stmt.setInt(2, ticketTypeId);
            stmt.setInt(3, count);
            return stmt.executeUpdate();
        }
    }

    public int refundTicketInventory(int ticketTypeId, int count) throws SQLException {
        var sql = "UPDATE ticket_types SET remain_count = remain_count + ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, count);
            stmt.setInt(2, ticketTypeId);
            return stmt.executeUpdate();
        }
    }
}
