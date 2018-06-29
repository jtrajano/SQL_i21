CREATE VIEW [dbo].[vyuCTAlertNotificationCount]

AS
	
	SELECT *
	FROM
	(
		SELECT COUNT(1) AS intCount, 'intApprovedNotSentCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Approved Not Sent'
		UNION
		SELECT COUNT(1) AS intCount, 'intEmptyCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Empty'
		UNION
		SELECT COUNT(1) AS intCount, 'intUnconfirmedCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Unconfirmed'
		UNION
		SELECT COUNT(1) AS intCount, 'intUnsignedCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Unsigned'
		UNION
		SELECT COUNT(1) AS intCount, 'intUnsubmittedCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Unsubmitted'
	)t
	PIVOT
	(
		MIN(intCount) FOR strNotificationCount IN 
		(
			intUnsubmittedCount,
			intEmptyCount,
			intUnconfirmedCount,
			intApprovedNotSentCount,
			intUnsignedCount
		)
	)g