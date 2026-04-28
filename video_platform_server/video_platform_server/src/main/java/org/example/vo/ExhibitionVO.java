package org.example.vo;

import java.util.List;

public class ExhibitionVO {
    private int id;
    private String title;
    private String cover;
    private String address;
    private String type;
    private String start_time;
    private String end_time;
    private String price_min;

    public ExhibitionVO() {}

    public ExhibitionVO(int id, String title, String cover, String address, String type, String start_time, String end_time, String price_min) {
        this.id = id;
        this.title = title;
        this.cover = cover;
        this.address = address;
        this.type = type;
        this.start_time = start_time;
        this.end_time = end_time;
        this.price_min = price_min;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCover() { return cover; }
    public void setCover(String cover) { this.cover = cover; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getStart_time() { return start_time; }
    public void setStart_time(String start_time) { this.start_time = start_time; }
    public String getEnd_time() { return end_time; }
    public void setEnd_time(String end_time) { this.end_time = end_time; }
    public String getPrice_min() { return price_min; }
    public void setPrice_min(String price_min) { this.price_min = price_min; }
}
