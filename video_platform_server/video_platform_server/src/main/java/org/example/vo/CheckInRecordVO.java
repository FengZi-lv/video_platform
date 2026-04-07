package org.example.vo;

import java.util.List;

public class CheckInRecordVO extends ResultVO {
    private List<String> records;

    public CheckInRecordVO() {
    }

    public CheckInRecordVO(boolean success, String msg, List<String> records) {
        super(success, msg);
        this.records = records;
    }

    public List<String> getRecords() {
        return records;
    }

    public void setRecords(List<String> records) {
        this.records = records;
    }
}
