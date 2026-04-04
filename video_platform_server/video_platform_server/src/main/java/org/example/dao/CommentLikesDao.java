package org.example.dao;

import java.sql.SQLException;

public class CommentLikesDao extends BaseDao {

    public CommentLikesDao() throws SQLException {
        super();
    }

    public int addLike(int userId, int commentId) throws Exception {
        var sql = "INSERT INTO comment_likes (user_id, comment_id) VALUES (?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, commentId);
            return stmt.executeUpdate();
        }
    }


    public int deleteLike(int userId, int commentId) throws Exception {
        var sql = "DELETE FROM comment_likes WHERE user_id = ? AND comment_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, commentId);
            return stmt.executeUpdate();
        }
    }


}

