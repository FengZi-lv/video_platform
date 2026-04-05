package org.example.service;

import org.example.dto.*;
import org.example.dao.UserDao;
import org.example.entity.User;
import org.example.util.AuthUtil;
import org.example.vo.LoginVO;
import org.example.vo.RegisterVO;
import org.example.vo.ResultVO;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import java.sql.SQLException;

public class UserService {

    private final UserDao userDao;

    public UserService() throws SQLException {
        userDao = new UserDao();
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
}

