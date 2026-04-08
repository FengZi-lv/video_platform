package org.example.service;

import org.example.dao.CommentDao;
import org.example.dao.CommentLikesDao;
import org.example.dto.CommentLikeDTO;
import org.example.vo.ResultVO;

import java.sql.SQLIntegrityConstraintViolationException;

public class CommentLikesService {
    private CommentLikesDao commentLikesDao;
    private CommentDao commentDao;

    public CommentLikesService() throws Exception {
        commentLikesDao = new CommentLikesDao();
        commentDao = new CommentDao();
    }

    public ResultVO likeComment(CommentLikeDTO dto) throws Exception {
        try {
            int rows = commentLikesDao.addLike(dto.getUserId(), dto.getComment_id());
            if (rows > 0) {
                commentDao.incrementLikes(dto.getComment_id());
                return new ResultVO(true, "点赞评论成功");
            }
            return new ResultVO(false, "点赞评论失败");
        } catch (SQLIntegrityConstraintViolationException e) {
            return new ResultVO(false, "已点赞过");
        }
    }

    public ResultVO unlikeComment(CommentLikeDTO dto) throws Exception {
        int rows = commentLikesDao.deleteLike(dto.getUserId(), dto.getComment_id());
        if (rows > 0) {
            commentDao.decrementLikes(dto.getComment_id());
            return new ResultVO(true, "取消点赞评论成功");
        }
        return new ResultVO(false, "未点赞过");
    }
}
