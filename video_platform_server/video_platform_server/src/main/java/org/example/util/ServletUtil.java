package org.example.util;

import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.example.dto.UserPayloadDTO;
import org.example.vo.ResultVO;

import java.io.IOException;

public class ServletUtil {

    public interface PostServiceAction<T, R> {
        R execute(T DTO) throws Exception;
    }

    public interface GetServiceAction<R> {
        R execute(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception;
    }


    /**
     * 通用的 GET 请求带参数处理方法
     * <p>
     * 会将payload的内容也插入
     *
     * @param req    HttpServletRequest
     * @param resp   HttpServletResponse
     * @param action 具体的 Service 业务逻辑方法引用
     */
    public static <R extends ResultVO> void handleGetRequest(
            HttpServletRequest req,
            HttpServletResponse resp,
            GetServiceAction<R> action
    ) {
        try {
            UserPayloadDTO currentUser = (UserPayloadDTO) req.getAttribute("currentUser");
            req.getParameter("currentUser");
            R resultVO = action.execute(currentUser, req);

            if (!resultVO.isSuccess()) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

            resp.getWriter().write(new Gson().toJson(resultVO));

        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\": false, \"message\": \"服务器发生错误\"}");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }


    /**
     * 通用的 JSON 请求处理方法
     * <p>
     * 会将payload的内容也插入
     *
     * @param req      HttpServletRequest
     * @param resp     HttpServletResponse
     * @param dtoClass 请求体要转换json的 DTO 类型
     * @param action   具体的 Service 业务逻辑方法引用
     */
    public static <T extends UserPayloadDTO, R extends ResultVO> void handleJsonRequest(
            HttpServletRequest req,
            HttpServletResponse resp,
            Class<T> dtoClass,
            PostServiceAction<T, R> action
    ) {
        try {

            T reqDTO = new Gson().fromJson(req.getReader(), dtoClass);

            UserPayloadDTO currentUser = (UserPayloadDTO) req.getAttribute("currentUser");
            if (currentUser != null) {
                reqDTO.setUserId(currentUser.getUserId());
                reqDTO.setNickname(currentUser.getNickname());
                reqDTO.setIat(currentUser.getIat());
                reqDTO.setExp(currentUser.getExp());
                reqDTO.setRole(currentUser.getRole());
            }

            R resultVO = action.execute(reqDTO);

            if (!resultVO.isSuccess()) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

            resp.getWriter().write(new Gson().toJson(resultVO));

        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\": false, \"message\": \"服务器发生错误\"}");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }

}
