package org.example.dao;

import org.example.entity.Comment;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;

public class CommentDao extends BaseDao {

    public CommentDao() throws SQLException {
        super();
    }


    public int addComment(Comment comment) throws Exception {
        var sql = "INSERT INTO comments (user_id, video_id, context,parent_id) VALUES (?, ?,?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, comment.getUserId());
            stmt.setInt(2, comment.getVideoId());
            stmt.setString(3, comment.getContext());
            stmt.setInt(4, comment.getParentId());
            return stmt.executeUpdate();
        }
    }

    public int updateStatusComment(Comment comment) throws Exception {
        var sql = "UPDATE comments SET status = ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, comment.getStatus());
            return stmt.executeUpdate();
        }
    }

    public List<Comment> getCommentsByVideoId(int videoId) throws Exception {
        var sql = "SELECT * FROM comments WHERE video_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, videoId);
            var rs = stmt.executeQuery();
            var comments = new java.util.ArrayList<Comment>();
            while (rs.next()) {
                var comment = new Comment(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getInt("video_id"),
                        rs.getString("status"),
                        rs.getTimestamp("create_date"),
                        rs.getInt("parent_id"),
                        rs.getString("context")
                );
                comments.add(comment);
            }
            return comments;
        }
    }


}

