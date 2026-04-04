package org.example.vo;

public class LoginVO extends ResultVO {
    private String token;

    public LoginVO() {
    }

    public LoginVO(boolean success, String msg, String token) {
        super(success, msg);
        this.token = token;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

}

