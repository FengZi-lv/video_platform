package org.example.dao;

import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;

public abstract class BaseDao implements AutoCloseable {
    protected final Connection conn;

    protected BaseDao() throws SQLException {
        this.conn = DBUtil.getConnection();
    }

    @Override
    public void close() {
        DBUtil.close(conn);
    }
}

