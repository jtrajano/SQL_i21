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
		UNION
		SELECT COUNT(1) AS intCount, 'intPreshipmentNotYetApproved' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Pre-shipment Sample not yet approved'
		UNION
		SELECT COUNT(1) AS intCount, 'intLateShipmentCount' AS strNotificationCount  FROM vyuCTNotification WHERE strNotificationType = 'Late Shipment'
	)t
	PIVOT
	(
		MIN(intCount) FOR strNotificationCount IN 
		(
			intUnsubmittedCount,
			intEmptyCount,
			intUnconfirmedCount,
			intApprovedNotSentCount,
			intUnsignedCount,
			intPreshipmentNotYetApproved,
			intLateShipmentCount
		)
	)g
