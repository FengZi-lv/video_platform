package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;


/**
 * GET /api/video/thumbnail?name=xx
 */
@WebServlet("/api/video/thumbnail")
public class ImageStreamServlet extends HttpServlet {

    private static final String IMAGE_BASE_PATH = "C:\\Users\\fengz\\Downloads\\uploads\\";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String imageName = request.getParameter("name");

        if (imageName == null || imageName.isEmpty() || imageName.contains("..") || imageName.contains("/") || imageName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image name");
            return;
        }

        File imageFile = new File(IMAGE_BASE_PATH, imageName);
        if (!imageFile.exists() || !imageFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return;
        }

        String mimeType = getServletContext().getMimeType(imageFile.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        response.setContentType(mimeType);

        response.setContentLengthLong(imageFile.length());


        response.setHeader("Cache-Control", "max-age=2592000");

        try {
            Files.copy(imageFile.toPath(), response.getOutputStream());
        } catch (IOException e) {
            System.out.println("Client closed connection " + e.getMessage());
        }
    }
}