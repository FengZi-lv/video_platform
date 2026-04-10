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

    public java.util.List<Integer> getLikedCommentIds(int userId, int videoId) throws Exception {
        var sql = "SELECT cl.comment_id FROM comment_likes cl JOIN comments c ON cl.comment_id = c.id WHERE cl.user_id = ? AND c.video_id = ?";
        java.util.List<Integer> list = new java.util.ArrayList<>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, videoId);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt(1));
                }
            }
        }
        return list;
    }

}
