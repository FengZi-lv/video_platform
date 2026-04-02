package org.example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;


// @WebServlet 注解定义了访问这个 Servlet 的 URL 路径
@WebServlet("/hello")
public class TestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 设置响应的内容类型和字符编码，防止中文乱码
        response.setContentType("text/html;charset=UTF-8");

        // 获取输出流
        PrintWriter out = response.getWriter();

        // 向浏览器输出简单的 HTML 内容
        out.println("<html>");
        out.println("<head><title>Servlet 测试</title></head>");
        out.println("<body>");
        out.println("<h1>🎉 恭喜！你的 Servlet 运行成功了！</h1>");
        out.println("<p>当前时间: " + new java.util.Date() + "</p>");
        out.println("</body>");
        out.println("</html>");
    }
}