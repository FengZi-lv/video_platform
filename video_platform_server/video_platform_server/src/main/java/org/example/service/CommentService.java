package org.example.service;

import org.example.dao.CommentDao;
import org.example.dao.VideoDao;
import org.example.dto.CommentActionDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.Comment;
import org.example.entity.Video;
import org.example.util.Config;
import org.example.vo.CommentVO;
import org.example.vo.ResultVO;

import java.io.File;

public class CommentService {
    private CommentDao commentDao;
    private VideoDao videoDao;

    public CommentService() throws Exception {
        commentDao = new CommentDao();
        videoDao = new VideoDao();
    }

    public ResultVO postComment(CommentActionDTO dto) throws Exception {
        if (dto.getContent() == null || dto.getContent().trim().isEmpty()) {
            return new ResultVO(false, "评论失败，内容不能为空");
        }

        // 检查图片是否存在
        String physicalSrc = dto.getImage_url() != null ?
                dto.getImage_url().replace("/", Config.RES_BASE_PATH) : "";

        if (dto.getImage_url() != null && !dto.getImage_url().isEmpty() && !new File(physicalSrc).exists()) {
            return new ResultVO(false, "图片不存在");
        }

        Comment comment = new Comment(
                null,
                dto.getUserId(),
                0,
                dto.getVideo_id(),
                "none",
                null,
                dto.getParent_id() != null ? dto.getParent_id() : 0,
                dto.getContent(),
                dto.getImage_url()
        );
        int generatedId = commentDao.addComment(comment);
        return new CommentVO(true, "评论成功", generatedId, dto.getContent(), 0, dto.getParent_id(), "none", false, dto.getUserId(), dto.getImage_url());
    }

    public ResultVO deleteComment(UserPayloadDTO user, int commentId) throws Exception {
        Comment existingComment = commentDao.getCommentById(commentId);
        if (existingComment == null || "del".equals(existingComment.getStatus())) {
            return new ResultVO(false, "删除评论失败，评论不存在");
        }

        boolean isAuthorized = false;
        if (existingComment.getUserId().equals(user.getUserId())) {
            // 如果是发表评论的用户
            isAuthorized = true;
        } else {
            Video video = videoDao.getVideoById(existingComment.getVideoId());
            if (video != null && video.getUploaderId().equals(user.getUserId())) {
                // 如果是视频的上传者
                isAuthorized = true;
            }
        }

        if (!isAuthorized) {
             return new ResultVO(false, "删除评论失败，无权删除");
        }

        Comment comment = new Comment(
                commentId,
                null,
                null,
                null,
                "del",
                null,
                null,
                null,
                null
        );
        commentDao.updateStatusComment(comment);
        return new ResultVO(true, "删除评论成功");
    }
}
