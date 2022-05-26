CREATE VIEW [dbo].[vyuHDTimeEntryPeriodNotification]
AS
SELECT  [intTimeEntryPeriodNotificationId] = Notif.[intTimeEntryPeriodNotificationId]
	   ,[intEntityId]					   = Notif.[intEntityId]
	   ,[intEntityRecipientId]			   = Notif.[intEntityRecipientId]
	   ,[dtmDateCreated]				   = Notif.[dtmDateCreated]
	   ,[dtmDateSent]					   = Notif.[dtmDateSent]
	   ,[ysnSent]						   = Notif.[ysnSent]
	   ,[strWarning]					   = Notif.[strWarning]
	   ,[intConcurrencyId]				   = Notif.[intConcurrencyId]
	   ,[strRecipientFullName]			   = Entity.[strName]
	   ,[strRecipientEmail]				   = Entity.[strEmail]
	   ,[strBillingPeriodRange]			   = FORMAT(TimeEntryPeriodDetail.dtmBillingPeriodStart, 'MM/dd/yyyy') + ' - ' + FORMAT(TimeEntryPeriodDetail.dtmBillingPeriodEnd, 'MM/dd/yyyy')
FROM tblHDTimeEntryPeriodNotification Notif
		INNER JOIN vyuEMEntityContact Entity
ON Entity.[intEntityId] = Notif.[intEntityRecipientId] AND Entity.ysnDefaultContact = 1 
		LEFT JOIN tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
ON TimeEntryPeriodDetail.intTimeEntryPeriodDetailId = Notif.intTimeEntryPeriodDetailId
WHERE Notif.ysnSent = 0 AND
	  Notif.dtmDateSent IS NULL
GO 