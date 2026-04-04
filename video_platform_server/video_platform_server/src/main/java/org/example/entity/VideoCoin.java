package org.example.entity;

public class VideoCoin {
    private int userId;
    private int videoId;
    private int count;

    public VideoCoin(int userId, int videoId, int count) {
        this.userId = userId;
        this.videoId = videoId;
        this.count = count;
    }


    public int getUserId() {
        return userId;
    }

    public int getVideoId() {
        return videoId;
    }

    public int getCount() {
        return count;
    }
}
