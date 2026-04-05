package org.example.dto;

public class UserDeleteAccountDTO extends UserPayloadDTO {
    private String password;

    public UserDeleteAccountDTO() {
    }

    public UserDeleteAccountDTO(Integer userId, String nickname, String role, String password) {
        super(userId, nickname, null, null, role);
        this.password = password;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

}
