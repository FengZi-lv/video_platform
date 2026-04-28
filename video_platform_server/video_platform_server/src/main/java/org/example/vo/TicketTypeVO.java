package org.example.vo;

public class TicketTypeVO {
    private int id;
    private String type_name;
    private String price;
    private int remain_count;

    public TicketTypeVO() {}

    public TicketTypeVO(int id, String type_name, String price, int remain_count) {
        this.id = id;
        this.type_name = type_name;
        this.price = price;
        this.remain_count = remain_count;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getType_name() { return type_name; }
    public void setType_name(String type_name) { this.type_name = type_name; }

    public String getPrice() { return price; }
    public void setPrice(String price) { this.price = price; }

    public int getRemain_count() { return remain_count; }
    public void setRemain_count(int remain_count) { this.remain_count = remain_count; }
}