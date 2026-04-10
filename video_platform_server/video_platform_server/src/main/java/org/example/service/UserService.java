package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.CheckInDao;
import org.example.dao.VideoDao;
import org.example.dto.*;
import org.example.dao.UserDao;
import org.example.entity.User;
import org.example.util.AuthUtil;
import org.example.vo.*;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import java.sql.SQLException;
import java.util.stream.Collectors;

public class UserService {

    private final UserDao userDao;
    private final VideoDao videoDao;
    private final CheckInDao checkInDao;

    public UserService() throws SQLException {
        videoDao = new VideoDao();
        userDao = new UserDao();
        checkInDao = new CheckInDao();
    }

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

    /**
     * 用户登录
     */
    public LoginVO login(UserLoginDTO userLoginDTO) throws Exception {

        var user = userDao.queryUsersByUsername(userLoginDTO.getUsername());
        if (user.isEmpty()) {
            return new LoginVO(false, "不存在此用户名，或发生错误", null);
        }
        if (!user.get(0).getPassword().equals(
                AuthUtil.generatePwdHash(userLoginDTO.getPassword())
        )) {
            return new LoginVO(false, "密码错误", null);
        }
        // 生成jwt
        var payload = new UserPayloadDTO(
                user.get(0).getId(),
                user.get(0).getNickname(),
                new java.sql.Timestamp(System.currentTimeMillis()),
                // 7天后过期
                new java.sql.Timestamp(System.currentTimeMillis() + 604800000),
                user.get(0).getStatus()
        );

        return new LoginVO(true, "登录成功", AuthUtil.hashJWT(payload));

    }

    /**
     * 用户注册
     */
    public RegisterVO register(UserRegisterDTO userRegisterDTO) throws Exception {
        // 检验用户名密码格式是否正确
        Matcher matcher = EMAIL_PATTERN.matcher(userRegisterDTO.getUsername());
        if (!matcher.matches()) return new RegisterVO(false, "用户名必须是邮箱");
        if (userRegisterDTO.getPassword().length() < 6 || userRegisterDTO.getPassword().length() > 20)
            return new RegisterVO(false, "密码长度必须在6-20位之间");
        if (userRegisterDTO.getNickname().length() < 2 || userRegisterDTO.getNickname().length() > 10)
            return new RegisterVO(false, "昵称长度必须2-10之间");

        var existingUser = userDao.queryUsersByUsername(userRegisterDTO.getUsername());
        if (!existingUser.isEmpty()) {
            return new RegisterVO(false, "用户名已存在");
        }

        var newUser = new User(
                null,
                userRegisterDTO.getUsername(),
                AuthUtil.generatePwdHash(userRegisterDTO.getPassword()),
                userRegisterDTO.getNickname(),
                "active",
                userRegisterDTO.getBio(),
                0,
                0,
                0
        );

        userDao.addUser(newUser);

        return new RegisterVO(true, "注册成功");

    }

    /**
     * 修改密码
     */
    public ResultVO changePassword(UserChangePwdDTO userChangePwdDTO) throws Exception {
        var user = userDao.queryUsersById(userChangePwdDTO.getUserId());
        if (user.isEmpty()) {
            return new ResultVO(false, "不存在此用户名，或发生错误");
        }
        if (!user.get(0).getPassword().equals(
                AuthUtil.generatePwdHash(userChangePwdDTO.getOldPassword())
        )) {
            return new ResultVO(false, "旧密码错误");
        }

        userDao.updateUserPassword(user.get(0).getId(), AuthUtil.generatePwdHash(userChangePwdDTO.getNewPassword()));
        return new ResultVO(true, "密码修改成功");

    }

    /**
     * 注销账号
     */
    public ResultVO deleteAccount(UserDeleteAccountDTO userDeleteAccountDTO) throws Exception {
        var user = userDao.queryUsersById(userDeleteAccountDTO.getUserId());
        if (user.isEmpty()) {
            return new ResultVO(false, "不存在此用户名，或发生错误");
        }
        if (!user.get(0).getPassword().equals(
                AuthUtil.generatePwdHash(userDeleteAccountDTO.getPassword())
        )) {
            return new ResultVO(false, "密码错误");
        }

        userDao.deleteUserById(user.get(0).getId());
        return new ResultVO(true, "账号注销成功");
    }

    /**
     * 修改个人信息
     */
    public ResultVO updateProfile(UpdateProfileDTO updateProfileDTO) throws Exception {
        var effortLinesCount = userDao.updateUserInfoById(new User(
                updateProfileDTO.getUserId(),
                null,
                null,
                updateProfileDTO.getNickname(),
                null,
                updateProfileDTO.getBio(),
                null,
                null,
                null
        ));
        if (effortLinesCount == 0) {
            return new ResultVO(false, "更新失败，用户不存在或发生错误");
        }
        return new ResultVO(true, "个人信息更新成功");
    }

    /**
     * 获取用户信息
     */
    public UserInfoVO getUserInfo(UserPayloadDTO userPayloadDTO, Integer id) throws Exception {
        var user = userDao.queryUsersById(id);
        if (user.isEmpty()) {
            return null;
        }
        var u = user.get(0);

        var videos = videoDao.getUserAllVideoById(u.getId())
                .stream().map(temp_user -> new VideoVO(
                        true,
                        "成功",
                        temp_user.getId(),
                        temp_user.getTitle(),
                        temp_user.getThumbnailUrl(),
                        temp_user.getLikesCount(),
                        temp_user.getCoinsCount()
                )).collect(Collectors.toList());

        return new UserInfoVO(
                true,
                "成功",
                u.getId(),
                u.getNickname(),
                u.getBio(),
                u.getLikes(),
                u.getCoins(),
                u.getStatus(),
                videos
        );
    }

    /**
     * 签到，获得10个硬币
     */
    public ResultVO signIn(UserPayloadDTO userPayloadDTO) throws Exception {
        if (checkInDao.signIn(userPayloadDTO.getUserId()) <= 0) {
            return new ResultVO(false, "签到失败，已经签到过");
        }
        if (userDao.updateUserInfoById(new User(
                userPayloadDTO.getUserId(),
                null,
                null,
                null,
                null,
                null,
                10,
                0,
                0
        )) <= 0) {
            return new ResultVO(false, "签到失败，发生错误");
        }
        return new ResultVO(true, "签到成功，获得10个硬币");
    }

    /**
     * 获取签到记录
     */
    public CheckInRecordVO getSignInHistory(UserPayloadDTO userPayloadDTO) throws Exception {
        return new CheckInRecordVO(
                true,
                "获取成功",
                checkInDao.getAllRecords(userPayloadDTO.getUserId())
        );
    }

    /**
     * 获取所有用户
     */
    public UserListVO getAllUsers(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        var users = userDao.getAllUsers().stream().map(u -> new UserInfoVO(
                true,
                "获取成功",
                u.getId(),
                u.getNickname(),
                u.getBio(),
                u.getLikes(),
                u.getEarn_coins(),
                u.getStatus(),
                null
        )).collect(Collectors.toList());
        return new UserListVO(true, "获取成功", users);
    }

    /**
     * 封禁用户
     */
    public ResultVO banUser(BanUserDTO banUserDTO) throws Exception {
        int rows = userDao.banUserById(banUserDTO.getUser_id());
        if (rows > 0) {
            return new ResultVO(true, "封禁账号成功");
        }
        return new ResultVO(false, "封禁账号失败");
    }
}
