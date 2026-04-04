package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/admin/*")
public class AdminServlet extends HttpServlet {

    /**
     * GET /api/admin/users
     * 查看所有用户
     */
    private void getUsers(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/admin/users/ban
     * 封禁账号
     */
    private void banUser(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * GET /api/admin/videos/pending
     * 查看审核视频列表
     */
    private void getPendingVideos(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/admin/videos/review
     * 审核视频
     */
    private void reviewVideo(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * GET /api/admin/reports
     * 查看举报列表
     */
    private void getReports(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/admin/reports/handle
     * 处理举报
     */
    private void handleReport(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users" -> getUsers(req, resp);
            case "/videos/pending" -> getPendingVideos(req, resp);
            case "/reports" -> getReports(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users/ban" -> banUser(req, resp);
            case "/videos/review" -> reviewVideo(req, resp);
            case "/reports/handle" -> handleReport(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
