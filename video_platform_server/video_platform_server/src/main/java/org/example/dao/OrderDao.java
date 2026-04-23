package org.example.dao;

import org.example.entity.Order;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class OrderDao extends BaseDao {

    public OrderDao() throws SQLException {
        super();
    }

    public OrderDao(Connection conn) {
        super(conn);
    }

    public int createOrder(Order order) throws SQLException {
        var sql = "INSERT INTO orders ( user_id, exhibition_id, session_id, ticket_type_id, count, total_amount, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, order.getUserId());
            stmt.setInt(2, order.getExhibitionId());
            stmt.setInt(3, order.getSessionId());
            stmt.setInt(4, order.getTicketTypeId());
            stmt.setInt(5, order.getCount());
            stmt.setDouble(6, order.getTotalAmount());
            return stmt.executeUpdate();
        }
    }

    public int updateOrderStatus(Integer orderNo, String status) throws SQLException {
        var sql = "UPDATE orders SET status = ? WHERE order_no = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, orderNo);
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

    public List<Order> getAllOrders() throws SQLException {
        List<Order> orders = new ArrayList<>();
        var sql = "SELECT * FROM orders ORDER BY create_time DESC";
        try (var stmt = conn.prepareStatement(sql);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                orders.add(new Order(
                    rs.getInt("order_no"),
                        rs.getInt("user_id"),
                        rs.getInt("exhibition_id"),
                        rs.getInt("session_id"),
                        rs.getInt("ticket_type_id"),
                        rs.getInt("count"),
                        rs.getDouble("total_amount"),
                        rs.getString("status"),
                        rs.getTimestamp("create_time"),
                        rs.getTimestamp("pay_time")
                ));
            }
        }
        return orders;
    }

    public Order getOrderById(Integer orderNo) throws SQLException {
        var sql = "SELECT * FROM orders WHERE order_no = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderNo);
            try (var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Order(
                            rs.getInt("order_no"),
                            rs.getInt("user_id"),
                            rs.getInt("exhibition_id"),
                            rs.getInt("session_id"),
                            rs.getInt("ticket_type_id"),
                            rs.getInt("count"),
                            rs.getDouble("total_amount"),
                            rs.getString("status"),
                            rs.getTimestamp("create_time"),
                            rs.getTimestamp("pay_time")
                    );

                }
            }
        }
        return null;
    }

}
