package org.example.vo;

import java.util.List;

public class FollowUserListVO extends ResultVO {
    private List<FollowUserItemVO> users;

    public FollowUserListVO() {
    }

    public FollowUserListVO(boolean success, String msg, List<FollowUserItemVO> users) {
        super(success, msg);
        this.users = users;
    }

    public List<FollowUserItemVO> getUsers() {
        return users;
    }

    public void setUsers(List<FollowUserItemVO> users) {
        this.users = users;
    }
}
