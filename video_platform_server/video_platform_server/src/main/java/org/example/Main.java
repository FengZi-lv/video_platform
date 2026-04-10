package org.example;


import org.example.util.AuthUtil;

public class Main {
    static void main() throws Exception {
        IO.println(AuthUtil.generatePwdHash("123456"));
    }
}
