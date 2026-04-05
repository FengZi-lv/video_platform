package org.example.util;

import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.example.vo.ResultVO;

import java.io.IOException;

public class ServletUtil {

    public interface ServiceAction<T, R> {
        R execute(T DTO) throws Exception;
    }

    /**
     * 通用的 JSON 请求处理方法
     *
     * @param req      HttpServletRequest
     * @param resp     HttpServletResponse
     * @param dtoClass 请求体要转换json的 DTO 类型
     * @param action   具体的 Service 业务逻辑方法引用
     */
    public static  <T, R extends ResultVO> void handleJsonRequest(
            HttpServletRequest req,
            HttpServletResponse resp,
            Class<T> dtoClass,
            ServiceAction<T, R> action
    ) {
        try {

            T reqDTO = new Gson().fromJson(req.getReader(), dtoClass);

            R resultVO = action.execute(reqDTO);

            if (!resultVO.isSuccess()) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(new Gson().toJson(resultVO));

        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "服务器出错");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }

}
