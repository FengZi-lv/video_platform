package org.example.dto;


public class UpdateProfileDTO extends UserPayloadDTO {
    private String bio;
    private String avatar;

    public UpdateProfileDTO() {
    }

    public UpdateProfileDTO(String bio, String avatar) {
        super(null, null, null, null, null);
        this.bio = bio;
        this.avatar = avatar;
    }


    public String getBio() {
        return bio;
    }


    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }
}
