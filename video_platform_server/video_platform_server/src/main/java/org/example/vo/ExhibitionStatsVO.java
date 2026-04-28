package org.example.vo;

import java.util.List;

public class ExhibitionStatsVO extends ResultVO {

    private int total_revenue;
    private int total_tickets_sold;
    private int total_tickets_verified;
    private List<SessionStatVO> sessions_stats;

    public ExhibitionStatsVO(boolean success, String msg, int total_revenue, int total_tickets_sold, int total_tickets_verified, List<SessionStatVO> sessions_stats) {
        super(success, msg);
        this.total_revenue = total_revenue;
        this.total_tickets_sold = total_tickets_sold;
        this.total_tickets_verified = total_tickets_verified;
        this.sessions_stats = sessions_stats;
    }

    public int getTotal_revenue() {
        return total_revenue;
    }

    public void setTotal_revenue(int total_revenue) {
        this.total_revenue = total_revenue;
    }

    public int getTotal_tickets_sold() {
        return total_tickets_sold;
    }

    public void setTotal_tickets_sold(int total_tickets_sold) {
        this.total_tickets_sold = total_tickets_sold;
    }

    public int getTotalTicketsVerified() {
        return total_tickets_verified;
    }

    public void setTotal_tickets_verified(int total_tickets_verified) {
        this.total_tickets_verified = total_tickets_verified;
    }

    public List<SessionStatVO> getSessions_stats() {
        return sessions_stats;
    }

    public void setSessions_stats(List<SessionStatVO> sessions_stats) {
        this.sessions_stats = sessions_stats;
    }
}