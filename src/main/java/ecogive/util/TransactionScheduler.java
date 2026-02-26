package ecogive.util;

import ecogive.Controller.ChatEndpoint;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.Transaction;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class TransactionScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        // Chạy tác vụ mỗi 1 giờ
        scheduler.scheduleAtFixedRate(new AutoCompleteTask(), 0, 1, TimeUnit.HOURS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdown();
        }
    }

    class AutoCompleteTask implements Runnable {
        private final TransactionDAO transactionDAO = new TransactionDAO();
        private final ItemDAO itemDAO = new ItemDAO();
        private final UserDAO userDAO = new UserDAO();

        @Override
        public void run() {
            System.out.println("Scheduler: Running auto-complete task for overdue transactions...");
            try {
                // Tìm các giao dịch đã quá 3 ngày
                List<Transaction> overdueTransactions = transactionDAO.findOverdueConfirmedTransactions(3);

                for (Transaction trans : overdueTransactions) {
                    System.out.println("Scheduler: Processing overdue transaction ID: " + trans.getTransactionId());
                    
                    Item item = itemDAO.findById(trans.getItemId());
                    if (item == null) {
                        System.err.println("Scheduler: Item not found for transaction " + trans.getTransactionId());
                        continue;
                    }

                    // 1. Cập nhật trạng thái giao dịch -> COMPLETED
                    boolean transSuccess = transactionDAO.confirmByReceiver(trans.getTransactionId());

                    if (transSuccess) {
                        // 2. Cập nhật trạng thái vật phẩm -> COMPLETED
                        itemDAO.updateStatus(item.getItemId(), ItemStatus.COMPLETED);

                        // 3. Cộng điểm cho người cho
                        if (item.getEcoPoints() != null && item.getEcoPoints().compareTo(BigDecimal.ZERO) > 0) {
                            userDAO.addEcoPoints(item.getGiverId(), item.getEcoPoints());
                        }

                        // 4. Gửi thông báo
                        String sysMsg = "SYSTEM_GIFT:Giao dịch cho vật phẩm '" + item.getTitle() + "' đã tự động hoàn tất sau 3 ngày.";
                        ChatEndpoint.sendSystemMessage(String.valueOf(item.getGiverId()), sysMsg);
                        ChatEndpoint.sendSystemMessage(String.valueOf(trans.getReceiverId()), sysMsg);
                        
                        System.out.println("Scheduler: Successfully completed transaction ID: " + trans.getTransactionId());
                    } else {
                        System.err.println("Scheduler: Failed to update transaction status for ID: " + trans.getTransactionId());
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
