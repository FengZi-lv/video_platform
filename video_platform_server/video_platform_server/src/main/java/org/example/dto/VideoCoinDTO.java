package org.example.dto;

public class VideoCoinDTO extends UserPayloadDTO {
    private Integer video_id;
    private Integer coins;

    public VideoCoinDTO() {
        super(null, null, null, null, null);
    }

    public VideoCoinDTO(Integer video_id, Integer coins) {
        super(null, null, null, null, null);
        this.video_id = video_id;
        this.coins = coins;
    }

    public Integer getVideo_id() {
        return video_id;
    }

    public void setVideo_id(Integer video_id) {
        this.video_id = video_id;
    }

    public Integer getCoins() {
        return coins;
    }

    public void setCoins(Integer coins) {
        this.coins = coins;
    }
}