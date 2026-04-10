package org.example.dao;

import org.example.entity.Video;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VideoFavoritesDao extends BaseDao {

    public VideoFavoritesDao() throws SQLException {
        super();
    }

    public int addFavorite(int userId, int videoId) throws Exception {
        var sql = "INSERT INTO video_favorites (user_id, video_id) VALUES (?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            return stmt.executeUpdate();
        }
    }

    public int deleteFavorite(int userId, int videoId) throws Exception {
        var sql = "DELETE FROM video_favorites WHERE user_id = ? AND video_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            return stmt.executeUpdate();
        }
    }

    public boolean isFavorited(int userId, int videoId) throws Exception {
        var sql = "SELECT 1 FROM video_favorites WHERE user_id = ? AND video_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            try (var rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<Video> getAllFavoritesByUserId(int userId) throws Exception {
        var sql = "SELECT v.* FROM video_favorites vf JOIN videos v ON vf.video_id = v.id WHERE vf.user_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            var rs = stmt.executeQuery();
            List<Video> videos = new ArrayList<>();
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
