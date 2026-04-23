package org.example.dao;

import org.example.entity.Ticket;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;

public class TicketDao extends BaseDao {

    public TicketDao() throws SQLException {
        super();
    }

    public TicketDao(Connection conn) {
        super(conn);
    }

    public int createTicket(Ticket ticket) throws SQLException {
        var sql = "INSERT INTO tickets (order_no, user_id, ticket_code, status) VALUES (?, ?, ?, 'valid')";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticket.getOrderNo());
            stmt.setInt(2, ticket.getUserId());
            stmt.setString(3, ticket.getTicketCode());
            return stmt.executeUpdate();
        }
    }

    public int verifyTicket(String ticketCode) throws SQLException {
        // 核销
        var sql = "UPDATE tickets SET status = 'used', verify_time = ? WHERE ticket_code = ? AND status = 'valid'";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            stmt.setString(2, ticketCode);
            return stmt.executeUpdate();
        }
    }

    public int refundTicket(Integer orderNo) throws SQLException {
        var sql = "UPDATE tickets SET status = 'refunded' WHERE order_no = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderNo);
            return stmt.executeUpdate();
        }
    }
}
