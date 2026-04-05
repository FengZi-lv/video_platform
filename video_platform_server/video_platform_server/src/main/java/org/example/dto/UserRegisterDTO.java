package org.example.dto;

public class UserRegisterDTO extends UserPayloadDTO {
    private String username;
    private String password;
    private String bio;

    public UserRegisterDTO() {
    }

    public UserRegisterDTO(String username, String password, String nickname, String bio) {
        super(null, nickname, null, null, null);
        this.username = username;
        this.password = password;
        this.bio = bio;
    }

    public String getPassword() {
        return password;
    }

    public String getUsername() {
        return username;
    }


    public String getBio() {
        return bio;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }
}
