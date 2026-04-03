package org.example.dao;


import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CheckInDao implements AutoCloseable {
    private final Connection conn;

    public CheckInDao() throws SQLException {
        this.conn = DBUtil.getConnection();
    }

    @Override
    public void close() {
        DBUtil.close(conn);
    }

    public int signIn(int id) throws Exception {
        var sql = "INSERT INTO check_in (user_id) VALUES (?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate();
        }
    }

    public List<String> getAllRecords(int id) throws Exception {
        var sql = "SELECT date FROM check_in WHERE user_id = ?";
        var records = new ArrayList<String>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    records.add(rs.getString("date"));
                }
            }
        }
        return records;
    }

}