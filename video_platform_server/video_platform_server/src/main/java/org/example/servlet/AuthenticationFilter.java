package org.example.servlet;


import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.util.AuthUtil;

import java.io.IOException;

@WebFilter(urlPatterns = "/api/*")
public class AuthenticationFilter implements Filter {

    private static final String[] guestAllowed = {
            "/api/auth/login",
            "/api/auth/register",
            "/api/videos",
            "/api/videos/search"
    };

    private static final String[] adminAllowed = {
            "/api/admin"
    };

    // 需要根据工件名称排除path
    private static final String artifactName = "/video_platform_server_war_exploded";

    private static boolean verifyPathIsAllow(String path, String[] allowedList) {
        for (var allowedPath : allowedList) {
            if (path.startsWith(allowedPath)) {
                return true;
            }
        }
        return false;
    }


    private void reject(HttpServletResponse httpResponse) throws IOException {
        httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        httpResponse.setContentType("application/json;charset=UTF-8");
        httpResponse.getWriter().write("{\"success\": false, \"message\": \"Unauthorized\"}");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        var httpRequest = (HttpServletRequest) request;
        var httpResponse = (HttpServletResponse) response;


        String authHeader = httpRequest.getHeader("Authorization");

        // 验证是否带bearer
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            reject(httpResponse);
            return;
        }
        var token = authHeader.substring(7);

        // bearer为空
        if (token.isEmpty()) {
            reject(httpResponse);
            return;
        }

        var path = httpRequest.getRequestURI();

        // 过滤工件名
        path = path.substring(artifactName.length());

        // role为guest
        if (token.equals("guest")) {

            // 如果范围的是游客可访问的接口
            if (!verifyPathIsAllow(path, guestAllowed)) {
                reject(httpResponse);
                return;
            }

            chain.doFilter(request, response);
            return;
        }

        // 验证jwt是否正确
        if (!AuthUtil.verifyToken(token)) {
            reject(httpResponse);
            return;
        }

        var payload = AuthUtil.parseToken(token);

        // 验证访问路径是否为管理员
        if (!verifyPathIsAllow(path, adminAllowed) && payload.getRole().equals("admin")) {
            reject(httpResponse);
            return;
        }

        // 解析payload并传递给后续servlet
        httpRequest.setAttribute("currentUser", payload);
        chain.doFilter(request, response);
    }
}
