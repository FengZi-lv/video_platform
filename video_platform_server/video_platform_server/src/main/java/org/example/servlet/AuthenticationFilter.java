package org.example.servlet;


import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.util.AuthUtil;
import org.example.dao.UserDao;

import java.sql.SQLException;
import java.sql.Timestamp;

import java.io.IOException;

@WebFilter(urlPatterns = "/api/*")
public class AuthenticationFilter implements Filter {

    private static final String[] guestAllowed = {
            "/api/auth/login",
            "/api/auth/register",
            "/api/videos",
            "/api/videos/search"
    };

    private static final String[] withoutJWTAllowed = {
            "/api/file/get-video",
            "/api/file/get-image"
    };

    private static final String[] adminAllowed = {
            "/api/admin"
    };

    // 需要根据工件名称排除path
    private static final String artifactName = "/video_platform_server_war_exploded";

    private static UserDao userDao;

    @Override
    public void init(FilterConfig filterConfig) {
        try {
            userDao = new UserDao();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    private static boolean verifyPathIsAllow(String path, String[] allowedList) {
        for (var allowedPath : allowedList) {
            if (path.startsWith(allowedPath)) {
                return true;
            }
        }
        return false;
    }


    private void reject(HttpServletResponse httpResponse, String msg) throws IOException {
        httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        httpResponse.getWriter().write("{\"success\": false, \"msg\": \"" + msg + "\"}");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        var httpRequest = (HttpServletRequest) request;
        var httpResponse = (HttpServletResponse) response;

        var path = httpRequest.getRequestURI();

        // 过滤工件名
        path = path.substring(artifactName.length());

        // 如果是请求视频和缩略图
        if (verifyPathIsAllow(path, withoutJWTAllowed)) {
            chain.doFilter(request, response);
            return;
        }


        // 先设置所有后续返回的响应头为json
        httpResponse.setContentType("application/json;charset=UTF-8");

        String authHeader = httpRequest.getHeader("Authorization");

        // 验证是否带bearer
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            reject(httpResponse, "没有携带jwt");
            return;
        }
        var token = authHeader.substring(7);

        // bearer为空
        if (token.isEmpty()) {
            reject(httpResponse, "jwt为空");
            return;
        }


        // role为guest
        if (token.equals("guest")) {

            // 如果范围的是游客可访问的接口
            if (!verifyPathIsAllow(path, guestAllowed)) {
                reject(httpResponse, "游客不可访问");
                return;
            }

            chain.doFilter(request, response);
            return;
        }

        // 验证jwt是否正确
        var payload = AuthUtil.verifyToken(token);
        if (payload == null) {
            reject(httpResponse, "jwt格式错误");
            return;
        }

        // 验证用户是否已经被封禁
        if (payload.getRole().equals("ban")) {
            reject(httpResponse, "用户已被封禁");
            return;
        }

        // 验证jwt是否是修改密码前生成的
        Timestamp validAfter = null;
        try {
            validAfter = userDao.getTokenInvalidationTime(payload.getUserId());
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        if (validAfter != null && payload.getIat() != null) {
            if (payload.getIat().before(validAfter)) {
                reject(httpResponse, "jwt已过期");
                return;
            }
        }

        // 验证访问路径是否为管理员
        if (verifyPathIsAllow(path, adminAllowed) && !payload.getRole().equals("admin")) {
            reject(httpResponse, "无权限访问管理员接口");
            return;
        }

        // 解析payload并传递给后续servlet
        httpRequest.setAttribute("currentUser", payload);
        chain.doFilter(request, response);
    }
}
