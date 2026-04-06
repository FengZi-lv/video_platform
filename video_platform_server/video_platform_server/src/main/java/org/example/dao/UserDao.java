package org.example.dao;

import org.example.entity.User;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDao extends BaseDao {

    public UserDao() throws SQLException {
        super();
    }


    public List<User> queryUsersById(int id) throws SQLException {
        var sql = "SELECT * FROM users WHERE id = ?";
        var users = new ArrayList<User>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    var user = new User(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("nickname"),
                            rs.getString("status"),
                            rs.getString("bio"),
                            rs.getInt("coins")
                    );
                    users.add(user);
                }
            }
        }
        return users;
    }

    public List<User> queryUsersByUsername(String username) throws SQLException {
        var sql = "SELECT * FROM users WHERE username = ?";
        var users = new ArrayList<User>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    var user = new User(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("nickname"),
                            rs.getString("status"),
                            rs.getString("bio"),
                            rs.getInt("coins")
                    );
                    users.add(user);
                }
            }
        }
        return users;
    }

    public int addUser(User user) throws SQLException {
        var sql = "INSERT INTO users (username, password, nickname, bio) VALUES (?, ?, ?, ?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getNickname());
            stmt.setString(4, user.getBio());
            return stmt.executeUpdate();
        }
    }

    public int updateUserPassword(int id, String pwd) throws SQLException {
        var sql = "UPDATE users SET password = ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, pwd);
            stmt.setInt(2, id);
            return stmt.executeUpdate();
        }
    }

    public int updateUserInfoById(User user) throws SQLException {
        var sql = "UPDATE users SET nickname = COALESCE(?, nickname), bio = COALESCE(?, bio) WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getNickname());
            stmt.setString(2, user.getBio());
            stmt.setInt(3, user.getId());
            return stmt.executeUpdate();
        }
    }

    public List<User> getAllUsers() throws SQLException {
        var sql = "SELECT * FROM users";
        var users = new ArrayList<User>();
        try (var stmt = conn.prepareStatement(sql);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                var user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("nickname"),
                        rs.getString("status"),
                        rs.getString("bio"),
                        rs.getInt("coins")
                );
                users.add(user);
            }
        }
        return users;
    }

    public int deleteUserById(int id) throws SQLException {
        var sql = "DELETE FROM users WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate();
        }
    }

    public int banUserById(int id) throws SQLException {
        var sql = "UPDATE users SET status = 'ban' WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate();
        }
    }

    public int unbanUserById(int id) throws SQLException {
        var sql = "UPDATE users SET status = 'active' WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate();
        }
    }

}
