package org.example.dao;


import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VideoLikeDao extends BaseDao {

    public VideoLikeDao() throws SQLException {
        super();
    }

    public int addLike(int userId, int videoId) throws Exception {
        var sql = "INSERT INTO video_like (user_id, video_id) VALUES (?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            return stmt.executeUpdate();
        }
    }

    public int deleteLike(int userId, int videoId) throws Exception {
        var sql = "DELETE FROM video_like WHERE user_id = ? AND video_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            return stmt.executeUpdate();
        }
    }


}

