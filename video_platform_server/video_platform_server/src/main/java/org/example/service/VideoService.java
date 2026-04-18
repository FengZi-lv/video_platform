package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.*;
import org.example.dto.*;
import org.example.entity.Comment;
import org.example.entity.Video;
import org.example.entity.VideoCoin;
import org.example.util.Config;
import org.example.vo.*;

import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;
import java.util.Objects;

import jakarta.servlet.http.Part;

import java.io.File;
import java.util.UUID;


public class VideoService {

    private final VideoDao videoDao;
    private final VideoLikeDao videoLikeDao;
    private final VideoFavoritesDao videoFavoritesDao;
    private final VideoHistoryDao videoHistoryDao;
    private final VideoCoinsDao videoCoinsDao;
    private final CommentDao commentDao;
    private final CommentLikesDao commentLikesDao;

    private final String uploadDir;

    public VideoService() throws SQLException {
        videoDao = new VideoDao();
        videoLikeDao = new VideoLikeDao();
        videoFavoritesDao = new VideoFavoritesDao();
        videoHistoryDao = new VideoHistoryDao();
        videoCoinsDao = new VideoCoinsDao();
        commentDao = new CommentDao();
        commentLikesDao = new CommentLikesDao();
        uploadDir = Config.RES_BASE_PATH;

    }

