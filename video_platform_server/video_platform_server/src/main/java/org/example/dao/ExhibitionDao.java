package org.example.dao;

import org.example.entity.Exhibition;
import org.example.entity.ExhibitionSession;
import org.example.entity.TicketType;
import org.example.entity.Video;
import org.example.vo.ExhibitionStatsVO;
import org.example.vo.ExhibitionVO;
import org.example.vo.ExhibitionsListVO;
import org.example.vo.SessionStatVO;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

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
        try (var stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, exhibition.getTitle());
            stmt.setString(2, exhibition.getCover());
            stmt.setString(3, exhibition.getAddress());
            stmt.setString(4, exhibition.getType());
            stmt.setString(5, exhibition.getPhone());
            stmt.setString(6, exhibition.getDescription());

            var affected = stmt.executeUpdate();
            if (affected > 0) {
                try (var rs = stmt.getGeneratedKeys()) {
                    if (rs.next())
                        return rs.getInt(1);
                }
            }
            return 0;
        }
    }

    public List<Video> getAllExhibitions(String title, int offset) throws Exception {
        var sql = "SELECT * FROM exhibitions WHERE status = 'pass' AND title LIKE ? LIMIT 10 OFFSET ?";
        var videos = new ArrayList<Video>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + title + "%");
            stmt.setInt(2, offset);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(new Video(
                            rs.getInt("id"),
                            rs.getInt("uploader_id"),
                            rs.getString("title"),
                            rs.getString("intro"),
                            "pass",
                            rs.getInt("likes_count"),
                            rs.getInt("favorites_count"),
                            rs.getInt("earn_coins"),
                            rs.getString("video_url"),
                            rs.getString("thumbnail_url"),
                            rs.getTimestamp("create_date")));
                }
                return videos;
            }
        }
    }

    public ExhibitionsListVO getExhibitionsList(String type, String time, int offset) throws Exception {
        StringBuilder countSql = new StringBuilder("SELECT COUNT(*) FROM exhibitions e WHERE 1=1");
        StringBuilder dataSql = new StringBuilder(
                "SELECT " +
                        "    e.id, e.title, e.cover, e.address, e.type," +
                        "    (SELECT MIN(session_time) FROM exhibition_sessions WHERE exhibition_id = e.id) as start_time,"
                        +
                        "    (SELECT MAX(session_time) FROM exhibition_sessions WHERE exhibition_id = e.id) as end_time,"
                        +
                        "    (SELECT MIN(price) FROM ticket_types tt JOIN exhibition_sessions ts ON tt.session_id = ts.id WHERE ts.exhibition_id = e.id) as price_min "
                        +
                        "FROM exhibitions e WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (type != null && !type.isEmpty() && !type.equals("全部")) {
            countSql.append(" AND e.type = ?");
            dataSql.append(" AND e.type = ?");
            params.add(type);
        }

        if ("本周".equals(time)) {
            String timeCond = " AND EXISTS (SELECT 1 FROM exhibition_sessions s WHERE s.exhibition_id = e.id AND YEARWEEK(s.session_time, 1) = YEARWEEK(CURDATE(), 1))";
            countSql.append(timeCond);
            dataSql.append(timeCond);
        } else if ("本月".equals(time)) {
            String timeCond = " AND EXISTS (SELECT 1 FROM exhibition_sessions s WHERE s.exhibition_id = e.id AND DATE_FORMAT(s.session_time, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m'))";
            countSql.append(timeCond);
            dataSql.append(timeCond);
        }

        dataSql.append(" LIMIT 10 OFFSET ?");

        int total = 0;
        try (var stmt = conn.prepareStatement(countSql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (var rs = stmt.executeQuery()) {
                if (rs.next())
                    total = rs.getInt(1);
            }
        }

        List<ExhibitionVO> exhibitions = new ArrayList<>();
        try (var stmt = conn.prepareStatement(dataSql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            stmt.setInt(params.size() + 1, offset);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ExhibitionVO vo = new ExhibitionVO(
                            rs.getInt("id"),
                            rs.getString("title"),
                            rs.getString("cover"),
                            rs.getString("address"),
                            rs.getString("type"),
                            null,
                            null,
                            rs.getString("price_min"));

                    Timestamp start = rs.getTimestamp("start_time");
                    if (start != null)
                        vo.setStart_time(start.toString().substring(0, 10));
                    Timestamp end = rs.getTimestamp("end_time");
                    if (end != null)
                        vo.setEnd_time(end.toString().substring(0, 10));
                    double priceMin = rs.getDouble("price_min");
                    if (!rs.wasNull())
                        vo.setPrice_min(String.format("%.2f", priceMin));
                    exhibitions.add(vo);
                }
            }
        }
        return new ExhibitionsListVO(true, "获取成功", total, exhibitions);
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

    public Exhibition getExhibitionById(int id) throws SQLException {
        var sql = "SELECT * FROM exhibitions WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Exhibition(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("cover"),
                        rs.getString("address"),
                        rs.getString("type"),
                        rs.getString("phone"),
                        rs.getString("description"),
                        rs.getTimestamp("create_date")
                    );
                }
            }
        }
        return null;
    }

    public List<ExhibitionSession> getSessionsByExhibitionId(int exhibitionId) throws SQLException {
        var sql = "SELECT * FROM exhibition_sessions WHERE exhibition_id = ?";
        List<ExhibitionSession> list = new ArrayList<>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exhibitionId);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new ExhibitionSession(
                        rs.getInt("id"),
                        rs.getInt("exhibition_id"),
                        rs.getString("session_name"),
                        rs.getTimestamp("session_time")
                    ));
                }
            }
        }
        return list;
    }

    public List<TicketType> getTicketTypesBySessionId(int sessionId) throws SQLException {
        var sql = "SELECT * FROM ticket_types WHERE session_id = ?";
        List<TicketType> list = new ArrayList<>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, sessionId);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new TicketType(
                        rs.getInt("id"),
                        rs.getInt("session_id"),
                        rs.getString("type_name"),
                        rs.getDouble("price"),
                        rs.getInt("quantity"),
                        rs.getInt("remain_count")
                    ));
                }
            }
        }
        return list;
    }

    public int addSession(ExhibitionSession session) throws SQLException {
        var sql = "INSERT INTO exhibition_sessions (exhibition_id, session_name, session_time) VALUES (?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, session.getExhibitionId());
            stmt.setString(2, session.getSessionName());
            stmt.setTimestamp(3, session.getSessionTime());

            var affected = stmt.executeUpdate();
            if (affected > 0) {
                try (var rs = stmt.getGeneratedKeys()) {
                    if (rs.next())
                        return rs.getInt(1);
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

    public ExhibitionStatsVO getStats(int exhibitionId) throws SQLException {
        String totalSql = "SELECT " +
                "IFNULL(SUM(total_amount), 0) AS total_revenue, " +
                "IFNULL(SUM(count), 0) AS total_tickets_sold, " +
                "(SELECT COUNT(*) FROM tickets t JOIN orders o ON t.order_no = o.order_no " +
                "WHERE o.status = 'paid' AND t.status = 'used') AS total_tickets_verified " +
                "FROM orders WHERE status = 'paid'";
        // 获取总计数据
        var psTotal = conn.prepareStatement(totalSql);
        var rsTotal = psTotal.executeQuery();
        ExhibitionStatsVO stats = null;
        if (rsTotal.next()) {
            stats = new ExhibitionStatsVO(
                    true,
                    "统计信息获取成功",
                    rsTotal.getInt("total_revenue"),
                    rsTotal.getInt("total_tickets_sold"),
                    rsTotal.getInt("total_tickets_verified"),
                    new ArrayList<>());
        }

        String sessionSql = "SELECT " +
                "es.id AS session_id, " +
                "es.session_name, " +
                "IFNULL(SUM(o.total_amount), 0) AS revenue, " +
                "IFNULL(SUM(o.count), 0) AS sold, " +
                "COUNT(IF(t.status = 'used', 1, NULL)) AS verified " +
                "FROM exhibition_sessions es " +
                "LEFT JOIN orders o ON es.id = o.session_id AND o.status = 'paid' " +
                "LEFT JOIN tickets t ON o.order_no = t.order_no " +
                "GROUP BY es.id, es.session_name";
        // 获取各场次明细数据
        var psSession = conn.prepareStatement(sessionSql);
        ResultSet rsSession = psSession.executeQuery();
        var sessionStat = new SessionStatVO();
        while (rsSession.next()) {
            sessionStat.setSession_id(rsSession.getInt("session_id"));
            sessionStat.setSession_name(rsSession.getString("session_name"));
            sessionStat.setRevenue(rsSession.getInt("revenue"));
            sessionStat.setSold(rsSession.getInt("sold"));
            sessionStat.setVerified(rsSession.getInt("verified"));

            // 将单个场次数据加入到总结果的列表中
            stats.getSessions_stats().add(sessionStat);
        }
        return stats;
    }
}
