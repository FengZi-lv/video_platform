package org.example.entity;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.sql.Timestamp;


public class UserPayload {
    private String userId;
    private Timestamp iat;
    private Timestamp exp;
    private String role;

    /**
     *
     * @param userId 用户Id
     * @param iat    签发时间
     * @param exp    过期时间
     * @param role   用户角色(admin,user,guest,banned)
     */
    public UserPayload(String userId, Timestamp iat, Timestamp exp, String role) {
        this.userId = userId;
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

    public String getUserId() {
        return userId;
    }

    public String toJSON() {
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, (JsonSerializer<Timestamp>) (src, typeOfSrc, context) -> {
                    return new JsonPrimitive(src.getTime());
                })
                .create();
        return gson.toJson(this);
    }
}
