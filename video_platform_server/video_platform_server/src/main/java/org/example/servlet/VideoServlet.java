package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.*;
import org.example.service.ReportService;
import org.example.service.VideoService;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;
import org.example.vo.VideoDetailVO;
import org.example.vo.VideoListVO;
import org.example.vo.VideoVO;

import java.io.IOException;

@WebServlet("/api/videos/*")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB 配置阈值
        maxFileSize = 1024 * 1024 * 500,      // 500MB 最大单个文件大小
        maxRequestSize = 1024 * 1024 * 550    // 550MB 最大整体请求大小
)
public class VideoServlet extends HttpServlet {
    private VideoService videoService;
    private ReportService reportService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            videoService = new VideoService();
            reportService = new ReportService();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize VideoService", e);
        }
    }

    /**
     * GET /api/videos
     * 获取视频列表
     */
    private VideoListVO getVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return videoService.getVideos(userPayloadDTO, req);
    }

    /**
     * GET /api/videos/search?q=关键字&page=页码
     * 搜索视频
     */
    private VideoListVO searchVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return videoService.searchVideos(userPayloadDTO, req);
    }

    /**
     * GET /api/videos/{id}
     * 获取视频详情
     */
    private VideoDetailVO getVideoDetail(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return videoService.getVideoDetail(userPayloadDTO, req);
    }

    /**
     * GET /api/videos/favorites
     * 收藏的视频列表
     */
    private VideoListVO getFavoriteVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return videoService.getFavoriteVideos(userPayloadDTO, req);
    }

    /**
     * GET /api/videos/history
     * 获取历史浏览记录
     */
    private VideoListVO getVideoHistory(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return videoService.getVideoHistory(userPayloadDTO, req);
    }

    /**
     * POST /api/videos/publish
     * 发布视频
     */
    private ResultVO publishVideo(PublishVideoDTO dto) throws Exception {
        return videoService.publishVideo(dto);
    }

    /**
     * POST /api/videos/upload
     * 上传视频 (multipart/form-data)
     */
    private void uploadVideo(HttpServletRequest req, HttpServletResponse resp) {
        try {
            ResultVO result = videoService.uploadVideo((UserPayloadDTO) req.getAttribute("currentUser"), req);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            try {
                e.printStackTrace();
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"message\": \"上传失败，发生错误\"}");
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }

    /**
     * POST /api/videos/like
     * 点赞视频
     */
    private ResultVO likeVideo(VideoActionDTO dto) throws Exception {
        return videoService.likeVideo(dto);
    }

    /**
     * POST /api/videos/unlike
     * 取消点赞
     */
    private ResultVO unlikeVideo(VideoActionDTO dto) throws Exception {
        return videoService.unlikeVideo(dto);
    }

    /**
     * POST /api/videos/favorite
     * 收藏视频
     */
    private ResultVO favoriteVideo(VideoActionDTO dto) throws Exception {
        return videoService.favoriteVideo(dto);
    }

    /**
     * POST /api/videos/unfavorite
     * 取消收藏
     */
    private ResultVO unfavoriteVideo(VideoActionDTO dto) throws Exception {
        return videoService.unfavoriteVideo(dto);
    }

    /**
     * POST /api/videos/coin
     * 投币
     */
    private ResultVO coinVideo(VideoCoinDTO dto) throws Exception {
        return videoService.coinVideo(dto);
    }

    /**
     * POST /api/videos/report
     * 举报视频
     */
    private ResultVO reportVideo(ReportVideoDTO dto) throws Exception {
        return reportService.reportVideo(dto);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case null -> ServletUtil.handleGetRequest(req, resp, this::getVideos);
            case "/search" -> ServletUtil.handleGetRequest(req, resp, this::searchVideos);
            case "/favorites" -> ServletUtil.handleGetRequest(req, resp, this::getFavoriteVideos);
            case "/history" -> ServletUtil.handleGetRequest(req, resp, this::getVideoHistory);
            default -> {
                if (pathInfo.matches("/\\d+")) {
                    ServletUtil.handleGetRequest(req, resp, this::getVideoDetail);
                } else {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
                }
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/publish" -> ServletUtil.handleJsonRequest(req, resp, PublishVideoDTO.class, this::publishVideo);
            case "/upload" -> uploadVideo(req, resp);
            case "/like" -> ServletUtil.handleJsonRequest(req, resp, VideoActionDTO.class, this::likeVideo);
            case "/unlike" -> ServletUtil.handleJsonRequest(req, resp, VideoActionDTO.class, this::unlikeVideo);
            case "/favorite" -> ServletUtil.handleJsonRequest(req, resp, VideoActionDTO.class, this::favoriteVideo);
            case "/unfavorite" -> ServletUtil.handleJsonRequest(req, resp, VideoActionDTO.class, this::unfavoriteVideo);
            case "/coin" -> ServletUtil.handleJsonRequest(req, resp, VideoCoinDTO.class, this::coinVideo);
            case "/report" -> ServletUtil.handleJsonRequest(req, resp, ReportVideoDTO.class, this::reportVideo);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}