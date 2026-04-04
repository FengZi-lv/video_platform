package org.example.dao;

import org.example.entity.Report;

import java.sql.SQLException;
import java.util.List;

public class ReportDao extends BaseDao {

    public ReportDao() throws SQLException {
        super();
    }

    public int addReport(Report report) throws Exception {
        var sql = "INSERT INTO reports (user_id, video_id, context) VALUES (?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, report.getUserId());
            stmt.setInt(2, report.getVideoId());
            stmt.setString(3, report.getContext());
            return stmt.executeUpdate();
        }
    }

    public int updateStatusReport(Report report) throws Exception {
        var sql = "UPDATE reports SET status = ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, report.getStatus());
            stmt.setInt(2, report.getId());
            return stmt.executeUpdate();
        }
    }

    public List<Report> getAllReports() throws Exception {
        var sql = "SELECT * FROM reports";
        try (var stmt = conn.prepareStatement(sql)) {
            var rs = stmt.executeQuery();
            var reports = new java.util.ArrayList<Report>();
            while (rs.next()) {
                var report = new Report(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getInt("video_id"),
                        rs.getString("context"),
                        rs.getString("status"),
                        rs.getTimestamp("create_date")
                );
                reports.add(report);
            }
            return reports;
        }
    }
}

