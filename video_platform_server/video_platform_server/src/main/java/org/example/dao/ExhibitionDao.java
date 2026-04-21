package org.example.dao;

import org.example.entity.Exhibition;
import org.example.entity.ExhibitionSession;
import org.example.entity.TicketType;

import java.sql.SQLException;

public class ExhibitionDao extends BaseDao {

    public ExhibitionDao() throws SQLException {
        super();
    }

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
}
