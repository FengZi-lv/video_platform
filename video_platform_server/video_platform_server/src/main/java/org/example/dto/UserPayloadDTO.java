package org.example.dto;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.sql.Timestamp;


public class UserPayloadDTO {
    private Integer userId;
    private String nickname;
    private Timestamp iat;
    private Timestamp exp;
    private String role;

    public UserPayloadDTO() {
    }

    /**
     *
     * @param userId 用户Id
     * @param iat    签发时间
     * @param exp    过期时间
     * @param role   用户角色(admin,user,guest,banned)
     */
    public UserPayloadDTO(Integer userId, String nickname, Timestamp iat, Timestamp exp, String role) {
        this.userId = userId;
        this.nickname = nickname;
        this.iat = iat;
        this.exp = exp;
        this.role = role;
    }

    public String getRole() {
        return role;
    }

    public Timestamp getExp() {
        return exp;
    }

    public Timestamp getIat() {
        return iat;
    }

    public Integer getUserId() {
        return userId;
    }

    public String getNickname() {
        return nickname;
    }

    public String toJSON() {
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, (JsonSerializer<Timestamp>) (src, typeOfSrc, context) -> {
                    return new JsonPrimitive(src.getTime());
                })
                .create();
        return gson.toJson(this);
    }


    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public void setIat(Timestamp iat) {
        this.iat = iat;
    }

    public void setExp(Timestamp exp) {
        this.exp = exp;
    }

    public void setRole(String role) {
        this.role = role;
    }

}
