CREATE PROCEDURE uspSMInterCompanyCopyMessagingDetails
	@intSourceTransactionId INT,
	@intDestinationTransactionId INT,
	@intDestinationCompanyId INT = NULL
AS
BEGIN

	BEGIN TRY

		BEGIN TRANSACTION
		PRINT('---------------START COPY INTER COMPANY RECORDS FOR MESSAGING---------------')

		--START CREATE TEMPOPARY TABLES
		IF OBJECT_ID('tempdb..#TempActivity') IS NOT NULL
			DROP TABLE #TempActivity
	
		CREATE TABLE #TempActivity
		(
			[intActivityId]			[int] NOT NULL,
			[intTransactionId]		[int] NULL,
			[strType]				[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
			[strSubject]			[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
			[intEntityContactId]	[int] NULL, 
			[intEntityId]			[int] NULL, 
			[intCompanyLocationId]	[int] NULL, 
			[dtmStartDate]			[datetime] NULL, 
			[dtmEndDate]			[datetime] NULL, 
			[dtmStartTime]			[datetime] NULL, 
			[dtmEndTime]			[datetime] NULL, 
			[ysnAllDayEvent]		[bit] NULL,
			[ysnRemind]				[bit] NULL,
			[strReminder]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strStatus]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strPriority]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strCategory]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[intAssignedTo]			[int] NULL,
			[strActivityNo]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strRelatedTo]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strRecordNo]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strLocation]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strDetails]			[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
			[strShowTimeAs]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[ysnPrivate]			[bit] NULL,
			[ysnPublic]				[bit] NULL,
			[dtmCreated]			[datetime] NULL, 
			[dtmModified]			[datetime] NULL, 
			[intCreatedBy]			[int] NULL,
			[strImageId]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[strMessageType]		NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
			[strFilter]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			[ysnDismiss]			[bit] NULL,
			[intActivitySourceId]	[int] NULL
		)

		IF OBJECT_ID('tempdb..#TempComment') IS NOT NULL
			DROP TABLE #TempComment

		CREATE TABLE #TempComment
		(
			[intCommentId]		INT,
			[strComment]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			[strScreen]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[strRecordNo]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[dtmAdded]			DATETIME DEFAULT (GETDATE()) NULL,
			[dtmModified]		DATETIME DEFAULT (GETDATE()) NULL,
			[ysnPublic]			BIT NULL,
			[ysnEdited]			BIT NULL,
			[intEntityId]		INT NULL,
			[intTransactionId]	INT NULL,
			[intActivityId]		INT NULL
		)

		IF OBJECT_ID('tempdb..#TempTransferLog') IS NOT NULL
			DROP TABLE #TempTransferLog

		CREATE TABLE #TempTransferLog
		(
			[intInterCompanyTransferLogForCommentId]	INT,
			[intSourceRecordId]							INT,
			[intDestinationRecordId]					INT,
			[intDestinationCompanyId]					INT NULL --TODO

		)
	
		IF OBJECT_ID('tempdb..#TempActivityAttendee') IS NOT NULL
			DROP TABLE #TempActivityAttendee

		CREATE TABLE #TempActivityAttendee
		(
			[intActivityAttendeeId]		INT,
			[intActivityId]				INT,
			[intEntityId]				INT,
			[ysnAddCalendarEvent]		BIT

		)

		IF OBJECT_ID('tempdb..#TempTransferLogForUpdating') IS NOT NULL
			DROP TABLE #TempTransferLogForUpdating

		CREATE TABLE #TempTransferLogForUpdating
		(
			[intInterCompanyTransferLogForCommentId]	INT,
			[intSourceRecordId]							INT,
			[intDestinationRecordId]					INT,
			[intDestinationCompanyId]					INT NULL --TODO
		)

		--END CREATE TEMPOPARY TABLES

		DECLARE @intActivityId INT = 0;
		DECLARE @intNewActivityId INT = 0;
		DECLARE @strNewActivityNo NVARCHAR(50);
		DECLARE @intCommentId INT = 0;
		DECLARE @intNewCommentId INT = 0;
		DECLARE @intActivityAttendeeId INT = 0;
		DECLARE @intNewActivityAttendeeId INT = 0;
		DECLARE @intNotificationId INT = 0;
		DECLARE @intNewNotificationId INT = 0;

		--TODO OTHER DATABASE INNER JOIN

		--Get all activities in intSourceRecordId when the source transaction id and destination transaction id are equals
		INSERT INTO #TempTransferLog ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
		SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId]
		FROM tblSMInterCompanyTransferLogForComment a
		INNER JOIN tblSMActivity b ON a.intSourceRecordId = b.intActivityId
		INNER JOIN tblSMActivity c ON a.intDestinationRecordId = c.intActivityId
		WHERE (
			b.intTransactionId = @intSourceTransactionId AND
			c.intTransactionId = @intDestinationTransactionId AND
			a.intDestinationCompanyId = @intDestinationCompanyId AND
			a.strTable = 'tblSMActivity'
		)

		--Get all activities in intDestinationRecordId when the destination transaction id is equal to @intSourceTransactionId and source transaction is equal to @intDestinationTransactionId
		INSERT INTO #TempTransferLog ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
		SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId]
		FROM tblSMInterCompanyTransferLogForComment a
		INNER JOIN tblSMActivity b ON a.intSourceRecordId = b.intActivityId
		INNER JOIN tblSMActivity c ON a.intDestinationRecordId = c.intActivityId
		WHERE (
			c.intTransactionId = @intSourceTransactionId AND
			b.intTransactionId = @intDestinationTransactionId AND
			a.intDestinationCompanyId = @intDestinationCompanyId AND
			a.strTable = 'tblSMActivity'
		)

		--GET ALL ACTIVITIES FROM SOURCE TRANSACTION ID--
		INSERT INTO #TempActivity(
			[intActivityId], [intTransactionId], [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
			[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strActivityNo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
			[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId]
		)
		SELECT
			[intActivityId], [intTransactionId], [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
			[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strActivityNo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
			[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId]
		FROM tblSMActivity
		WHERE intTransactionId = @intSourceTransactionId AND 
		intActivityId NOT IN (
			SELECT intSourceRecordId FROM #TempTransferLog
		)
	
		---------------------------------------------------------copy non existing activity---------------------------------------------------------
		WHILE EXISTS(SELECT 1 FROM #TempActivity)
		BEGIN		
			SELECT TOP 1 @intActivityId = intActivityId FROM #TempActivity
		
			--Copy tblSMActivity and all entries in tblSMAttendee, tblSMComment, and tblSMNotification
			INSERT INTO tblSMActivity
			(
				[intTransactionId], [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
				[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
				[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId]
			)
			SELECT TOP 1
				@intDestinationTransactionId, [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
				[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
				[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId]
			FROM #TempActivity
					
			SET @intNewActivityId = SCOPE_IDENTITY()
			SELECT @strNewActivityNo = strActivityNo FROM tblSMActivity WHERE intActivityId = @intNewActivityId

			INSERT INTO tblSMInterCompanyTransferLogForComment (
				[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
			)
			VALUES ('tblSMActivity', @intActivityId, @intNewActivityId, @intDestinationCompanyId);
					
			----------------------------------------ACTIVITY ATTENDEE----------------------------------------
			INSERT INTO #TempActivityAttendee (
				[intActivityAttendeeId], [intActivityId], [intEntityId], [ysnAddCalendarEvent]
			)
			SELECT [intActivityAttendeeId], [intActivityId], [intEntityId], [ysnAddCalendarEvent]
			FROM tblSMActivityAttendee
			WHERE intActivityId = @intActivityId
			
			--copy attendee through looping
			WHILE EXISTS(SELECT 1 FROM #TempActivityAttendee)
			BEGIN
				SELECT TOP 1 @intActivityAttendeeId = intActivityAttendee FROM #TempActivityAttendee
						
				INSERT INTO tblSMActivityAttendee(
					[intActivityId], [intEntityId], [ysnAddCalendarEvent]
				)
				SELECT TOP 1 @intNewActivityId, [intEntityId], [ysnAddCalendarEvent]
				FROM #TempActivityAttendee

				SET @intNewActivityAttendeeId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
				)
				VALUES ('tblSMActivityAttendee', @intActivityAttendeeId, @intNewActivityAttendeeId, @intDestinationCompanyId);

				DELETE FROM #TempActivityAttendee where intActivityAttendeeId = @intActivityAttendeeId
			END

			----------------------------------------ACTIVITY COMMENTS----------------------------------------
			INSERT INTO #TempComment(
				[intCommentId], [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
			)
			SELECT [intCommentId], [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
			FROM tblSMComment
			WHERE intActivityId = @intActivityId

			--copy comments through looping
			WHILE EXISTS(SELECT 1 FROM #TempComment)
			BEGIN
				SELECT TOP 1 @intCommentId = intCommentId FROM #TempComment

				INSERT INTO tblSMComment (
					[strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
				)
				SELECT TOP 1 [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], @intNewActivityId
				FROM #TempComment

				SET @intNewCommentId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
				)
				VALUES ('tblSMComment', @intCommentId, @intNewCommentId, NULL)

				----------------------------------------ACTIVITY COMMENTS NOTIFICATION----------------------------------------
				--copy all notification for this comment, greater than one, due to we can mention any user
				IF EXISTS(SELECT 1 FROM tblSMNotification WHERE  intCommentId = @intCommentId)
				BEGIN
					INSERT INTO #TempNotification (
						[intNotificationId], [intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
					)
					SELECT [intNotificationId], [intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
					FROM tblSMNotification
					WHERE intCommentId = @intCommentId

					--copy notification through looping
					WHILE EXISTS(SELECT 1 FROM #TempNotification)
					BEGIN
						--copy individual notification
						SELECT TOP 1 @intNotificationId = intNoficationId FROM #TempNotification

						INSERT INTO tblSMNotification(
							[intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						)
						SELECT TOP 1 @intNewCommentId, @intNewActivityId, @strNewActivityNo, [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						FROM #TempNotification

						SET @intNewNotificationId = SCOPE_IDENTITY();

						INSERT INTO tblSMInterCompanyTransferLogForComment (
							[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
						)
						VALUES ('tblSMNotification', @intNotificationId, @intNewNotificationId, @intDestinationCompanyId);

						DELETE FROM #TempNotification where intNotificationId = @intNotificationId
					END
					--end notification through looping
				END
				DELETE FROM #TempComment where intCommentId = @intCommentId
			END
			--end copy comments
			DELETE FROM #TempActivity WHERE intActivityId = @intActivityId
		END
		---------------------------------------------------------end copy non existing activity---------------------------------------------------------


		---------------------------------------------------------update existing activity---------------------------------------------------------
		DELETE FROM #TempActivityAttendee;
		DELETE FROM #TempComment;
		DELETE FROM #TempNotification;

		DECLARE @intTransferLogId INT = 0;
		DECLARE @intSourceActivityId INT = 0;
		DECLARE @intDestinationActivityId INT = 0;

		WHILE EXISTS(SELECT 1 FROM #TempTransferLog)
		BEGIN
			SELECT TOP 1 
			@intTransferLogId = intInterCompanyTransferLogForCommentId, 
			@intSourceActivityId = intSourceRecordId, 
			@intDestinationActivityId = intDestinationRecordId 
			FROM #TempTransferLog

			SELECT @strNewActivityNo = strActivityNo FROM tblSMActivity where intActivityId = @intDestinationActivityId
		
			--Update tblSMAttendee, tblSMComment, and tblSMNotification
		
			----------------------------------------ACTIVITY ATTENDEE----------------------------------------
			--Get all attendee in intSourceRecordId when the source activity id and destination activity id are equals
			INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
			SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId]
			FROM tblSMInterCompanyTransferLogForComment a
			INNER JOIN tblSMActivityAttendee b ON a.intSourceRecordId = b.intActivityAttendeeId
			INNER JOIN tblSMActivityAttendee c ON a.intDestinationRecordId = c.intActivityAttendeeId
			WHERE (
				b.intActivityId = @intSourceActivityId AND
				c.intActivityId = @intDestinationActivityId AND
				a.intDestinationCompanyId = @intDestinationCompanyId AND
				a.strTable = 'tblSMActivityAttendee'
			)

			--Get all attendee in intDestinationRecordId when the destination activity id is equal to @intSourceActivityId and source transaction is equal to @intDestinationActivityId
			INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
			SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId]
			FROM tblSMInterCompanyTransferLogForComment a
			INNER JOIN tblSMActivityAttendee b ON a.intSourceRecordId = b.intActivityAttendeeId
			INNER JOIN tblSMActivityAttendee c ON a.intDestinationRecordId = c.intActivityAttendeeId
			WHERE (
				c.intActivityId = @intSourceActivityId AND
				b.intActivityId = @intDestinationActivityId AND
				a.intDestinationCompanyId = @intDestinationCompanyId AND
				a.strTable = 'tblSMActivityAttendee'
			)

			INSERT INTO #TempActivityAttendee (
				[intActivityAttendeeId], [intActivityId], [intEntityId], [ysnAddCalendarEvent]
			)
			SELECT [intActivityAttendeeId], [intActivityId], [intEntityId], [ysnAddCalendarEvent]
			FROM tblSMActivityAttendee
			WHERE intActivityId = @intSourceActivityId AND
			intActivityAttendeeId NOT IN (
				SELECT intSourceRecordId FROM #TempTransferLogForUpdating
			)
			
			--copy attendee through looping
			WHILE EXISTS(SELECT 1 FROM #TempActivityAttendee)
			BEGIN
				SELECT TOP 1 @intActivityAttendeeId = intActivityAttendeeI FROM #TempActivityAttendee
						
				INSERT INTO tblSMActivityAttendee(
					[intActivityId], [intEntityId], [ysnAddCalendarEvent]
				)
				SELECT TOP 1 @intDestinationActivityId, [intEntityId], [ysnAddCalendarEvent]
				FROM #TempActivityAttendee

				SET @intNewActivityAttendeeId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
				)
				VALUES ('tblSMActivityAttendee', @intActivityAttendeeId, @intNewActivityAttendeeId, @intDestinationCompanyId);
			
				DELETE FROM #TempActivityAttendee where intActivityAttendeeId = @intActivityAttendeeId
			END

			----------------------------------------ACTIVITY COMMENTS----------------------------------------
			DELETE FROM #TempTransferLogForUpdating;

			--Get all comments in intSourceRecordId when the source activity id and destination activity id are equals
			INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
			SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId]
			FROM tblSMInterCompanyTransferLogForComment a
			INNER JOIN tblSMComment b ON a.intSourceRecordId = b.intCommentId
			INNER JOIN tblSMComment c ON a.intDestinationRecordId = c.intCommentId
			WHERE (
				b.intActivityId = @intSourceActivityId AND
				c.intActivityId = @intDestinationActivityId AND
				a.intDestinationCompanyId = @intDestinationCompanyId AND
				a.strTable = 'tblSMComment'
			)

			--Get all comments in intDestinationRecordId when the destination activity id is equal to @intSourceActivityId and source transaction is equal to @intDestinationActivityId
			INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
			SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId]
			FROM tblSMInterCompanyTransferLogForComment a
			INNER JOIN tblSMComment b ON a.intSourceRecordId = b.intCommentId
			INNER JOIN tblSMComment c ON a.intDestinationRecordId = c.intCommentId
			WHERE (
				c.intActivityId = @intSourceActivityId AND
				b.intActivityId = @intDestinationActivityId AND
				a.intDestinationCompanyId = @intDestinationCompanyId AND
				a.strTable = 'tblSMComment'
			)

			INSERT INTO #TempComment(
				[intCommentId], [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
			)
			SELECT [intCommentId], [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
			FROM tblSMComment
			WHERE intActivityId = @intSourceActivityId AND
			intCommentId NOT IN (
				SELECT intSourceRecordId FROM #TempTransferLogForUpdating
			)

			--copy comments through looping
			WHILE EXISTS(SELECT 1 FROM #TempComment)
			BEGIN
				SELECT TOP 1 @intCommentId = intCommentId FROM #TempComment

				INSERT INTO tblSMComment (
					[strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId]
				)
				SELECT TOP 1 [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], @intDestinationActivityId
				FROM tblSMComment

				SET @intNewCommentId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
				)
				VALUES ('tblSMComment', @intCommentId, @intNewCommentId, NULL)

				----------------------------------------ACTIVITY COMMENTS NOTIFICATION----------------------------------------
				--copy all notification for this comment, greater than one, due to we can mention any user
				IF EXISTS(SELECT 1 FROM tblSMNotification WHERE  intCommentId = @intCommentId)
				BEGIN
					INSERT INTO #TempNotification (
						[intNotificationId], [intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
					)
					SELECT [intNotificationId], [intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
					FROM tblSMNotification
					WHERE intCommentId = @intCommentId

					--copy notification through looping
					WHILE EXISTS(SELECT 1 FROM #TempNotification)
					BEGIN
						--copy individual notification'
						SELECT TOP 1 @intNotificationId = intNoficationId FROM #TempNotification
					
						INSERT INTO tblSMNotification(
							[intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						)
						SELECT TOP 1 @intNewCommentId, @intDestinationActivityId, @strNewActivityNo, [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						FROM #TempNotification

						SET @intNewNotificationId = SCOPE_IDENTITY();

						INSERT INTO tblSMInterCompanyTransferLogForComment (
							[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId]
						)
						VALUES ('tblSMNotification', @intNotificationId, @intNewNotificationId, @intDestinationCompanyId);

						DELETE FROM #TempNotification where intNotificationId = @intNotificationId
					END
					--end notification through looping
				END

				DELETE FROM #TempComment where intCommentId = @intCommentId
			END
			--end copy comments

			DELETE FROM #TempTransferLog WHERE intInterCompanyTransferLogForCommentId = @intTransferLogId
		END
		---------------------------------------------------------end update existing activity---------------------------------------------------------

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH	
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION  


		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
		RETURN 0	

	END CATCH	

	RETURN 1
END