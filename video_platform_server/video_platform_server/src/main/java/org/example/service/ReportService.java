package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.ReportDao;
import org.example.dao.UserDao;
import org.example.dao.VideoDao;
import org.example.dto.HandleReportDTO;
import org.example.dto.ReportVideoDTO;
import org.example.dto.ReviewVideoDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.Report;
import org.example.entity.Video;
import org.example.vo.*;

import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

public class ReportService {
    private final ReportDao reportDao;
    private final VideoDao videoDao;
    private final UserDao userDao;

    public ReportService() throws SQLException {
        this.reportDao = new ReportDao();
        this.videoDao = new VideoDao();
        this.userDao = new UserDao();
    }

    /**
     * 举报视频
     */
    public ResultVO reportVideo(ReportVideoDTO dto) throws Exception {
        Report report = new Report(
                null,
                dto.getUserId(),
                dto.getVideo_id(),
                dto.getReason(),
                "reviewing",
                new java.sql.Timestamp(System.currentTimeMillis()),
                dto.getNickname()
        );
        int rows = reportDao.addReport(report);
        return new ResultVO(rows > 0, rows > 0 ? "举报成功" : "举报失败，已举报过");
    }

    /**
     * 查看审核视频
     */
    public VideoListVO getPendingVideos(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        List<Video> videos = videoDao.getAllPendingVideos();
        List<VideoVO> videoArray = videos.stream()
                .map(v -> new VideoVO(
                        v.getId(),
                        v.getTitle(),
                        v.getThumbnailUrl(),
                        v.getLikesCount(),
                        v.getCoinsCount()
                ))
                .toList();
        return new VideoListVO(true, "获取审核视频成功", videoArray, null);
    }

    /**
     * 审核视频
     */
    public ResultVO reviewVideo(ReviewVideoDTO dto) throws Exception {
        int rows = videoDao.updateReviewingVideoStatus(dto.getVideo_id(), dto.getAction());
        if (rows == 0) {
            return new ResultVO(false, "审核失败，视频不存在或已经审核过");
        }
        return new ResultVO(true, "审核成功");
    }

    /**
     * 查看举报列表
     */
    public ReportListVO getReportList(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        List<ReportVO> reportVOList = reportDao.getAllReports().stream().map(report -> new ReportVO(
                report.getId(),
                report.getVideoId(),
                report.getContext(),
                report.getReporterName(),
                report.getStatus()
        )).toList();
        return new ReportListVO(true, "获取举报列表成功", reportVOList);
    }

    /**
     * 处理举报
     */
    public ResultVO handleReport(HandleReportDTO dto) throws Exception {
        String status = "approve".equals(dto.getAction()) ? "pass" : "reject";
        int rows = reportDao.updateStatusReport(new Report(
                dto.getReport_id(),
                0,
                dto.getVideo_id(),
                null,
                dto.getAction(),
                null,
                null
        ));
        if (rows == 0) {
            return new ResultVO(false, "处理举报失败，举报不存在或已经处理过");
        }
        // 举报成功后直接封禁视频
        if (status.equals("pass")) {
            rows = videoDao.updateReviewingVideoStatus(dto.getVideo_id(), "reject");
            if (rows == 0) {
                return new ResultVO(false, "处理举报成功，但是封禁失败，视频不存在或已经审核过");
            }
        }
        return new ResultVO(true, "处理举报成功");
    }

}