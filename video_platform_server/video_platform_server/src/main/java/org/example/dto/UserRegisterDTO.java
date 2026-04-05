package org.example.dto;

public class UserRegisterDTO {
    private String username;
    private String password;
    private String nickname;
    private String bio;

    public UserRegisterDTO(String username, String password, String nickname, String bio) {
        this.username = username;
        this.password = password;
        this.nickname = nickname;
        this.bio = bio;
    }

    public String getPassword() {
        return password;
    }

    public String getUsername() {
        return username;
    }

    public String getNickname() {
        return nickname;
    }

    public String getBio() {
        return bio;
    }
}
