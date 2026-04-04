package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.UserLoginDTO;
import org.example.dto.UserPayloadDTO;
import org.example.dao.UserDao;
import org.example.util.AuthUtil;
import org.example.vo.LoginVO;

import java.sql.SQLException;

public class UserService {

    private final UserDao userDao;

    public UserService() throws SQLException {
        userDao = new UserDao();
    }

    /**
     * 用户登录
     */
    public LoginVO login(UserLoginDTO userLoginDTO) {
        try {
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
        } catch (Exception e) {
            e.printStackTrace();
            return new LoginVO(false, "发生错误", null);
        }
    }

    /**
     * 用户注册
     */
    public void register(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * 修改密码
     */
    public void changePassword(HttpServletRequest req, HttpServletResponse resp) {

    }

    /**
     * 注销账号
     */
    public void deleteAccount(HttpServletRequest req, HttpServletResponse resp) {

    }
}

