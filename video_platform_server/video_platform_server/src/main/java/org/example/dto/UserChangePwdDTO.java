package org.example.dto;

public class UserChangePwdDTO extends UserPayloadDTO {
    private String oldPassword;
    private String newPassword;

    public UserChangePwdDTO() {
    }

    public UserChangePwdDTO(String currentPassword, String updatedPassword) {
        super(null, null, null, null, null);
        this.oldPassword = currentPassword;
        this.newPassword = updatedPassword;
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

}
