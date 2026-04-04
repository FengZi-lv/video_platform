package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/videos/*")
public class VideoServlet extends HttpServlet {

    /**
     * GET /api/videos
     * 获取视频列表
     */
    private void getVideos(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * GET /api/videos/search?q=关键字&page=页码
     * 搜索视频
     */
    private void searchVideos(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * GET /api/videos/{id}
     * 获取视频详情
     */
    private void getVideoDetail(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/publish
     * 发布视频
     */
    private void publishVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/upload
     * 上传视频
     */
    private void uploadVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/like
     * 点赞视频
     */
    private void likeVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/unlike
     * 取消点赞
     */
    private void unlikeVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/favorite
     * 收藏视频
     */
    private void favoriteVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/unfavorite
     * 取消收藏
     */
    private void unfavoriteVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * GET /api/videos/favorites
     * 收藏的视频列表
     */
    private void getFavoriteVideos(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * GET /api/videos/history
     * 获取历史浏览记录
     */
    private void getVideoHistory(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/coin
     * 投币
     */
    private void coinVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/videos/report
     * 举报视频
     */
    private void reportVideo(HttpServletRequest req, HttpServletResponse resp) {

    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "", "/" -> getVideos(req, resp);
            case "/search" -> searchVideos(req, resp);
            case "/favorites" -> getFavoriteVideos(req, resp);
            case "/history" -> getVideoHistory(req, resp);
            case null, default -> {
                if (pathInfo != null && pathInfo.matches("/\\d+")) {
                    getVideoDetail(req, resp);
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
            case "/publish" -> publishVideo(req, resp);
            case "/upload" -> uploadVideo(req, resp);
            case "/like" -> likeVideo(req, resp);
            case "/unlike" -> unlikeVideo(req, resp);
            case "/favorite" -> favoriteVideo(req, resp);
            case "/unfavorite" -> unfavoriteVideo(req, resp);
            case "/coin" -> coinVideo(req, resp);
            case "/report" -> reportVideo(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
