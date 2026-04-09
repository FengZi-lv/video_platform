package org.example.vo;

import java.util.List;

public class UserListVO extends ResultVO {
    private List<UserInfoVO> users;

    public UserListVO() {
    }

    public UserListVO(boolean success, String msg, List<UserInfoVO> users) {
        super(success, msg);
        this.users = users;
    }

    public List<UserInfoVO> getUsers() {
        return users;
    }

    public void setUsers(List<UserInfoVO> users) {
        this.users = users;
    }
}
