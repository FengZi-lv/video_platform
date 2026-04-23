package org.example.dto;

public class FollowUserDTO extends UserPayloadDTO {
    private Integer following_id;

    public FollowUserDTO() {}

    public FollowUserDTO(Integer following_id) {
        super();
        this.following_id = following_id;
    }

    public Integer getFollowing_id() {
        return following_id;
    }

    public void setFollowing_id(Integer following_id) {
        this.following_id = following_id;
    }
}
