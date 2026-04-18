package org.example.servlet;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.UserChangePwdDTO;
import org.example.dto.UserDeleteAccountDTO;
import org.example.dto.UserLoginDTO;
import org.example.dto.UserRegisterDTO;
import org.example.service.UserService;
import org.example.util.ServletUtil;
import org.example.vo.LoginVO;
import org.example.vo.RegisterVO;
import org.example.vo.ResultVO;

import java.io.IOException;

@WebServlet("/api/auth/*")
public class AuthServlet extends HttpServlet {

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
     * POST /api/auth/login
     * 用户登录
     */
    private LoginVO login(UserLoginDTO userLoginDTO) throws Exception {
        return userService.login(userLoginDTO);
    }

    /**
     * POST /api/auth/register
     * 用户注册
     */
    private RegisterVO register(UserRegisterDTO userRegisterDTO) throws Exception {
        return userService.register(userRegisterDTO);
    }

    /**
     * POST /api/auth/change-password
     * 修改密码
     */
    private ResultVO changePassword(UserChangePwdDTO userChangePwdDTO) throws Exception {
        return userService.changePassword(userChangePwdDTO);
    }

    /**
     * POST /api/auth/delete-account
     * 注销账号
     */
    private ResultVO deleteAccount(UserDeleteAccountDTO userDeleteAccountDTO) throws Exception {
        return   userService.deleteAccount(userDeleteAccountDTO);
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/login" -> ServletUtil.handleJsonRequest(req, resp, UserLoginDTO.class, this::login);
            case "/register" -> ServletUtil.handleJsonRequest(req, resp, UserRegisterDTO.class, this::register);
            case "/change-password" ->
                    ServletUtil.handleJsonRequest(req, resp, UserChangePwdDTO.class, this::changePassword);
            case "/delete-account" ->
                    ServletUtil.handleJsonRequest(req, resp, UserDeleteAccountDTO.class, this::deleteAccount);
            case null, default -> {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"success\": false, \"msg\": \"Not Found api\"}");
            }
        }
    }
}
