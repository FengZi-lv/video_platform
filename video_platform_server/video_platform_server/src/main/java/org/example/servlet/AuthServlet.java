package org.example.servlet;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/auth/*")
public class AuthServlet extends HttpServlet {

    /**
     * POST /api/auth/login
     * 用户登录
     */
    private void login(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/auth/register
     * 用户注册
     */
    private void register(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/auth/change-password
     * 修改密码
     */
    private void changePassword(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/auth/delete-account
     * 注销账号
     */
    private void deleteAccount(HttpServletRequest req, HttpServletResponse resp) {
       
    }
    

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/login" -> login(req, resp);
            case "/register" -> register(req, resp);
            case "/change-password" -> changePassword(req, resp);
            case "/delete-account" -> deleteAccount(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