    /**
     * 获取视频列表
     */
    public VideoListVO getVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        List<Video> videos = videoDao.getRadomVideos();
        List<VideoVO> videoArray = toVideoVOArray(videos);
        return new VideoListVO(true, "获取视频列表成功", videoArray, null);
    }

    /**
     * 搜索视频
     */
    public VideoListVO searchVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        String keyword = req.getParameter("q");
        int page = req.getParameter("page") != null ? Integer.parseInt(req.getParameter("page")) : 1;
        int offset = (page - 1) * 10;
        List<Video> videos = videoDao.queryVideosByTitle(keyword, offset);
        int total = videoDao.countVideosByTitle(keyword);
        int totalPages = (int) Math.ceil((double) total / 10);
        return new VideoListVO(true, "搜索成功", toVideoVOArray(videos), totalPages);
    }

    /**
     * 获取视频详情
     */
    public VideoDetailVO getVideoDetail(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        String pathInfo = req.getPathInfo();
        int videoId = Integer.parseInt(pathInfo.replace("/", ""));

        Video video = videoDao.getVideoById(videoId);
        if (video == null) {
            return new VideoDetailVO();
        }

        List<Integer> likedCommentIds = new java.util.ArrayList<>();
        boolean isLiked = false;
        boolean isFavorited = false;
        if (userPayloadDTO != null && userPayloadDTO.getUserId() != null) {
            int userId = userPayloadDTO.getUserId();
            videoHistoryDao.addHistory(userId, videoId);
            likedCommentIds = commentLikesDao.getLikedCommentIds(userId, videoId);
            isLiked = videoLikeDao.isLiked(userId, videoId);
            isFavorited = videoFavoritesDao.isFavorited(userId, videoId);
        }

        List<Integer> finalLikedCommentIds = likedCommentIds;
        List<CommentVO> comments = commentDao.getCommentsByVideoId(videoId).stream()
                .map(c -> new CommentVO(
                        true,
                        "成功",
                        c.getId(),
                        Objects.equals(c.getStatus(), "del") ? "" : c.getContext(),
                        c.getLikes(),
                        c.getParentId(),
                        c.getStatus(),
                        finalLikedCommentIds.contains(c.getId()),
                        c.getUserId()
                ))
                .toList();

        return new VideoDetailVO(
                true,
                "成功",
                video.getId(),
                video.getIntro(),
                video.getVideoUrl(),
                video.getUploaderId(),
                isLiked,
                isFavorited,
                comments
        );
    }

    /**
     * POST /api/videos/publish
     * 发布视频
     */
    public ResultVO publishVideo(PublishVideoDTO dto) throws Exception {

        // 检查服务器是否存在视频文件和缩略图文件
        String physicalSrc = dto.getSrc() != null ?
                                        dto.getSrc().replace("/", uploadDir) : "";
        String physicalThumb = dto.getThumbnail() != null ?
                                        dto.getThumbnail().replace("/", uploadDir) : "";
        if (!new File(physicalSrc).exists() || !new File(physicalThumb).exists()) {
            return new ResultVO(false, "发布失败：视频文件或缩略图文件不存在");
        }

        Video video = new Video(
                null,
                dto.getUserId(),
                dto.getTitle(),
                dto.getDescription(),
                "reviewing",
                0,
                0,
                0,
                dto.getSrc(),
                dto.getThumbnail(),
                new java.sql.Timestamp(System.currentTimeMillis())
        );
        int rows = videoDao.addVideo(video);
        return new ResultVO(rows > 0, rows > 0 ? "发布成功，等待审核" : "发布失败");
    }

    /**
     * 上传视频
     */
    public ResultVO uploadVideo(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        Part videoPart = req.getPart("video");
        Part thumbnailPart = req.getPart("thumbnail");

        if (videoPart == null || thumbnailPart == null) {
            return new ResultVO(false, "上传视频失败：缺少视频或缩略图文件");
        }

        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        String videoFileName = UUID.randomUUID() + "-" + getSubmittedFileName(videoPart);
        String thumbnailFileName = UUID.randomUUID() + "-" + getSubmittedFileName(thumbnailPart);

        videoPart.write(uploadDir + videoFileName);
        thumbnailPart.write(uploadDir + thumbnailFileName);

        return new UploadResult(true, "上传视频成功", "/" + videoFileName, "/" + thumbnailFileName);
    }

    private String getSubmittedFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }

    /**
     * 点赞视频
     */
    public ResultVO likeVideo(VideoActionDTO dto) throws Exception {
        try {
            int rows = videoLikeDao.addLike(dto.getUserId(), dto.getVideo_id());
            return new ResultVO(rows > 0, rows > 0 ? "点赞成功" : "点赞失败");
        } catch (SQLIntegrityConstraintViolationException e) {
            return new ResultVO(false, "已点赞过");
        }
    }

    /**
     * 取消点赞
     */
    public ResultVO unlikeVideo(VideoActionDTO dto) throws Exception {
        int rows = videoLikeDao.deleteLike(dto.getUserId(), dto.getVideo_id());
        return new ResultVO(rows > 0, rows > 0 ? "取消点赞成功" : "未点赞过");
    }

    /**
     * 收藏视频
     */
    public ResultVO favoriteVideo(VideoActionDTO dto) throws Exception {
        try {
            int rows = videoFavoritesDao.addFavorite(dto.getUserId(), dto.getVideo_id());
            return new ResultVO(rows > 0, rows > 0 ? "收藏成功" : "收藏失败");
        } catch (SQLIntegrityConstraintViolationException e) {
            return new ResultVO(false, "已收藏过");
        }
    }

    /**
     * 取消收藏
     */
    public ResultVO unfavoriteVideo(VideoActionDTO dto) throws Exception {
        int rows = videoFavoritesDao.deleteFavorite(dto.getUserId(), dto.getVideo_id());
        return new ResultVO(rows > 0, rows > 0 ? "取消收藏成功" : "未收藏过");
    }

    /**
     * 收藏的视频列表
     */
    public VideoListVO getFavoriteVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        List<Video> videos = videoFavoritesDao.getAllFavoritesByUserId(userPayloadDTO.getUserId());
        return new VideoListVO(true, "获取收藏列表成功", toVideoVOArray(videos), null);
    }

    /**
     * 历史浏览
     */
    public VideoListVO getVideoHistory(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        List<Video> videos = videoHistoryDao.getAllHistoryByUserId(userPayloadDTO.getUserId());
        return new VideoListVO(true, "获取历史记录成功", toVideoVOArray(videos), null);
    }

    /**
     * 投币
     */
    public ResultVO coinVideo(VideoCoinDTO dto) throws Exception {
        try {
            VideoCoin videoCoin = new VideoCoin(dto.getUserId(), dto.getVideo_id(), dto.getCoins());
            int rows = videoCoinsDao.addCoins(videoCoin);
            return new ResultVO(rows > 0, rows > 0 ? "投币成功" : "投币失败，硬币不足");
        } catch (SQLIntegrityConstraintViolationException e) {
            return new ResultVO(false, "已投币过");
        }
    }



    private List<VideoVO> toVideoVOArray(List<Video> videos) {
        return videos.stream()
                .map(v -> new VideoVO(
                        true,
                        "成功",
                        v.getId(),
                        v.getTitle(),
                        v.getThumbnailUrl(),
                        v.getLikesCount(),
                        v.getCoinsCount()
                )).toList();
    }
}