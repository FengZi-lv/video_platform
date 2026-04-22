package org.example.vo;

public class ImageUploadResultVO extends ResultVO {
    private String image_url;

    public ImageUploadResultVO(boolean success, String msg, String image_url) {
        super(success, msg);
        this.image_url = image_url;
    }

    public String getImage_url() {
        return image_url;
    }
}