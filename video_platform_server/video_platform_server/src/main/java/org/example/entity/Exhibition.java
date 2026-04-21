package org.example.entity;

import java.sql.Timestamp;

public class Exhibition {
    private Integer id;
    private String title;
    private String cover;
    private String address;
    private String type;
    private String phone;
    private String description;
    private Timestamp createDate;

    public Exhibition() {}

    public Exhibition(Integer id, String title, String cover, String address, String type, String phone, String description, Timestamp createDate) {
        this.id = id;
        this.title = title;
        this.cover = cover;
        this.address = address;
        this.type = type;
        this.phone = phone;
        this.description = description;
        this.createDate = createDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCover() { return cover; }
    public void setCover(String cover) { this.cover = cover; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreateDate() { return createDate; }
    public void setCreateDate(Timestamp createDate) { this.createDate = createDate; }
}