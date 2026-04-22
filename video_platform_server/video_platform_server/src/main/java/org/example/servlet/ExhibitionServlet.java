package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.UserPayloadDTO;
import org.example.util.ServletUtil;
import org.example.vo.ResultVO;

import java.io.IOException;

@WebServlet("/api/exhibitions/*")
public class ExhibitionServlet extends HttpServlet {


    @Override
    public void init() throws ServletException {

    }

    /**
     * GET /api/exhibitions
     * 获取漫展演出列表
     */
    private ResultVO getExhibitions(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        String page = req.getParameter("page");
        String type = req.getParameter("type");
        String time = req.getParameter("time");
        return null;
    }

    /**
     * GET /api/exhibitions/{id}
     * 漫展展览详情
     */
    private ResultVO getExhibitionDetail(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {

        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/", "" -> ServletUtil.handleGetRequest(req, resp, this::getExhibitions);
            default -> {
                if (pathInfo.matches("/\\d+")) {
                    ServletUtil.handleGetRequest(req, resp, this::getExhibitionDetail);
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
                }
            }
        }
    }
}
