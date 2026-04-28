package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.ExhibitionDao;
import org.example.dto.PublishExhibitionDTO;
import org.example.dto.UpdateExhibitionDTO;
import org.example.dto.UserPayloadDTO;
import org.example.entity.Exhibition;
import org.example.entity.ExhibitionSession;

import org.example.entity.TicketType;
import org.example.vo.ExhibitionStatsVO;
import org.example.vo.ExhibitionsListVO;
import org.example.vo.ExhibitionDetailVO;
import org.example.vo.ExhibitionSessionVO;
import org.example.vo.TicketTypeVO;
import org.example.vo.ResultVO;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ExhibitionService {
    private ExhibitionDao exhibitionDao;

    public ExhibitionService() throws SQLException {
        this.exhibitionDao = new ExhibitionDao();
    }

    public ResultVO getExhibitionStats(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        String pathInfo = req.getPathInfo();
        String[] parts = pathInfo.split("/");
        int id = Integer.parseInt(parts[2]);

        try (var dao = new ExhibitionDao()) {
            var stats = dao.getStats(id);
            if (stats == null) {
                return new ResultVO(false, "未找到统计数据");
            }
            return stats;
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
                    null);

            dao.getConnection().setAutoCommit(false);
            try {
                int exhId = dao.addExhibition(exh);
                if (exhId <= 0)
                    throw new SQLException("Failed to add exhibition");

                if (dto.getSessions() != null) {
                    for (var sDto : dto.getSessions()) {
                        String tStr = sDto.getTime();
                        if (tStr != null && tStr.length() == 10) tStr += " 00:00:00";
                        ExhibitionSession session = new ExhibitionSession(
                                null,
                                exhId,
                                sDto.getName(),
                                Timestamp.valueOf(tStr));
                        int sessionId = dao.addSession(session);

                        if (sDto.getTickets() != null) {
                            for (var tDto : sDto.getTickets()) {
                                TicketType tt = new TicketType(
                                        null,
                                        sessionId,
                                        tDto.getName(),
                                        Double.parseDouble(tDto.getPrice()),
                                        tDto.getQuantity(),
                                        tDto.getQuantity());
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
                    null);

            int affected = dao.updateExhibition(exh);
            if (affected > 0) {
                return new ResultVO(true, "更新漫展成功");
            } else {
                return new ResultVO(false, "未找到漫展");
            }
        }
    }

    /**
     * 获取漫展演出列表
     */
    public ResultVO getExhibitions(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        String type = req.getParameter("type");
        int page = Integer.parseInt(req.getParameter("page"));
        String time = req.getParameter("time");

        int offset = (page - 1) * 10;

        ExhibitionsListVO listVO = exhibitionDao.getExhibitionsList(type, time, offset);
        return listVO;
    }

    /**
     * 漫展展览详情
     */
    public ResultVO getExhibitionDetail(UserPayloadDTO userPayloadDTO, HttpServletRequest req) throws Exception {
        String pathInfo = req.getPathInfo();
        String[] parts = pathInfo.split("/");
        if (parts.length > 1) {
            int exhId = Integer.parseInt(parts[1]);
            Exhibition exh = exhibitionDao.getExhibitionById(exhId);
            if (exh == null) {
                return new ResultVO(false, "未找到该漫展");
            }
            
            ExhibitionDetailVO detailVO = new ExhibitionDetailVO(
                true, "获取成功",
                exh.getId(), exh.getTitle(), exh.getCover(), exh.getAddress(),
                exh.getType(), exh.getPhone(), exh.getDescription(),
                new ArrayList<>()
            );

            List<ExhibitionSession> sessions = exhibitionDao.getSessionsByExhibitionId(exhId);
            for (ExhibitionSession session : sessions) {
                ExhibitionSessionVO sessionVO = new ExhibitionSessionVO();
                sessionVO.setId(session.getId());
                sessionVO.setName(session.getSessionName());
                if (session.getSessionTime() != null) {
                    sessionVO.setTime(session.getSessionTime().toString().substring(0, 19));
                }
                sessionVO.setTickets(new ArrayList<>());
                
                List<TicketType> tickets = exhibitionDao.getTicketTypesBySessionId(session.getId());
                for (TicketType ticket : tickets) {
                    TicketTypeVO ticketVO = new TicketTypeVO();
                    ticketVO.setId(ticket.getId());
                    ticketVO.setType_name(ticket.getTypeName());
                    ticketVO.setPrice(String.format("%.2f", ticket.getPrice()));
                    ticketVO.setRemain_count(ticket.getRemainCount());
                    sessionVO.getTickets().add(ticketVO);
                }
                detailVO.getSessions().add(sessionVO);
            }
            return detailVO;
        }
        return new ResultVO(false, "参数错误");
    }

}
