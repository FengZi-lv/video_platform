package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.OrderDao;
import org.example.dao.TicketDao;
import org.example.dto.HandleRefundDTO;
import org.example.dto.UserPayloadDTO;
import org.example.dto.VerifyTicketDTO;
import org.example.entity.Order;
import org.example.vo.ResultVO;
import org.example.vo.OrderListVO;

import java.sql.SQLException;
import java.util.List;

public class TicketAdminService {

    public TicketAdminService() {}

    public ResultVO getAllTicketOrders(UserPayloadDTO user, HttpServletRequest req) throws Exception {
        try (var orderDao = new OrderDao()) {
            List<Order> orders = orderDao.getAllOrders();
            return new OrderListVO(true, "Success", orders);
        }
    }

    public ResultVO handleTicketRefund(HandleRefundDTO dto) throws Exception {
        try (var orderDao = new OrderDao();
             var ticketDao = new TicketDao(orderDao.getConnection())) {
            
            Order order = orderDao.getOrderById(dto.getOrder_id());
            if (order == null) {
                return new ResultVO(false, "未找到订单");
            }

            if (!"refunding".equals(order.getStatus())) {
                return new ResultVO(false, "订单不在退款状态");
            }

            orderDao.getConnection().setAutoCommit(false);
            try {
                if ("approve".equals(dto.getAction())) {
                    orderDao.updateOrderStatus(dto.getOrder_id(), "refunded");                  // 更新订单为退款
                    ticketDao.refundTicket(dto.getOrder_id());                                  // 更新票为无效
                    orderDao.refundTicketInventory(order.getTicketTypeId(), order.getCount());  // 修改库存为+count
                    orderDao.getConnection().commit();
                    return new ResultVO(true, "已同意退款");
                } else {
                    orderDao.updateOrderStatus(dto.getOrder_id(), "paid");  // 更新订单为已支付
                    orderDao.getConnection().commit();
                    return new ResultVO(true, "已拒绝退款");
                }
            } catch (Exception e) {
                orderDao.getConnection().rollback();
                throw e;
            } finally {
                orderDao.getConnection().setAutoCommit(true);
            }
        }
    }

    public ResultVO verifyTicket(VerifyTicketDTO dto) throws Exception {
        try (var ticketDao = new TicketDao()) {
            int affected = ticketDao.verifyTicket(dto.getTicket_code());
            if (affected > 0) {
                return new ResultVO(true, "门票验证成功");
            } else {
                return new ResultVO(false, "无效或已使用的门票");
            }
        }
    }
}
