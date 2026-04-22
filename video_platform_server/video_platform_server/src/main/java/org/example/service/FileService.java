package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import org.example.dto.UserPayloadDTO;
import org.example.vo.ResultVO;
import org.example.vo.UploadResultVO;
import org.example.vo.ImageUploadResultVO;
import org.example.util.Config;

import java.io.File;
import java.util.UUID;

public class FileService {

    private final String uploadDir;

    public FileService() {
        uploadDir = Config.RES_BASE_PATH;
    }

    /**
     * 保存文件并返回相对路径
     */
    private String saveFile(Part part) throws Exception {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        String fileName = UUID.randomUUID() + "-" + getSubmittedFileName(part);
        part.write(uploadDir + fileName);

        return "/" + fileName;
    }

    /**
     * 上传视频和缩略图
     */
    public ResultVO uploadVideo(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        Part videoPart = req.getPart("video");
        Part thumbnailPart = req.getPart("thumbnail");

        if (videoPart == null || thumbnailPart == null) {
            return new ResultVO(false, "上传视频失败：缺少视频或缩略图文件");
        }

        String videoUrl = saveFile(videoPart);
        String thumbnailUrl = saveFile(thumbnailPart);

        return new UploadResultVO(true, "上传视频成功", videoUrl, thumbnailUrl);
    }

    /**
     * 上传图片
     */
    public ImageUploadResultVO uploadImage(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        Part imagePart = req.getPart("image");

        if (imagePart == null) {
            return new ImageUploadResultVO(false, "上传图片失败：缺少图片文件", null);
        }

        String imageUrl = saveFile(imagePart);

        return new ImageUploadResultVO(true, "上传图片成功", imageUrl);
    }

    private String getSubmittedFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
