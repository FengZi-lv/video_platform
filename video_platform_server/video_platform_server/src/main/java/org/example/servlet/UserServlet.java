package org.example.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.FollowDao;
import org.example.dto.FollowUserDTO;
import org.example.dto.UpdateProfileDTO;
import org.example.dto.UserPayloadDTO;
import org.example.service.FollowService;
import org.example.service.UserService;
import org.example.util.AuthUtil;
import org.example.util.ServletUtil;
import org.example.vo.CheckInRecordVO;
import org.example.vo.ResultVO;
import org.example.vo.UserInfoVO;

import java.io.IOException;

@WebServlet("/api/users/*")
public class UserServlet extends HttpServlet {

    private UserService userService;
    private FollowService followService;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userService = new UserService();
            followService = new FollowService();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize UserService", e);
        }
    }

    /**
     * POST /api/users/profile
     * 修改个人信息
     */
    private ResultVO updateProfile(UpdateProfileDTO updateProfileDTO) throws Exception {
        return userService.updateProfile(updateProfileDTO);
    }

    /**
     * GET /api/users/{id}
     * 获取用户信息
     */
    private UserInfoVO getUserInfo(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return userService.getUserInfo(userPayloadDTO,
                Integer.valueOf(req.getPathInfo().replace("/", ""))
        );
    }

    /**
     * POST /api/users/sign-in
     * 签到，获得10个硬币
     */
    private ResultVO signIn(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return userService.signIn(userPayloadDTO);
    }

    /**
     * GET /api/users/sign-in/history
     * 获取签到记录
     */
    private CheckInRecordVO getSignInHistory(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return userService.getSignInHistory(userPayloadDTO);
    }

    /**
     * POST /api/users/follow
     * 关注用户
     */
    private ResultVO followUser(FollowUserDTO followUserDTO) throws Exception {
        return followService.followUser(followUserDTO);
    }

    /**
     * POST /api/users/unfollow
     * 取消关注
     */
    private ResultVO unfollowUser(FollowUserDTO followUserDTO) throws Exception {
        return followService.unfollowUser(followUserDTO);
    }

    /**
     * GET /api/users/{id}/following
     * 查看关注列表
     */
    private ResultVO getFollowing(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return followService.getFollowing(userPayloadDTO,
                Integer.valueOf(req.getPathInfo().split("/")[1])
        );
    }

    /**
     * GET /api/users/{id}/followers
     * 查看粉丝列表
     */
    private ResultVO getFollowers(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        return followService.getFollowers(userPayloadDTO,
                Integer.valueOf(req.getPathInfo().split("/")[1])
        );
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/sign-in/history" -> ServletUtil.handleGetRequest(req, resp, this::getSignInHistory);
            case null, default -> {
                if (pathInfo != null && pathInfo.matches("/\\d+")) {
                    ServletUtil.handleGetRequest(req, resp, this::getUserInfo);
                } else if (pathInfo != null && pathInfo.matches("/\\d+/following")) {
                    ServletUtil.handleGetRequest(req, resp, this::getFollowing);
                } else if (pathInfo != null && pathInfo.matches("/\\d+/followers")) {
                    ServletUtil.handleGetRequest(req, resp, this::getFollowers);
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
                }
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        switch (pathInfo) {
            case "/profile" -> ServletUtil.handleJsonRequest(req, resp, UpdateProfileDTO.class, this::updateProfile);
            case "/sign-in" -> ServletUtil.handleGetRequest(req, resp, this::signIn);
            case "/follow" -> ServletUtil.handleJsonRequest(req, resp, FollowUserDTO.class, this::followUser);
            case "/unfollow" -> ServletUtil.handleJsonRequest(req, resp, FollowUserDTO.class, this::unfollowUser);
            case null, default -> {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"success\": false, \"msg\": \"API not found\"}");
            }
        }
    }
}
