package org.example.dto;

import java.util.List;

public class PublishExhibitionDTO extends UserPayloadDTO {
    private String title;
    private String cover;
    private String address;
    private String phone;
    private String type;
    private String description;
    private List<SessionDTO> sessions;

    public PublishExhibitionDTO() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCover() { return cover; }
    public void setCover(String cover) { this.cover = cover; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<SessionDTO> getSessions() { return sessions; }
    public void setSessions(List<SessionDTO> sessions) { this.sessions = sessions; }

    public static class SessionDTO {
        private String name;
        private String time;
        private List<TicketDTO> tickets;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getTime() { return time; }
        public void setTime(String time) { this.time = time; }

        public List<TicketDTO> getTickets() { return tickets; }
        public void setTickets(List<TicketDTO> tickets) { this.tickets = tickets; }
    }

    public static class TicketDTO {
        private String name;
        private String price;
        private Integer quantity;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getPrice() { return price; }
        public void setPrice(String price) { this.price = price; }

        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
    }
}
