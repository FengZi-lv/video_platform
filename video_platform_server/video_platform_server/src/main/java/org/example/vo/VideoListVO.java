package org.example.vo;

public class VideoListVO extends ResultVO {
    private VideoVO[] videos;
    private Integer totalPages;

    public VideoListVO() {
    }

    public VideoListVO(boolean success, String msg, VideoVO[] videos, Integer totalPages) {
        super(success, msg);
        this.videos = videos;
        this.totalPages = totalPages;
    }

    public VideoVO[] getVideos() {
        return videos;
    }

    public void setVideos(VideoVO[] videos) {
        this.videos = videos;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }
}
