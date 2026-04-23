package org.example.vo;

public class ExhibitionStatsVO extends org.example.vo.ResultVO {
    private int exhibitionId;
    private int totalTickets;
    private int soldTickets;
    private int visitedTickets;
    private double totalRevenue;

    public ExhibitionStatsVO() {
    }



    public ExhibitionStatsVO(boolean success, String msg, int exhibitionId, int totalTickets, int soldTickets, int visitedTickets, double totalRevenue) {
        super(success, msg);
        this.exhibitionId = exhibitionId;
        this.totalTickets = totalTickets;
        this.soldTickets = soldTickets;
        this.visitedTickets = visitedTickets;
        this.totalRevenue = totalRevenue;
    }

    public int getExhibitionId() {
        return exhibitionId;
    }

    public void setExhibitionId(int exhibitionId) {
        this.exhibitionId = exhibitionId;
    }

    public int getTotalTickets() {
        return totalTickets;
    }

    public void setTotalTickets(int totalTickets) {
        this.totalTickets = totalTickets;
    }

    public int getSoldTickets() {
        return soldTickets;
    }

    public void setSoldTickets(int soldTickets) {
        this.soldTickets = soldTickets;
    }

    public int getVisitedTickets() {
        return visitedTickets;
    }

    public void setVisitedTickets(int visitedTickets) {
        this.visitedTickets = visitedTickets;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }
}
