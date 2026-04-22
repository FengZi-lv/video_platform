package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.util.Config;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.RandomAccessFile;

/**
 * GET /api/file/get-video?name=xxxx.mp4
 */
@WebServlet("/api/file/get-video")
public class VideoStreamServlet extends HttpServlet {

    private static final String VIDEO_BASE_PATH = Config.RES_BASE_PATH;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String videoName = request.getParameter("name");


        if (videoName == null || videoName.isEmpty() || videoName.contains("..") || videoName.contains("/") || videoName.contains("\\")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"msg\": \"Invalid video name\"}");
            return;
        }

        File videoFile = new File(VIDEO_BASE_PATH + videoName);
        if (!videoFile.exists()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"success\": false, \"msg\": \"Video not found\"}");
            return;
        }

        long fileLength = videoFile.length();
        long start = 0;
        long end = fileLength - 1;

        String rangeHeader = request.getHeader("Range");

        response.setHeader("Accept-Ranges", "bytes");
        response.setContentType("video/mp4");

        if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
            String[] range = rangeHeader.substring(6).split("-");
            try {
                start = Long.parseLong(range[0]);
                if (range.length > 1 && !range[1].isEmpty()) {
                    end = Long.parseLong(range[1]);
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
                return;
            }

            // 确保 end 不会超出文件实际大小
            if (end >= fileLength) {
                end = fileLength - 1;
            }

            long contentLength = end - start + 1;
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            response.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
            response.setHeader("Content-Length", String.valueOf(contentLength));
        } else {
            response.setStatus(HttpServletResponse.SC_OK);
            response.setHeader("Content-Length", String.valueOf(fileLength));
        }

        try (RandomAccessFile randomAccessFile = new RandomAccessFile(videoFile, "r");
             OutputStream outputStream = response.getOutputStream()) {

            randomAccessFile.seek(start);

            byte[] buffer = new byte[8192];
            long bytesToRead = end - start + 1;
            int bytesRead;

            while (bytesToRead > 0 && (bytesRead = randomAccessFile.read(buffer, 0, (int) Math.min(buffer.length, bytesToRead))) != -1) {
                outputStream.write(buffer, 0, bytesRead);
                bytesToRead -= bytesRead;
            }

            outputStream.flush();

        } catch (IOException e) {
            System.out.println("Client closed connection " + e.getMessage());
        }
    }
}