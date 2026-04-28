package org.example.vo;

import java.util.List;

public class ExhibitionsListVO extends ResultVO {
    private int total;
    private List<ExhibitionVO> exhibitions;

    public ExhibitionsListVO(boolean success, String msg, int total, List<ExhibitionVO> exhibitions) {
        super(success, msg);
        this.total = total;
        this.exhibitions = exhibitions;
    }

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<ExhibitionVO> getExhibitions() {
        return exhibitions;
    }

    public void setExhibitions(List<ExhibitionVO> exhibitions) {
        this.exhibitions = exhibitions;
    }

}
