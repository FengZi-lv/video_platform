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
        var sql = "INSERT INTO comments (user_id, video_id, context,parent_id, image_url) VALUES (?, ?, ?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, comment.getUserId());
            stmt.setInt(2, comment.getVideoId());
            stmt.setString(3, comment.getContext());
            stmt.setInt(4, comment.getParentId());
            stmt.setString(5, comment.getImageUrl());
            stmt.executeUpdate();
            try (var rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return 0;
        }
    }

    public int updateStatusComment(Comment comment) throws Exception {
        var sql = "UPDATE comments SET status = ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, comment.getStatus());
            stmt.setInt(2, comment.getId());
            return stmt.executeUpdate();
        }
    }

    public int incrementLikes(int commentId) throws Exception {
        var sql = "UPDATE comments SET likes = likes + 1 WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, commentId);
            return stmt.executeUpdate();
        }
    }

    public int decrementLikes(int commentId) throws Exception {
        var sql = "UPDATE comments SET likes = likes - 1 WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, commentId);
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
                        rs.getInt("likes"),
                        rs.getInt("video_id"),
                        rs.getString("status"),
                        rs.getTimestamp("create_date"),
                        rs.getInt("parent_id"),
                        rs.getString("context"),
                        rs.getString("image_url")
                );
                comments.add(comment);
            }
            return comments;
        }
    }


    public Comment getCommentById(int id) throws Exception {
        var sql = "SELECT * FROM comments WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            var rs = stmt.executeQuery();
            if (rs.next()) {
                return new Comment(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getInt("likes"),
                        rs.getInt("video_id"),
                        rs.getString("status"),
                        rs.getTimestamp("create_date"),
                        rs.getInt("parent_id"),
                        rs.getString("context"),
                        rs.getString("image_url")
                );
            }
            return null;
        }
    }

}
