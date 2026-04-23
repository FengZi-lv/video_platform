package org.example.dao;

import org.example.entity.Exhibition;
import org.example.entity.ExhibitionSession;
import org.example.entity.ExhibitionStats;
import org.example.entity.TicketType;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;

public class ExhibitionDao extends BaseDao {

    public ExhibitionDao() throws SQLException {
        super();
    }

    public ExhibitionDao(Connection conn) {
        super(conn);
    }
    // 返回主键
    public int addExhibition(Exhibition exhibition) throws SQLException {
        var sql = "INSERT INTO exhibitions (title, cover, address, type, phone, description) VALUES (?, ?, ?, ?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, exhibition.getTitle());
            stmt.setString(2, exhibition.getCover());
            stmt.setString(3, exhibition.getAddress());
            stmt.setString(4, exhibition.getType());
            stmt.setString(5, exhibition.getPhone());
            stmt.setString(6, exhibition.getDescription());
            
            var affected = stmt.executeUpdate();
            if (affected > 0) {
                try (var rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
            return 0;
        }
    }

    public int updateExhibition(Exhibition exhibition) throws SQLException {
        var sql = "UPDATE exhibitions SET title=?, cover=?, address=?, type=?, phone=?, description=? WHERE id=?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, exhibition.getTitle());
            stmt.setString(2, exhibition.getCover());
            stmt.setString(3, exhibition.getAddress());
            stmt.setString(4, exhibition.getType());
            stmt.setString(5, exhibition.getPhone());
            stmt.setString(6, exhibition.getDescription());
            stmt.setInt(7, exhibition.getId());
            return stmt.executeUpdate();
        }
    }

    public int addSession(ExhibitionSession session) throws SQLException {
        var sql = "INSERT INTO exhibition_sessions (exhibition_id, session_name, session_time) VALUES (?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, session.getExhibitionId());
            stmt.setString(2, session.getSessionName());
            stmt.setTimestamp(3, session.getSessionTime());
            
            var affected = stmt.executeUpdate();
            if (affected > 0) {
                try (var rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
            return 0;
        }
    }

    public int addTicketType(TicketType ticketType) throws SQLException {
        var sql = "INSERT INTO ticket_types (session_id, type_name, price, quantity, remain_count) VALUES (?, ?, ?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketType.getSessionId());
            stmt.setString(2, ticketType.getTypeName());
            stmt.setDouble(3, ticketType.getPrice());
            stmt.setInt(4, ticketType.getQuantity());
            stmt.setInt(5, ticketType.getQuantity()); // initial remain == total
            return stmt.executeUpdate();
        }
    }

    public ExhibitionStats getStats(int exhibitionId) throws SQLException {
        // totalTickets: 统计该展会下所有场次的门票总发行量
        // oldTickets: 统计该展会下所有状态为paid的订单中购买门票数量之和
        // visitedTickets: 统计该展会下所有订单对应的门票中状态为used的记录总数
        // totalRevenue: 统计该展会下所有状态为 'paid' 的订单总支付金额
        String sql = "SELECT " +
                "    (SELECT SUM(tt.quantity) FROM ticket_types tt JOIN exhibition_sessions es ON tt.session_id = es.id WHERE es.exhibition_id = ?) as totalTickets, " +
                "    (SELECT IFNULL(SUM(o.count), 0) FROM orders o WHERE o.exhibition_id = ? AND o.status = 'paid') as soldTickets, " +
                "    (SELECT COUNT(t.id) FROM tickets t JOIN orders o ON t.order_no = o.order_no WHERE o.exhibition_id = ? AND t.status = 'used') as visitedTickets, " +
                "    (SELECT IFNULL(SUM(o.total_amount), 0) FROM orders o WHERE o.exhibition_id = ? AND o.status = 'paid') as totalRevenue";

        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exhibitionId);
            stmt.setInt(2, exhibitionId);
            stmt.setInt(3, exhibitionId);
            stmt.setInt(4, exhibitionId);

            try (ResultSet rs = stmt.executeQuery()) {

                if (rs.next()) {
                        return new ExhibitionStats(
                            exhibitionId,
                            rs.getInt("totalTickets"),
                            rs.getInt("soldTickets"),
                            rs.getInt("visitedTickets"),
                            rs.getDouble("totalRevenue")
                    );
                }
            }
        }
        return null;
    }
}
