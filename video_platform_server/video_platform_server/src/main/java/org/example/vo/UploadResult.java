package org.example.vo;

public class UploadResult extends ResultVO {
    private String video_url;
    private String thumbnail_url;

    public UploadResult(boolean success, String msg, String video_url, String thumbnail_url) {
        super(success, msg);
        this.video_url = video_url;
        this.thumbnail_url = thumbnail_url;
    }

    public String getVideo_url() {
        return video_url;
    }

    public String getThumbnail_url() {
        return thumbnail_url;
    }
}
