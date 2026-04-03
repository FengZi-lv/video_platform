package org.example.dao;


import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VideoLikeDao implements AutoCloseable {
    private final Connection conn;

    public VideoLikeDao() throws SQLException {
        this.conn = DBUtil.getConnection();
    }

    @Override
    public void close() {
        DBUtil.close(conn);
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

