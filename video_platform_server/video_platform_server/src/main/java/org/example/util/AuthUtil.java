package org.example.util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import org.example.dto.UserPayloadDTO;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.util.Base64;

public class AuthUtil {
    private final static String salt = Config.SALT;
    private final static String HEADER = "{\"alg\": \"HS256\",\"typ\": \"JWT\"}";


    private static String generateHS256(String message) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");

        SecretKeySpec secretKeySpec = new SecretKeySpec(
                salt.getBytes(StandardCharsets.UTF_8),
                "HmacSHA256"
        );

        mac.init(secretKeySpec);

        byte[] hashBytes = mac.doFinal(message.getBytes(StandardCharsets.UTF_8));

        return strToBase64(hashBytes);
    }

    private static String strToBase64(byte[] json) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(json);
    }

    private static String base64ToStr(String base64) {
        return new String(Base64.getUrlDecoder().decode(base64), StandardCharsets.UTF_8);
    }   

    public static String hashJWT(UserPayloadDTO payload) throws Exception {
        var header_payload = strToBase64(HEADER.getBytes(StandardCharsets.UTF_8)) + "." + strToBase64(payload.toJSON().getBytes(StandardCharsets.UTF_8));
        var hash = generateHS256(header_payload);
        return header_payload + "." + hash;
    }

    public static UserPayloadDTO verifyToken(String token) {
        if (token == null || token.isEmpty()) {
            return null;
        }
        var parts = token.split("\\.");

        if (parts.length != 3)
            return null;
        var header = parts[0];
        var payload = parts[1];
        var hash = parts[2];


        try {
            var expectedHash = generateHS256(header + "." + payload);
            if (!expectedHash.equals(hash)) return null;
        } catch (Exception e) {
            return null;
        }

        // 验证时间
        UserPayloadDTO userPayloadDTO = parseToken(token);
        if (userPayloadDTO == null) return null;
        if (userPayloadDTO.getExp().before(new Timestamp(System.currentTimeMillis()))) {
            return null;
        }
        return userPayloadDTO;

    }

    private static UserPayloadDTO parseToken(String token) {
        if (token == null || token.isEmpty()) {
            return null;
        }

        var parts = token.split("\\.");

        if (parts.length != 3)
            return null;
        var payload = parts[1];

        try {
            var jsonStr = base64ToStr(payload);
            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(Timestamp.class,
                            (JsonDeserializer<Timestamp>) (json, typeOfT, context) -> {
                                long timeInMillis = json.getAsLong();
                                return new Timestamp(timeInMillis);
                            })
                    .create();

            return gson.fromJson(jsonStr, UserPayloadDTO.class);
        } catch (Exception e) {
            return null;
        }
    }


    public static String generatePwdHash(String pwd) throws Exception {
        return generateHS256("pwd{" + pwd + "}salt{" + salt + '}');
    }
}
