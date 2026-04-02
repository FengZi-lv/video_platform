package org.example.entity;

public class User {
    private Integer id;
    private String account;
    private String password;
    private String username;
    private String status;
    private String bio;
    private Integer coins;

    public User(Integer id, String account, String password, String username, String status, String bio, Integer coins) {
        this.id = id;
        this.account = account;
        this.password = password;
        this.username = username;
        this.status = status;
        this.bio = bio;
        this.coins = coins;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getAccount() { return account; }
    public void setAccount(String account) { this.account = account; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public Integer getCoins() { return coins; }
    public void setCoins(Integer coins) { this.coins = coins; }
}
