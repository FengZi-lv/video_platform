package org.example.dao;

import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;

public abstract class BaseDao implements AutoCloseable {
    protected final Connection conn;

    private final boolean isExternalConn;

    protected BaseDao() throws SQLException {
        this.conn = DBUtil.getConnection();
        this.isExternalConn = false;
    }

    protected BaseDao(Connection conn) {
        this.conn = conn;
        this.isExternalConn = true;
    }

    public Connection getConnection() {
        return conn;
    }

    @Override
    public void close() {
        if (!isExternalConn) {
            DBUtil.close(conn);
        }
    }
}

