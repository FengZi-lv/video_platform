package org.example.dto;


public class UpdateExhibitionDTO extends PublishExhibitionDTO {
    private Integer id;

    public UpdateExhibitionDTO() {}
    
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
}
