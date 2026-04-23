package org.example.dto;

public class VerifyTicketDTO extends UserPayloadDTO {
    private String ticket_code;

    public VerifyTicketDTO() {}

    public String getTicket_code() {
        return ticket_code;
    }

    public void setTicket_code(String ticket_code) {
        this.ticket_code = ticket_code;
    }
}
