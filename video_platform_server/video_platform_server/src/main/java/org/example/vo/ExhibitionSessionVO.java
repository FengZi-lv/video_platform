package org.example.vo;

import java.util.List;

public class ExhibitionSessionVO {
    private int id;
    private String name;
    private String time;
    private List<TicketTypeVO> tickets;

    public ExhibitionSessionVO() {}

    public ExhibitionSessionVO(int id, String name, String time, List<TicketTypeVO> tickets) {
        this.id = id;
        this.name = name;
        this.time = time;
        this.tickets = tickets;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public List<TicketTypeVO> getTickets() { return tickets; }
    public void setTickets(List<TicketTypeVO> tickets) { this.tickets = tickets; }
}