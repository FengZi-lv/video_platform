package org.example.dao;

import org.example.entity.Video;

import java.sql.SQLException;
import java.util.List;

public class VideoHistoryDao extends BaseDao {

    public VideoHistoryDao() throws SQLException {
        super();
    }


    public int addHistory(int userId, int videoId) throws Exception {
        var sql = "INSERT INTO video_history (user_id, video_id, last_watch_date) " +
                "VALUES (?, ?, CURRENT_TIMESTAMP)" +
                "ON DUPLICATE KEY UPDATE last_watch_date = CURRENT_TIMESTAMP;";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            return stmt.executeUpdate();
        }
    }

    public List<Video> getAllHistoryByUserId(int userId) throws Exception {
        var sql = "SELECT v.* FROM video_history vh JOIN videos v ON vh.video_id = v.id WHERE vh.user_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            var rs = stmt.executeQuery();
            List<Video> videos = new java.util.ArrayList<>();
            while (rs.next()) {
                Video video = new Video(
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
                        rs.getTimestamp("create_date")
                );
                videos.add(video);
            }
            return videos;
        }
    }
}

