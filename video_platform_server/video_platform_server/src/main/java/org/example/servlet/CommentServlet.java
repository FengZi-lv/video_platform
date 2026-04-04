package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/comments/*")
public class CommentServlet extends HttpServlet {

    /**
     * POST /api/comments
     * 发表评论
     */
    private void postComment(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * DELETE /api/comments/{id}
     * 删除评论
     */
    private void deleteComment(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/comments/like
     * 点赞评论
     */
    private void likeComment(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    /**
     * POST /api/comments/unlike
     * 取消点赞评论
     */
    private void unlikeComment(HttpServletRequest req, HttpServletResponse resp) {
       
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "", "/" -> postComment(req, resp);
            case "/like" -> likeComment(req, resp);
            case "/unlike" -> unlikeComment(req, resp);
            case null, default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            deleteComment(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "API not found");
        }
    }
}
