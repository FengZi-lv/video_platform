package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.ExhibitionDao;
import org.example.dto.PublishExhibitionDTO;
import org.example.dto.UpdateExhibitionDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.Exhibition;
import org.example.entity.ExhibitionSession;
import org.example.entity.ExhibitionStats;
import org.example.entity.TicketType;
import org.example.vo.ExhibitionStatsVO;
import org.example.vo.ResultVO;

import java.sql.SQLException;
import java.sql.Timestamp;

public class ExhibitionService {

    public ExhibitionService() {
    }

    public ResultVO getExhibitionStats(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        String pathInfo = req.getPathInfo();
        String[] parts = pathInfo.split("/");
        int id = Integer.parseInt(parts[2]);

        try (var dao = new ExhibitionDao()) {
            ExhibitionStats stats = dao.getStats(id);
            if (stats == null) {
                return new ResultVO(false, "未找到统计数据");
            }
            return new ExhibitionStatsVO(
                    true,
                    "Success",
                    stats.getExhibitionId(),
                    stats.getTotalTickets(),
                    stats.getSoldTickets(),
                    stats.getVisitedTickets(),
                    stats.getTotalRevenue()
            );
        }
    }

    public ResultVO publishExhibition(PublishExhibitionDTO dto) throws Exception {
        try (var dao = new ExhibitionDao()) {
            Exhibition exh = new Exhibition(
                    null,
                    dto.getTitle(),
                    dto.getCover(),
                    dto.getAddress(),
                    dto.getType(),
                    dto.getPhone(),
                    dto.getDescription(),
                    null
            );

            dao.getConnection().setAutoCommit(false);
            try {
                int exhId = dao.addExhibition(exh);
                if (exhId <= 0) throw new SQLException("Failed to add exhibition");

                if (dto.getSessions() != null) {
                    for (var sDto : dto.getSessions()) {
                        ExhibitionSession session = new ExhibitionSession(
                                null,
                                exhId,
                                sDto.getName(),
                                Timestamp.valueOf(sDto.getTime())
                        );
                        int sessionId = dao.addSession(session);

                        if (sDto.getTickets() != null) {
                            for (var tDto : sDto.getTickets()) {
                                TicketType tt = new TicketType(
                                        null,
                                        sessionId,
                                        tDto.getName(),
                                        Double.parseDouble(tDto.getPrice()),
                                        tDto.getQuantity(),
                                        tDto.getQuantity()
                                );
                                dao.addTicketType(tt);
                            }
                        }
                    }
                }
                dao.getConnection().commit();
                return new ResultVO(true, "发布漫展成功");
            } catch (Exception e) {
                dao.getConnection().rollback();
                throw e;
            } finally {
                dao.getConnection().setAutoCommit(true);
            }
        }
    }

    public ResultVO updateExhibition(UpdateExhibitionDTO dto) throws Exception {
        try (var dao = new ExhibitionDao()) {
            Exhibition exh = new Exhibition(
                    dto.getId(),
                    dto.getTitle(),
                    dto.getCover(),
                    dto.getAddress(),
                    dto.getType(),
                    dto.getPhone(),
                    dto.getDescription(),
                    null
            );

            int affected = dao.updateExhibition(exh);
            if (affected > 0) {
                return new ResultVO(true, "更新漫展成功");
            } else {
                return new ResultVO(false, "未找到漫展");
            }
        }
    }
}
