package org.example.dto;

public class BanUserDTO extends UserPayloadDTO {
    private Integer user_id;

    public BanUserDTO() {
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }
}

