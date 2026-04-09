package org.example.service;

import org.example.dao.CommentDao;
import org.example.dto.CommentActionDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.Comment;
import org.example.vo.CommentVO;
import org.example.vo.ResultVO;

public class CommentService {
    private CommentDao commentDao;

    public CommentService() throws Exception {
        commentDao = new CommentDao();
    }

    public ResultVO postComment(CommentActionDTO dto) throws Exception {
        if (dto.getContent() == null || dto.getContent().trim().isEmpty()) {
            return new ResultVO(false, "评论失败，内容不能为空");
        }
        Comment comment = new Comment(
                null,
                dto.getUserId(),
                0,
                dto.getVideo_id(),
                "none",
                null,
                dto.getParent_id() != null ? dto.getParent_id() : 0,
                dto.getContent()
        );
        int generatedId = commentDao.addComment(comment);
        return new CommentVO(true, "评论成功", generatedId, dto.getContent(), 0, dto.getParent_id(), "none");
    }

    public ResultVO deleteComment(UserPayloadDTO user, int commentId) throws Exception {
        Comment comment = new Comment(
                commentId,
                null,
                null,
                null,
                "del",
                null,
                null,
                null
        );
        commentDao.updateStatusComment(comment);
        return new ResultVO(true, "删除评论成功");
    }
}
