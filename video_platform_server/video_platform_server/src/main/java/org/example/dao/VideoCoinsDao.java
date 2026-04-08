package org.example.dao;

import org.example.entity.VideoCoin;

import java.sql.SQLException;
import java.util.List;

public class VideoCoinsDao extends BaseDao {

    public VideoCoinsDao() throws SQLException {
        super();
    }

    public int addCoins(VideoCoin videoCoin) throws Exception {
        var checkSql = "SELECT coins FROM users WHERE id = ?";
        try (var checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, videoCoin.getUserId());
            try (var rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    int balance = rs.getInt("coins");
                    if (balance < videoCoin.getCount()) {
                        return 0;
                    }
                } else {
                    return 0;
                }
            }
        }

        var updateSql = "UPDATE users SET coins = coins - ? WHERE id = ?";
        try (var updateStmt = conn.prepareStatement(updateSql)) {
            updateStmt.setInt(1, videoCoin.getCount());
            updateStmt.setInt(2, videoCoin.getUserId());
            updateStmt.executeUpdate();
        }

        var sql = "INSERT INTO video_earn_coins (user_id, video_id,count) VALUES (?, ?,?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, videoCoin.getUserId());
            stmt.setInt(2, videoCoin.getVideoId());
            stmt.setInt(3, videoCoin.getCount());

            int rows = stmt.executeUpdate();

            // Note: need to update videos.earn_coins to reflect the total earned coins
            var updateVideoSql = "UPDATE videos SET earn_coins = earn_coins + ? WHERE id = ?";
            try (var updateVideoStmt = conn.prepareStatement(updateVideoSql)) {
                updateVideoStmt.setInt(1, videoCoin.getCount());
                updateVideoStmt.setInt(2, videoCoin.getVideoId());
                updateVideoStmt.executeUpdate();
            }

            // Note: need to update users.earn_coins (for the uploader) to reflect total earned coins
            var updateUserEarnSql = "UPDATE users SET earn_coins = earn_coins + ? WHERE id = (SELECT uploader_id FROM videos WHERE id = ?)";
            try (var updateUserEarnStmt = conn.prepareStatement(updateUserEarnSql)) {
                updateUserEarnStmt.setInt(1, videoCoin.getCount());
                updateUserEarnStmt.setInt(2, videoCoin.getVideoId());
                updateUserEarnStmt.executeUpdate();
            }

            return rows;
        }
    }


    public List<VideoCoin> getAllCoinsRecords() throws Exception {
        var sql = "SELECT user_id, video_id, count FROM video_earn_coins";
        try (var stmt = conn.prepareStatement(sql);
             var rs = stmt.executeQuery()) {
            var coinsList = new java.util.ArrayList<VideoCoin>();
            while (rs.next()) {
                var videoCoin = new VideoCoin(
                        rs.getInt("user_id"),
                        rs.getInt("video_id"),
                        rs.getInt("count")
                );
                coinsList.add(videoCoin);
            }
            return coinsList;
        }
    }

}
