package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import org.example.dto.BanUserDTO;
import org.example.dto.HandleReportDTO;
import org.example.dto.ReviewVideoDTO;
import org.example.dto.UserPayloadDTO;
import org.example.service.ReportService;
import org.example.service.UserService;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;
import org.example.vo.UserListVO;
import org.example.vo.VideoListVO;

@WebServlet("/api/admin/*")
public class AdminServlet extends HttpServlet {

    private UserService userService;
    private ReportService reportService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userService = new UserService();
            reportService = new ReportService();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize UserService", e);
        }
    }

    /**
     * GET /api/admin/users
     * 查看所有用户
     */
    private UserListVO getUsers(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        return userService.getAllUsers(user, req);
    }

    /**
     * POST /api/admin/users/ban
     * 封禁账号
     */
    private ResultVO banUser(BanUserDTO dto) throws Exception {
        return userService.banUser(dto);
    }

    /**
     * GET /api/admin/videos/pending
     * 查看审核视频列表
     */
    private VideoListVO getPendingVideos(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        return reportService.getPendingVideos(user, req);
    }

    /**
     * POST /api/admin/videos/review
     * 审核视频
     */
    private ResultVO reviewVideo(ReviewVideoDTO dto) throws Exception {
        return reportService.reviewVideo(dto);
    }

    /**
     * GET /api/admin/reports
     * 查看举报列表
     */
    private org.example.vo.ReportListVO getReports(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        return reportService.getReportList(user, req);
    }

    /**
     * POST /api/admin/reports/handle
     * 处理举报
     */
    private ResultVO handleReport(HandleReportDTO dto) throws Exception {
        return reportService.handleReport(dto);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users" -> ServletUtil.handleGetRequest(req, resp, this::getUsers);
            case "/videos/pending" -> ServletUtil.handleGetRequest(req, resp, this::getPendingVideos);
            case "/reports" -> ServletUtil.handleGetRequest(req, resp, this::getReports);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users/ban" -> ServletUtil.handleJsonRequest(req, resp, BanUserDTO.class, this::banUser);
            case "/videos/review" -> ServletUtil.handleJsonRequest(req, resp, ReviewVideoDTO.class, this::reviewVideo);
            case "/reports/handle" -> ServletUtil.handleJsonRequest(req, resp, HandleReportDTO.class, this::handleReport);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
