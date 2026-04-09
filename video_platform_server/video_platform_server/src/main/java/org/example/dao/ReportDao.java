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

    public int updateReviewingReportStatus(int id, String status) throws Exception {
        var sql = "UPDATE reports SET status = ? WHERE id = ? AND status = 'reviewing'";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate();
        }
    }

    public List<Report> getAllReports() throws Exception {
        var sql = "SELECT r.id, r.video_id, r.context, r.status, u.nickname, r.user_id, r.create_date " +
                "FROM reports r " +
                "LEFT JOIN users u ON r.user_id = u.id";
        try (var stmt = conn.prepareStatement(sql)) {
            var rs = stmt.executeQuery();
            var reports = new java.util.ArrayList<Report>();
            while (rs.next()) {
                reports.add(new Report(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getInt("video_id"),
                        rs.getString("context"),
                        rs.getString("status"),
                        rs.getTimestamp("create_date"),
                        rs.getString("nickname")
                ));
            }
            return reports;
        }
    }
}