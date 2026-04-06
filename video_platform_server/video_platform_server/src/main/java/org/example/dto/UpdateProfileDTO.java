package org.example.dto;

/**
 * 继承自UserPayloadDTO，已存在nickname
 */
public class UpdateProfileDTO extends UserPayloadDTO {
    private String bio;


    public UpdateProfileDTO() {
    }

    public UpdateProfileDTO(String bio) {
        super(null, null, null, null, null);
        this.bio = bio;
    }


    public String getBio() {
        return bio;
    }


    public void setBio(String bio) {
        this.bio = bio;
    }
}
