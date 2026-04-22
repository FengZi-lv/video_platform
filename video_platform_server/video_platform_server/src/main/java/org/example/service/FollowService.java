package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.FollowDao;
import org.example.dto.FollowUserDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.User;
import org.example.vo.FollowUserItemVO;
import org.example.vo.FollowUserListVO;
import org.example.vo.ResultVO;

import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

public class FollowService {
    private FollowDao followDao;

    public FollowService() throws SQLException {
        followDao = new FollowDao();
    }

    /**
     * 关注用户
     */
    public ResultVO followUser(FollowUserDTO followUserDTO) throws Exception {
        int followerId = followUserDTO.getUserId();
        int followingId = followUserDTO.getFollowing_id();
        // 检查2个id是否相同
        if (followerId == followingId) {
            return new ResultVO(false, "不能关注自己");
        }
        int res = followDao.follow(followerId, followingId);
        if (res > 0) {
            return new ResultVO(true, "关注成功");
        }
        return new ResultVO(false, "关注失败");
    }

    /**
     * 取消关注
     */
    public ResultVO unfollowUser(FollowUserDTO followUserDTO) throws Exception {
        int followerId = followUserDTO.getUserId();
        int followingId = followUserDTO.getFollowing_id();
        int res = followDao.unfollow(followerId, followingId);
        if (res > 0) {
            return new ResultVO(true, "取消关注成功");
        }
        return new ResultVO(false, "取消关注失败");
    }

    /**
     * 查看关注列表
     */
    public ResultVO getFollowing(UserPayloadDTO userPayloadDTO, Integer id) throws Exception {
        int queryId = id != null ? id : userPayloadDTO.getUserId();
        List<User> followingUsers = followDao.getFollowingUsers(queryId);
        List<FollowUserItemVO> users = followingUsers.stream().map(user -> new FollowUserItemVO(
                user.getId(), user.getNickname(), user.getAvatar_url(), user.getBio()
        )).collect(Collectors.toList());
        return new FollowUserListVO(true, "获取成功", users);
    }

    /**
     * 查看粉丝列表
     */
    public ResultVO getFollowers(UserPayloadDTO userPayloadDTO, Integer id) throws Exception {
        int queryId = id != null ? id : userPayloadDTO.getUserId();
        List<User> followerUsers = followDao.getFollowerUsers(queryId);
        List<FollowUserItemVO> users = followerUsers.stream().map(user -> new FollowUserItemVO(
                user.getId(), user.getNickname(), user.getAvatar_url(), user.getBio()
        )).collect(Collectors.toList());
        return new FollowUserListVO(true, "获取成功", users);
    }
}