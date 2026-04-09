package org.example.vo;

import java.util.List;

public class ReportListVO extends ResultVO {
    private List<ReportVO> reports;

    public ReportListVO() {}

    public ReportListVO(boolean success, String msg, List<ReportVO> reports) {
        super(success, msg);
        this.reports = reports;
    }

    public List<ReportVO> getReports() {
        return reports;
    }

    public void setReports(List<ReportVO> reports) {
        this.reports = reports;
    }
}
