package org.example.vo;

import java.util.List;

public class VideoListVO extends ResultVO {
    private List<VideoVO> videos;
    private Integer totalPages;

    public VideoListVO() {
    }

    public VideoListVO(boolean success, String msg, List<VideoVO> videos, Integer totalPages) {
        super(success, msg);
        this.videos = videos;
        this.totalPages = totalPages;
    }

    public List<VideoVO> getVideos() {
        return videos;
    }

    public void setVideos(List<VideoVO> videos) {
        this.videos = videos;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }
}
