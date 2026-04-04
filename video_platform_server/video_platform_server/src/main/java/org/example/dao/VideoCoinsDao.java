package org.example.dao;

import org.example.entity.VideoCoin;

import java.sql.SQLException;
import java.util.List;

public class VideoCoinsDao extends BaseDao {

    public VideoCoinsDao() throws SQLException {
        super();
    }

    public int addCoins(VideoCoin videoCoin) throws Exception {
        var sql = "INSERT INTO video_earn_coins (user_id, video_id,count) VALUES (?, ?,?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, videoCoin.getUserId());
            stmt.setInt(2, videoCoin.getVideoId());
            stmt.setInt(3, videoCoin.getCount());
            return stmt.executeUpdate();
        }
    }

    public int deleteCoins(VideoCoin videoCoin) throws Exception {
        var sql = "DELETE FROM video_earn_coins WHERE user_id = ? AND video_id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, videoCoin.getUserId());
            stmt.setInt(2, videoCoin.getVideoId());
            return stmt.executeUpdate();
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

