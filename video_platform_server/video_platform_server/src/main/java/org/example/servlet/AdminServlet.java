package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import org.example.dto.*;
import org.example.service.ReportService;
import org.example.service.UserService;
import org.example.service.TicketAdminService;
import org.example.service.ExhibitionService;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;
import org.example.vo.UserListVO;
import org.example.vo.VideoListVO;

@WebServlet("/api/admin/*")
public class AdminServlet extends HttpServlet {

    private UserService userService;
    private ReportService reportService;
    private TicketAdminService ticketAdminService;
    private ExhibitionService exhibitionService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userService = new UserService();
            reportService = new ReportService();
            ticketAdminService = new TicketAdminService();
            exhibitionService = new ExhibitionService();
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

    /**
     * GET /api/admin/tickets/orders
     * 查看所有订单信息
     */
    private ResultVO getAllTicketOrders(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        return ticketAdminService.getAllTicketOrders(user, req);
    }

    /**
     * POST /api/admin/tickets/refund/handle
     * 同意用户退票
     */
    private ResultVO handleTicketRefund(HandleRefundDTO dto) throws Exception {
        return ticketAdminService.handleTicketRefund(dto);
    }

    /**
     * POST /api/admin/tickets/verify
     * 线下核销
     */
    private ResultVO verifyTicket(VerifyTicketDTO dto) throws Exception {
        return ticketAdminService.verifyTicket(dto);
    }

    /**
     * GET /api/admin/exhibitions/{id}/stats
     * 查看漫展数据统计
     */
    private ResultVO getExhibitionStats(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        return exhibitionService.getExhibitionStats(user, req);
    }

    /**
     * POST /api/admin/exhibitions
     * 发布漫展演出
     */
    private ResultVO publishExhibition(PublishExhibitionDTO dto) throws Exception {
        return exhibitionService.publishExhibition(dto);
    }

    /**
     * PUT /api/admin/exhibitions/{id}
     * 修改漫展演出
     */
    private ResultVO updateExhibition(UpdateExhibitionDTO dto) throws Exception {
        return exhibitionService.updateExhibition(dto);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users" -> ServletUtil.handleGetRequest(req, resp, this::getUsers);
            case "/videos/pending" -> ServletUtil.handleGetRequest(req, resp, this::getPendingVideos);
            case "/reports" -> ServletUtil.handleGetRequest(req, resp, this::getReports);
            case "/tickets/orders" -> ServletUtil.handleGetRequest(req, resp, this::getAllTicketOrders);
            case null, default -> {
                if (pathInfo != null && pathInfo.matches("/exhibitions/\\d+/stats")) {
                    ServletUtil.handleGetRequest(req, resp, this::getExhibitionStats);
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
                }
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/users/ban" -> ServletUtil.handleJsonRequest(req, resp, BanUserDTO.class, this::banUser);
            case "/videos/review" -> ServletUtil.handleJsonRequest(req, resp, ReviewVideoDTO.class, this::reviewVideo);
            case "/reports/handle" -> ServletUtil.handleJsonRequest(req, resp, HandleReportDTO.class, this::handleReport);
            case "/exhibitions" -> ServletUtil.handleJsonRequest(req, resp, PublishExhibitionDTO.class, this::publishExhibition);
            case "/tickets/refund/handle" -> ServletUtil.handleJsonRequest(req, resp, HandleRefundDTO.class, this::handleTicketRefund);
            case "/tickets/verify" -> ServletUtil.handleJsonRequest(req, resp, VerifyTicketDTO.class, this::verifyTicket);
            case null, default -> {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
            }
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && pathInfo.matches("/exhibitions/\\d+")) {
            ServletUtil.handleJsonRequest(req, resp, UpdateExhibitionDTO.class, this::updateExhibition);
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
        }
    }
}
