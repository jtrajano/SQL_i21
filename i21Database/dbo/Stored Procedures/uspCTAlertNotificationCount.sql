CREATE PROCEDURE [dbo].[uspCTAlertNotificationCount]
	@intEntityId INT
AS

BEGIN TRY

	DECLARE @NotificationTypeEvent TABLE
	(
		intEventId	INT,
		strNotificationType NVARCHAR(50)	
	)

	DECLARE @ErrMsg	NVARCHAR(MAX)

	INSERT INTO @NotificationTypeEvent
	SELECT	intEventId,
			CASE	WHEN	strEventName =  'Unconfirmed contract'				THEN	'Unconfirmed'
					WHEN	strEventName =  'Contract without a sequence'		THEN	'Empty'	
					WHEN	strEventName =	'Unsubmitted Contract Alert'		THEN	'Unsubmitted'
					WHEN	strEventName =  'Unsigned Contract Alert'			THEN	'Unsigned'
					WHEN	strEventName =  'Approved Contract Mail Not Sent'	THEN	'Approved Not Sent'
			END
	FROM tblCTEvent

	SELECT *
	FROM
	(
		SELECT COUNT(1) AS intCount, 'intApprovedNotSentCount' AS strNotificationCount  
		FROM vyuCTNotification		NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strNotificationType
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode) AND NF.strNotificationType = 'Approved Not Sent'

		UNION

		SELECT COUNT(1) AS intCount, 'intEmptyCount' AS strNotificationCount  
		FROM vyuCTNotification NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strNotificationType
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode) AND NF. strNotificationType = 'Empty'

		UNION

		SELECT COUNT(1) AS intCount, 'intUnconfirmedCount' AS strNotificationCount  
		FROM vyuCTNotification NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strNotificationType
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode) AND NF. strNotificationType = 'Unconfirmed'

		UNION

		SELECT COUNT(1) AS intCount, 'intUnsignedCount' AS strNotificationCount  
		FROM vyuCTNotification NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strNotificationType
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode) AND NF. strNotificationType = 'Unsigned'

		UNION

		SELECT COUNT(1) AS intCount, 'intUnsubmittedCount' AS strNotificationCount  
		FROM vyuCTNotification NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strNotificationType
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode) AND NF. strNotificationType = 'Unsubmitted'
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

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH