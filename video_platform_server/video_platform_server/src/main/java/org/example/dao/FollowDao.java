package org.example.dao;

import org.example.entity.User;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class FollowDao extends BaseDao {

    public FollowDao() throws SQLException {
        super();
    }

    public int follow(int followerId, int followingId) throws SQLException {
        var sql = "INSERT IGNORE INTO user_follows (follower_id, following_id) VALUES (?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, followerId);
            stmt.setInt(2, followingId);
            return stmt.executeUpdate();
        }
    }

    public int unfollow(int followerId, int followingId) throws SQLException {
        var sql = "DELETE FROM user_follows WHERE follower_id = ? AND following_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, followerId);
            stmt.setInt(2, followingId);
            return stmt.executeUpdate();
        }
    }

    public List<User> getFollowingUsers(int userId) throws SQLException {
        var sql = "SELECT u.* FROM users u INNER JOIN user_follows f ON u.id = f.following_id WHERE f.follower_id = ?";
        var list = new ArrayList<User>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    var user = new User(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("nickname"),
                            rs.getString("status"),
                            rs.getString("bio"),
                            rs.getInt("coins"),
                            rs.getInt("earn_coins"),
                            rs.getInt("likes")
                    );
                    list.add(user);
                }
            }
        }
        return list;
    }

    public List<User> getFollowerUsers(int userId) throws SQLException {
        var sql = "SELECT u.* FROM users u INNER JOIN user_follows f ON u.id = f.follower_id WHERE f.following_id = ?";
        var list = new ArrayList<User>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    var user = new User(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("nickname"),
                            rs.getString("status"),
                            rs.getString("bio"),
                            rs.getInt("coins"),
                            rs.getInt("earn_coins"),
                            rs.getInt("likes")
                    );
                    list.add(user);
                }
            }
        }
        return list;
    }

    public boolean isFollowing(int followerId, int followingId) throws SQLException {
        var sql = "SELECT 1 FROM user_follows WHERE follower_id = ? AND following_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, followerId);
            stmt.setInt(2, followingId);
            try (var rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }
}
