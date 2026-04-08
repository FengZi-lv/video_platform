package org.example.dao;


import org.example.entity.Video;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VideoDao extends BaseDao {

    public VideoDao() throws SQLException {
        super();
    }

    public List<Video> getRadomVideos() throws Exception {
        var sql = "SELECT * FROM videos WHERE status = 'pass' ORDER BY RAND() LIMIT 10";
        var videos = new ArrayList<Video>();
        try (var stmt = conn.prepareStatement(sql);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                videos.add(new Video(
                        rs.getInt("id"),
                        rs.getInt("uploader_id"),
                        rs.getString("title"),
                        rs.getString("intro"),
                        "pass",
                        rs.getInt("likes_count"),
                        rs.getInt("favorites_count"),
                        rs.getInt("earn_coins"),
                        rs.getString("video_url"),
                        rs.getString("thumbnail_url"),

                        rs.getTimestamp("create_date")
                ));
            }
            return videos;
        }
    }

    public List<Video> queryVideosByTitle(String title, int offset) throws Exception {
        var sql = "SELECT * FROM videos WHERE status = 'pass' AND title LIKE ? LIMIT 10 OFFSET ?";
        var videos = new ArrayList<Video>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + title + "%");
            stmt.setInt(2, offset);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(new Video(
                            rs.getInt("id"),
                            rs.getInt("uploader_id"),
                            rs.getString("title"),
                            rs.getString("intro"),
                            "pass",
                            rs.getInt("likes_count"),
                            rs.getInt("favorites_count"),
                            rs.getInt("earn_coins"),
                            rs.getString("video_url"),
                            rs.getString("thumbnail_url"),
                            rs.getTimestamp("create_date")
                    ));
                }
                return videos;
            }
        }
    }

    public int countVideosByTitle(String title) throws Exception {
        var sql = "SELECT COUNT(*) FROM videos WHERE status = 'pass' AND title LIKE ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + title + "%");
            try (var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    return 0;
                }
            }
        }
    }

    public List<Video> getUserAllVideoById(int id) throws Exception {
        var sql = "SELECT * FROM videos WHERE uploader_id = ? AND status = 'pass'";
        var videos = new ArrayList<Video>();
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (var rs = stmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(new Video(
                            rs.getInt("id"),
                            rs.getInt("uploader_id"),
                            rs.getString("title"),
                            rs.getString("intro"),
                            "pass",
                            rs.getInt("likes_count"),
                            rs.getInt("favorites_count"),
                            rs.getInt("earn_coins"),
                            rs.getString("video_url"),
                            rs.getString("thumbnail_url"),
                            rs.getTimestamp("create_date")
                    ));
                }
            }
        }
        return videos;
    }

    public Video getVideoById(int id) throws Exception {
        var sql = "SELECT * FROM videos WHERE id = ? AND status = 'pass'";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Video(
                            rs.getInt("id"),
                            rs.getInt("uploader_id"),
                            rs.getString("title"),
                            rs.getString("intro"),
                            "pass",
                            rs.getInt("likes_count"),
                            rs.getInt("favorites_count"),
                            rs.getInt("earn_coins"),
                            rs.getString("video_url"),
                            rs.getString("thumbnail_url"),
                            rs.getTimestamp("create_date")
                    );
                } else {
                    return null;
                }
            }
        }
    }

    public int addVideo(Video video) throws Exception {
        var sql = "INSERT INTO videos " +
                "(uploader_id, title, intro, status, likes_count, favorites_count, earn_coins, video_url,thumbnail_url) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?,?)";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, video.getUploaderId());
            stmt.setString(2, video.getTitle());
            stmt.setString(3, video.getIntro());
            stmt.setString(4, video.getStatus());
            stmt.setInt(5, video.getLikesCount());
            stmt.setInt(6, video.getFavoritesCount());
            stmt.setInt(7, video.getCoinsCount());
            stmt.setString(8, video.getVideoUrl());
            stmt.setString(9, video.getThumbnailUrl());
            return stmt.executeUpdate();
        }
    }

    public List<Video> getAllPendingVideos() throws Exception {
        var sql = "SELECT * FROM videos WHERE status = 'reviewing'";
        var videos = new ArrayList<Video>();
        try (var stmt = conn.prepareStatement(sql);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                videos.add(new Video(
                        rs.getInt("id"),
                        rs.getInt("uploader_id"),
                        rs.getString("title"),
                        rs.getString("intro"),
                        "pending",
                        rs.getInt("likes_count"),
                        rs.getInt("favorites_count"),
                        rs.getInt("earn_coins"),
                        rs.getString("video_url"),
                        rs.getString("thumbnail_url"),
                        rs.getTimestamp("create_date")
                ));
            }
            return videos;
        }
    }

    public int updateVideoStatus(int id, String status) throws Exception {
        var sql = "UPDATE videos SET status = ? WHERE id = ?";
        try (var stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate();
        }
    }


}

