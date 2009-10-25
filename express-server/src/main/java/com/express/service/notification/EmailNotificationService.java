package com.express.service.notification;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.express.domain.User;
import com.express.domain.AccessRequest;

@Service("notificationService")
public class EmailNotificationService implements NotificationService {
   
   private final NotificationFactory notificationFactory;
   private final MailSender mailSender;
   private final PropertiesConfiguration config;
   
   @Autowired
   public EmailNotificationService(@Qualifier("mailSender")MailSender mailSender,
                                  @Qualifier("config")PropertiesConfiguration config,
                                  @Qualifier("notificationFactory")NotificationFactory notificationFactory) {
      this.mailSender = mailSender;
      this.notificationFactory = notificationFactory;
      this.config = config;
   }

   public void sendConfirmationNotification(User user) {
      String url = config.getString("applicationUrl") + "/express.html#registerId=" + user.getId();
      mailSender.sendMail(notificationFactory.createConfirmationNotification(user, url));
   }

   public void sendPasswordReminderNotification(User user) {
      mailSender.sendMail(notificationFactory.createPasswordReminderNotification(user));
   }

   public void sendProjectAccessRequestNotification(AccessRequest request, User manager) {
      mailSender.sendMail(notificationFactory.createProjectAccessRequestNotification(
                          request.getRequestor(),request.getProject(), manager));
   }

   public void sendProjectAccessAccept(AccessRequest request) {
      mailSender.sendMail(notificationFactory.createProjectAccessAcceptNotification(
                                                      request.getRequestor(),request.getProject()));
   }

   public void sendProjectAccessReject(AccessRequest request) {
      mailSender.sendMail(notificationFactory.createProjectAccessRejectNotification(
                                                      request.getRequestor(),request.getProject()));
   }
}
