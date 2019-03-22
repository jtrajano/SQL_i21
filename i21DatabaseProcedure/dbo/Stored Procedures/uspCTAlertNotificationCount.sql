CREATE PROCEDURE [dbo].[uspCTAlertNotificationCount]
	@intEntityId INT
AS

BEGIN TRY

	DECLARE @NotificationCount TABLE
	(
		intCount	INT,
		strNotificationCount NVARCHAR(50)	
	)

	DECLARE @ErrMsg	NVARCHAR(MAX),
			@intApprovedNotSentCount INT

	INSERT INTO @NotificationCount
	EXEC  [uspCTNotification] 'Empty',@intEntityId,1

	INSERT INTO @NotificationCount
	EXEC  [uspCTNotification] 'Unconfirmed',@intEntityId,1

	INSERT INTO @NotificationCount
	EXEC  [uspCTNotification] 'Unsigned',@intEntityId,1

	INSERT INTO @NotificationCount
	EXEC  [uspCTNotification] 'Unsubmitted',@intEntityId,1

	INSERT INTO @NotificationCount
	EXEC  [uspCTNotification] 'Approved Not Sent',@intEntityId,1

	UPDATE @NotificationCount SET strNotificationCount = 'int'+REPLACE(strNotificationCount,' ','')+'Count',intCount = ISNULL(intCount,0)

	SELECT  ISNULL(intUnsubmittedCount,0)		AS intUnsubmittedCount,
			ISNULL(intEmptyCount,0)				AS intEmptyCount,
			ISNULL(intUnconfirmedCount,0)		AS intUnconfirmedCount,
			ISNULL(intApprovedNotSentCount,0)	AS intApprovedNotSentCount,
			ISNULL(intUnsignedCount,0)			AS intUnsignedCount
	FROM
	@NotificationCount
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