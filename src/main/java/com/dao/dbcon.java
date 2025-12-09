package com.dao;

import java.sql.Connection;
import java.sql.DriverManager;

    public class dbcon {

        private static final String url = "jdbc:mysql://localhost:3306/saas_auth_system";
        private static final String user = "root";
        private static final String password = "6677";

        public static Connection getConnection() {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connection = DriverManager.getConnection(url, user, password);
                return connection;
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        }
    }

