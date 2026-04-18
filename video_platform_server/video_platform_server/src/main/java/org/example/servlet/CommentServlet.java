package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.CommentActionDTO;
import org.example.dto.CommentLikeDTO;
import org.example.dto.UserPayloadDTO;
import org.example.service.CommentLikesService;
import org.example.service.CommentService;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;

import java.io.IOException;

@WebServlet("/api/comments/*")
public class CommentServlet extends HttpServlet {

    private CommentService commentService;
    private CommentLikesService commentLikesService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            commentService = new CommentService();
            commentLikesService = new CommentLikesService();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize services", e);
        }
    }

    /**
     * POST /api/comments
     * 发表评论
     */
    private ResultVO postComment(CommentActionDTO commentActionDTO) throws Exception {
        return commentService.postComment(commentActionDTO);
    }

    /**
     * DELETE /api/comments/{id}
     * 删除评论
     */
    private ResultVO deleteComment(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        int commentId = Integer.parseInt(req.getPathInfo().replace("/", ""));
        return commentService.deleteComment(userPayloadDTO, commentId);
    }

    /**
     * POST /api/comments/like
     * 点赞评论
     */
    private ResultVO likeComment(CommentLikeDTO commentLikeDTO) throws Exception {
        return commentLikesService.likeComment(commentLikeDTO);
    }

    /**
     * POST /api/comments/unlike
     * 取消点赞评论
     */
    private ResultVO unlikeComment(CommentLikeDTO commentLikeDTO) throws Exception {
        return commentLikesService.unlikeComment(commentLikeDTO);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case null -> ServletUtil.handleJsonRequest(req, resp, CommentActionDTO.class, this::postComment);
            case "/like" -> ServletUtil.handleJsonRequest(req, resp, CommentLikeDTO.class, this::likeComment);
            case "/unlike" -> ServletUtil.handleJsonRequest(req, resp, CommentLikeDTO.class, this::unlikeComment);
            default -> {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            ServletUtil.handleGetRequest(req, resp, this::deleteComment);
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
        }
    }
}
