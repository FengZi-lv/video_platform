package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.UserPayloadDTO;
import org.example.service.FileService;
import org.example.vo.ImageUploadResult;

import java.io.IOException;

@WebServlet("/api/files/*")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB 配置阈值
        maxFileSize = 1024 * 1024 * 10,       // 10MB 最大单个文件大小
        maxRequestSize = 1024 * 1024 * 15     // 15MB 最大整体请求大小
)
public class FileServlet extends HttpServlet {
    private FileService fileService;

    @Override
    public void init() throws ServletException {
        super.init();
        fileService = new FileService();
    }

    /**
     * POST /api/files/upload/image
     * 上传图片 (multipart/form-data)
     */
    private void uploadImage(HttpServletRequest req, HttpServletResponse resp) {
        try {
            ImageUploadResult result = fileService.uploadImage((UserPayloadDTO) req.getAttribute("currentUser"), req);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            try {
                e.printStackTrace();
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\": false, \"msg\": \"服务器发生错误\"}");
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if ("/upload/image".equals(pathInfo)) {
            uploadImage(req, resp);
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
        }
    }
}