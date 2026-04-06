package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.UpdateProfileDTO;
import org.example.service.UserService;
import org.example.util.AuthUtil;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;

import java.io.IOException;

@WebServlet("/api/users/*")
public class UserServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userService = new UserService();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize UserService", e);
        }
    }

    /**
     * POST /api/users/profile
     * 修改个人信息
     */
    private ResultVO updateProfile(UpdateProfileDTO updateProfileDTO) throws Exception {
        return userService.updateProfile(updateProfileDTO);
    }

    /**
     * GET /api/users/me
     * 获取用户信息
     */
    private void getUserInfo(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * POST /api/users/sign-in
     * 签到，获得10个硬币
     */
    private void signIn(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * GET /api/users/sign-in/history
     * 获取签到记录
     */
    private void getSignInHistory(HttpServletRequest req, HttpServletResponse resp) {

    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/me" -> getUserInfo(req, resp);
            case "/sign-in/history" -> getSignInHistory(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/profile" -> ServletUtil.handleJsonRequest(req, resp, UpdateProfileDTO.class, this::updateProfile);
            case "/sign-in" -> signIn(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
