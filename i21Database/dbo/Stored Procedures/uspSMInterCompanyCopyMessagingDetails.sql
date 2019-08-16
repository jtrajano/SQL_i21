CREATE PROCEDURE uspSMInterCompanyCopyMessagingDetails
	@intSourceTransactionId INT,
	@intDestinationTransactionId INT,
	@intDestinationCompanyId INT = NULL
AS
BEGIN

	BEGIN TRY

		BEGIN TRANSACTION
		--PRINT('---------------START COPY INTER COMPANY RECORDS FOR MESSAGING---------------')

		--START CREATE TEMPOPARY TABLES
		IF OBJECT_ID('tempdb..#TempActivity') IS NOT NULL
			DROP TABLE #TempActivity
	
		CREATE TABLE #TempActivity
		(
			[intActivityId]				[int] NOT NULL,
			[intTransactionId]			[int] NULL,
			[strType]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
			[strSubject]				[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
			[intEntityContactId]		[int] NULL, 
			[intEntityId]				[int] NULL, 
			[intCompanyLocationId]		[int] NULL, 
			[dtmStartDate]				[datetime] NULL, 
			[dtmEndDate]				[datetime] NULL, 
			[dtmStartTime]				[datetime] NULL, 
			[dtmEndTime]				[datetime] NULL, 
			[ysnAllDayEvent]			[bit] NULL,
			[ysnRemind]					[bit] NULL,
			[strReminder]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strStatus]					[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strPriority]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strCategory]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[intAssignedTo]				[int] NULL,
			[strActivityNo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strRelatedTo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strRecordNo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strLocation]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[strDetails]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
			[strShowTimeAs]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
			[ysnPrivate]				[bit] NULL,
			[ysnPublic]					[bit] NULL,
			[dtmCreated]				[datetime] NULL, 
			[dtmModified]				[datetime] NULL, 
			[intCreatedBy]				[int] NULL,
			[strImageId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[strMessageType]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
			[strFilter]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			[ysnDismiss]				[bit] NULL,
			[intActivitySourceId]		[int] NULL
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

		IF OBJECT_ID('tempdb..#TempNotification') IS NOT NULL
			DROP TABLE #TempNotification

		CREATE TABLE #TempNotification
		(
			[intNotificationId] INT              NOT NULL,	
			[intCommentId]      INT              NULL,
			[intActivityId]     INT              NULL,
			[strTitle]			NVARCHAR(255)	 COLLATE Latin1_General_CI_AS NULL,
			[strAction]         NVARCHAR(255)    COLLATE Latin1_General_CI_AS NULL,
			[strType]           NVARCHAR(255)    COLLATE Latin1_General_CI_AS NULL,
			[strRoute]          NVARCHAR(MAX)    COLLATE Latin1_General_CI_AS NULL,
			[ysnSent]			BIT				 DEFAULT ((0)) NULL,	
			[ysnSeen]			BIT				 DEFAULT ((0)) NULL, 
			[ysnRead]           BIT              DEFAULT ((0)) NULL,
			[intFromEntityId]	INT				 NULL, 
			[intToEntityId]     INT              NULL,
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

		IF OBJECT_ID('tempdb..#TempTransferLogForUpdating') IS NOT NULL
			DROP TABLE #TempTransferLogForUpdating

		CREATE TABLE #TempTransferLogForUpdating
		(
			[intInterCompanyTransferLogForCommentId]	INT,
			[intSourceRecordId]							INT,
			[intDestinationRecordId]					INT,
			[intDestinationCompanyId]					INT NULL,
			[dtmCreated]								DATETIME,
			[strDatabaseName]							NVARCHAR(250)
		)

		--END CREATE TEMPOPARY TABLES

		DECLARE @intActivityId INT = 0;
		DECLARE @intNewActivityId INT = 0;
		DECLARE @strNewActivityNo NVARCHAR(50);
		DECLARE @intCreatedBy INT;
		DECLARE @intAssignedTo INT;
		DECLARE @strInterCompanyCreatedBy NVARCHAR(250);
		DECLARE @strInterCompanyAssignedTo NVARCHAR(250);
		DECLARE @intCommentId INT = 0;
		DECLARE @intNewCommentId INT = 0;
		DECLARE @intActivityAttendeeId INT = 0;
		DECLARE @intNewActivityAttendeeId INT = 0;
		DECLARE @intNotificationId INT = 0;
		DECLARE @intNewNotificationId INT = 0;
		DECLARE @sql NVARCHAR(MAX);
		DECLARE @strCurrentDatabaseName NVARCHAR(250) = DB_NAME();
		DECLARE @strDestinationDatabaseName NVARCHAR(250);
		DECLARE @intCurrentCompanyId INT;
		DECLARE @intCommentEntityId INT = 0;
		DECLARE @strCommentEntityName NVARCHAR(250);

		DECLARE @ParamStringDefinition NVARCHAR(250) = N'@paramOut NVARCHAR(250) OUTPUT';
		DECLARE @ParamIntDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
		DECLARE @ParamDateTimeDefinition NVARCHAR(250) = N'@paramOut DATETIME OUTPUT';

		IF ISNULL(@intDestinationCompanyId, 0) <> 0
		BEGIN
			--GET EXISTING ACTIVITY IN THE OTHER DATABASE'
			SELECT @strDestinationDatabaseName = strDatabaseName FROM tblSMInterCompany WHERE intInterCompanyId = @intDestinationCompanyId;
			SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);
		END
		ELSE
		BEGIN
			--GET EXISTING ACTIVITY IN THE CURRENT DATABASE
			SET @strDestinationDatabaseName = DB_NAME();
		END

		--VALIDATION 1: Get all activities in intSourceRecordId when the source transaction id and destination transaction id are equals
		SET @sql = N'INSERT INTO #TempTransferLog ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
		SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId]
		FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
		INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMActivity] b ON a.intSourceRecordId = b.intActivityId
		INNER JOIN [' + @strDestinationDatabaseName + '].dbo.[tblSMActivity] c ON a.intDestinationRecordId = c.intActivityId
		WHERE (
			b.intTransactionId = ' + CONVERT(VARCHAR, @intSourceTransactionId) + ' AND
			c.intTransactionId = ' + CONVERT(VARCHAR, @intDestinationTransactionId) + ' AND
			ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intDestinationCompanyId, 0)) + ' AND
			a.strTable = ''tblSMActivity''
		)';
		EXEC sp_executesql @sql;

		--VALIDATION 2: Get all activities in intDestinationRecordId when the destination transaction id is equal to @intSourceTransactionId and source transaction is equal to @intDestinationTransactionId
		SET @sql = N'INSERT INTO #TempTransferLog ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
		SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId]
		FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
		INNER JOIN [' + @strDestinationDatabaseName +'].dbo.[tblSMActivity] b ON a.intSourceRecordId = b.intActivityId
		INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMActivity] c ON a.intDestinationRecordId = c.intActivityId
		WHERE (
			b.intTransactionId = ' + CONVERT(VARCHAR, @intDestinationTransactionId) + ' AND
			c.intTransactionId = ' + CONVERT(VARCHAR, @intSourceTransactionId) + ' AND
			ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ' AND
			a.strTable = ''tblSMActivity''
		)';
		EXEC sp_executesql @sql;

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
		WHERE intTransactionId = @intSourceTransactionId AND strType = 'Comment' AND
		intActivityId NOT IN (
			SELECT intSourceRecordId FROM #TempTransferLog
		)
	
		---------------------------------------------------------copy non existing activity---------------------------------------------------------
		WHILE EXISTS(SELECT 1 FROM #TempActivity)
		BEGIN		
			SELECT TOP 1 @intActivityId = intActivityId, @intCreatedBy = intCreatedBy, @intAssignedTo = intAssignedTo FROM #TempActivity
			SELECT TOP 1 @strInterCompanyCreatedBy = strName FROM tblEMEntity WHERE intEntityId = @intCreatedBy
			SELECT TOP 1 @strInterCompanyAssignedTo = strName FROM tblEMEntity WHERE intEntityId = @intAssignedTo

			--Copy tblSMActivity and all entries in tblSMAttendee, tblSMComment, and tblSMNotification
			
			---STARTING NUMBERS--
			SET @sql = N'
				SELECT @paramOut = strPrefix + CONVERT(VARCHAR, intNumber) FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMStartingNumber] 
				WHERE strTransactionType = ''Activity'' AND strModule = ''System Manager''';
			EXEC sp_executesql @sql, @ParamStringDefinition, @paramOut = @strNewActivityNo OUTPUT;

			SET @sql = N'
				UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMStartingNumber] SET intNumber = intNumber+1 WHERE strTransactionType = ''Activity'' and strModule = ''System Manager'';
			';
			EXEC sp_executesql @sql
			---END STARTING NUMBERS--

			SET @sql = N'INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMActivity]
			(
				[intTransactionId], [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
				[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
				[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId], [strActivityNo],
				[strInterCompanyCreatedBy], [strInterCompanyAssignedTo]
			)
			SELECT TOP 1
				' + CONVERT(VARCHAR, @intDestinationTransactionId) + ', [strType], [strSubject], [intEntityContactId], [intEntityId], [intCompanyLocationId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [ysnAllDayEvent],
				[ysnRemind], [strReminder], [strStatus], [strPriority], [strCategory], [intAssignedTo], [strRelatedTo], [strRecordNo], [strLocation], [strDetails], [strShowTimeAs],
				[ysnPrivate], [ysnPublic], [dtmCreated], [dtmModified], [intCreatedBy], [strImageId], [strMessageType], [strFilter], [ysnDismiss], [intActivitySourceId], ''' + @strNewActivityNo + ''',
				''' + @strInterCompanyCreatedBy + ''', ''' + @strInterCompanyAssignedTo + '''
			FROM #TempActivity;
			
			SELECT @paramOut = SCOPE_IDENTITY()
			';
			
			EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewActivityId OUTPUT;


			INSERT INTO tblSMInterCompanyTransferLogForComment (
				[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
			)
			VALUES ('tblSMActivity', @intActivityId, @intNewActivityId, @intDestinationCompanyId, @intActivityId, @intNewActivityId);
					
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
				SELECT TOP 1 @intActivityAttendeeId = intActivityAttendeeId FROM #TempActivityAttendee

				SET @sql = N'
					INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMActivityAttendee](
						[intActivityId], [intEntityId], [ysnAddCalendarEvent], [intInterCompanyId]
					)
					SELECT TOP 1 ' + CONVERT(VARCHAR, @intNewActivityId) + ', [intEntityId], [ysnAddCalendarEvent], ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + '
					FROM #TempActivityAttendee;

					SELECT @paramOut = SCOPE_IDENTITY()
				';
				EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewActivityAttendeeId OUTPUT;

				--SET @intNewActivityAttendeeId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
				)
				VALUES ('tblSMActivityAttendee', @intActivityAttendeeId, @intNewActivityAttendeeId, @intDestinationCompanyId, @intActivityId, @intNewActivityId);

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
				SELECT TOP 1 @intCommentId = intCommentId, @intCommentEntityId = intEntityId FROM #TempComment
				SELECT TOP 1 @strCommentEntityName = strName FROM tblEMEntity where intEntityId = @intCommentEntityId

				SET @sql = N'
					INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMComment] (
						[strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId], 
						[intInterCompanyId], [strInterCompanyEntityName], [intInterCompanyEntityId]
					)
					SELECT TOP 1 [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], ' + CONVERT(VARCHAR, @intNewActivityId) + ', 
						' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ', ''' + @strCommentEntityName + ''', ' + CONVERT(VARCHAR, @intCommentEntityId) + '
					FROM #TempComment;

					SELECT @paramOut = SCOPE_IDENTITY()
				';
				EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewCommentId OUTPUT;

				--SET @intNewCommentId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
				)
				VALUES ('tblSMComment', @intCommentId, @intNewCommentId, @intDestinationCompanyId, @intActivityId, @intNewActivityId)

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
						SELECT TOP 1 @intNotificationId = intNotificationId FROM #TempNotification

						SET @sql = N'
							INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMNotification](
								[intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
							)
							SELECT TOP 1 ' + CONVERT(VARCHAR, @intNewCommentId) + ', ' +
											 CONVERT(VARCHAR, @intNewActivityId) + ', ''' +
											 CONVERT(VARCHAR, @strNewActivityNo) + ''', [strAction], [strType], [strRoute], [ysnSent], [ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
							FROM #TempNotification;

							SELECT @paramOut = SCOPE_IDENTITY()
						';
						EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewNotificationId OUTPUT;

						--SET @intNewNotificationId = SCOPE_IDENTITY();

						INSERT INTO tblSMInterCompanyTransferLogForComment (
							[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
						)
						VALUES ('tblSMNotification', @intNotificationId, @intNewNotificationId, @intDestinationCompanyId, @intActivityId, @intNewActivityId);

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

			SET @sql = N'SELECT @paramOut = strActivityNo FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMActivity] where intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId);
			EXEC sp_executesql @sql, @ParamStringDefinition, @paramOut = @strNewActivityNo OUTPUT;

			--ALWAYS UPDATE  SUBJECT AND PUBLIC
			SET @sql = N'
				UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMActivity] SET 
				strSubject = (
					SELECT strSubject FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMActivity] WHERE intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + '
				),
				ysnPublic = (
					SELECT ysnPublic FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMActivity] WHERE intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + '
				)
				WHERE intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId);
			EXEC sp_executesql @sql
			
			
			--Update tblSMAttendee, tblSMComment, and tblSMNotification
		
			----------------------------------------ACTIVITY ATTENDEE----------------------------------------
			--Get all attendee in intSourceRecordId when the source activity id and destination activity id are equals
			SET @sql = N'
				INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
				SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId]
				FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
				INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMActivityAttendee] b ON a.intSourceRecordId = b.intActivityAttendeeId
				INNER JOIN [' + @strDestinationDatabaseName + '].dbo.[tblSMActivityAttendee] c ON a.intDestinationRecordId = c.intActivityAttendeeId
				WHERE (
					b.intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + ' AND
					c.intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId) + ' AND
					ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intDestinationCompanyId, 0)) + ' AND
					a.strTable = ''tblSMActivityAttendee''
				)
			';
			EXEC sp_executesql @sql;

			----Get all attendee in intDestinationRecordId when the destination activity id is equal to @intSourceActivityId and source transaction is equal to @intDestinationActivityId
			SET @sql = N'
				INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId])
				SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId]
				FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
				INNER JOIN [' + @strDestinationDatabaseName + '].dbo.[tblSMActivityAttendee] b ON a.intSourceRecordId = b.intActivityAttendeeId
				INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMActivityAttendee] c ON a.intDestinationRecordId = c.intActivityAttendeeId
				WHERE (
					b.intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId) + ' AND
					c.intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + ' AND
					ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ' AND
					a.strTable = ''tblSMActivityAttendee''
				)
			';
			EXEC sp_executesql @sql;

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
				SELECT TOP 1 @intActivityAttendeeId = intActivityAttendeeId FROM #TempActivityAttendee
				SET @sql = N'
					INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMActivityAttendee](
						[intActivityId], [intEntityId], [ysnAddCalendarEvent], [intInterCompanyId]
					)
					SELECT TOP 1 ' + CONVERT(VARCHAR, @intDestinationActivityId) + ', [intEntityId], [ysnAddCalendarEvent], ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + '
					FROM #TempActivityAttendee;

					SELECT @paramOut = SCOPE_IDENTITY()
				';
				
				EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewActivityAttendeeId OUTPUT;

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
				)
				VALUES ('tblSMActivityAttendee', @intActivityAttendeeId, @intNewActivityAttendeeId, @intDestinationCompanyId, @intSourceActivityId, @intDestinationActivityId);
			
				DELETE FROM #TempActivityAttendee where intActivityAttendeeId = @intActivityAttendeeId
			END

			----------------------------------------ACTIVITY COMMENTS----------------------------------------
			DELETE FROM #TempTransferLogForUpdating;

			--Get all comments in intSourceRecordId when the source activity id and destination activity id are equals
			SET @sql = N'
				INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId], [dtmCreated], [strDatabaseName])
				SELECT [intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId], [dtmCreated], ''' + @strCurrentDatabaseName + '''
				FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
				INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMComment] b ON a.intSourceRecordId = b.intCommentId
				INNER JOIN [' + @strDestinationDatabaseName + '].dbo.[tblSMComment] c ON a.intDestinationRecordId = c.intCommentId
				WHERE (
					b.intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + ' AND
					c.intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId) + ' AND
					ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intDestinationCompanyId, 0)) + ' AND
					a.strTable = ''tblSMComment''
				)
			';
			EXEC sp_executesql @sql;

			--Get all comments in intDestinationRecordId when the destination activity id is equal to @intSourceActivityId and source transaction is equal to @intDestinationActivityId
			SET @sql = N'
				INSERT INTO #TempTransferLogForUpdating ([intInterCompanyTransferLogForCommentId], [intSourceRecordId], [intDestinationRecordId], [dtmCreated], [strDatabaseName])
				SELECT [intInterCompanyTransferLogForCommentId], [intDestinationRecordId], [intSourceRecordId], [dtmCreated], ''' + @strDestinationDatabaseName + '''
				FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForComment] a
				INNER JOIN [' + @strDestinationDatabaseName + '].dbo.[tblSMComment] b ON a.intSourceRecordId = b.intCommentId
				INNER JOIN [' + @strCurrentDatabaseName + '].dbo.[tblSMComment] c ON a.intDestinationRecordId = c.intCommentId
				WHERE (
					b.intActivityId = ' + CONVERT(VARCHAR, @intDestinationActivityId) + ' AND
					c.intActivityId = ' + CONVERT(VARCHAR, @intSourceActivityId) + ' AND
					ISNULL(a.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ' AND
					a.strTable = ''tblSMComment''
				)
			';
			EXEC sp_executesql @sql;

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
				SELECT TOP 1 @intCommentId = intCommentId, @intCommentEntityId = intEntityId FROM #TempComment
				SELECT TOP 1 @strCommentEntityName = strName FROM tblEMEntity where intEntityId = @intCommentEntityId

				SET @sql = N'
					INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMComment] (
						[strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], [intActivityId],
						[intInterCompanyId], [strInterCompanyEntityName], [intInterCompanyEntityId]
					)
					SELECT TOP 1 [strComment], [strScreen], [strRecordNo], [dtmAdded], [dtmModified], [ysnPublic], [ysnEdited], [intEntityId], [intTransactionId], ' + CONVERT(VARCHAR, @intDestinationActivityId) + ', 
								' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ', ''' + @strCommentEntityName + ''', ' + CONVERT(VARCHAR, @intCommentEntityId) + '
					FROM #TempComment;

					SELECT @paramOut = SCOPE_IDENTITY()
				';
				
				EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewCommentId OUTPUT;

				--SET @intNewCommentId = SCOPE_IDENTITY()

				INSERT INTO tblSMInterCompanyTransferLogForComment (
					[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
				)
				VALUES ('tblSMComment', @intCommentId, @intNewCommentId, @intDestinationCompanyId, @intSourceActivityId, @intDestinationActivityId)

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
						SELECT TOP 1 @intNotificationId = intNotificationId FROM #TempNotification
					
						--INSERT INTO tblSMNotification(
						--	[intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						--)
						--SELECT TOP 1 @intNewCommentId, @intDestinationActivityId, @strNewActivityNo, [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
						--FROM #TempNotification
						SET @sql = N'
							INSERT INTO [' + @strDestinationDatabaseName + '].dbo.[tblSMNotification](
								[intCommentId], [intActivityId], [strTitle], [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
							)
							SELECT TOP 1 ' +
								CONVERT(VARCHAR, @intNewCommentId) + ', ' + 
								CONVERT(VARCHAR, @intDestinationActivityId) + ', ''' +
								CONVERT(VARCHAR, @strNewActivityNo) + ''', [strAction], [strType], [strRoute], [ysnSent],	[ysnSeen], [ysnRead], [intFromEntityId], [intToEntityId]
							FROM #TempNotification;

							SELECT @paramOut = SCOPE_IDENTITY()
						';
						
						
						EXEC sp_executesql @sql, @ParamIntDefinition, @paramOut = @intNewNotificationId OUTPUT;

						--SET @intNewNotificationId = SCOPE_IDENTITY();

						INSERT INTO tblSMInterCompanyTransferLogForComment (
							[strTable], [intSourceRecordId], [intDestinationRecordId], [intDestinationCompanyId], [intSourceActivityId], [intDestinationActivityId]
						)
						VALUES ('tblSMNotification', @intNotificationId, @intNewNotificationId, @intDestinationCompanyId, @intSourceActivityId, @intDestinationActivityId);

						DELETE FROM #TempNotification where intNotificationId = @intNotificationId
					END
					--end notification through looping
				END

				DELETE FROM #TempComment where intCommentId = @intCommentId
			END

			---------------------------------------------------------update existing comment---------------------------------------------------------
			DECLARE @intTempTransferLogId INT = 0;
			DECLARE @intTempSourceCommentId INT = 0;
			DECLARE @intTempDestinationCommentId INT = 0;
			DECLARE @dtmLogDate DATETIME;
			DECLARE @dtmSourceDate DATETIME;
			DECLARE @strLogTableDataSource NVARCHAR(250);
			WHILE EXISTS(SELECT 1 FROM #TempTransferLogForUpdating)
			BEGIN
				SELECT TOP 1 
					@intTempTransferLogId = intInterCompanyTransferLogForCommentId, 
					@intTempSourceCommentId = intSourceRecordId, 
					@intTempDestinationCommentId = intDestinationRecordId,
					@dtmLogDate = dtmCreated,
					@strLogTableDataSource = strDatabaseName
				FROM #TempTransferLogForUpdating

				--ALWAYS UPDATE  COMMENT WHEN LATEST
				SET @sql = N'SELECT @paramOut = DATEADD(MILLISECOND,DATEDIFF(MILLISECOND,getutcdate(),GETDATE()), dtmModified) FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMComment] WHERE intCommentId = ' + CONVERT(VARCHAR, @intTempSourceCommentId);
				EXEC sp_executesql @sql, @ParamDateTimeDefinition, @paramOut = @dtmSourceDate OUTPUT;
				
				IF ISNULL(@dtmSourceDate, 0) > ISNULL(@dtmLogDate, 0)
				BEGIN
					SET @sql = N'
						UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMComment] SET 
						strComment = (
							SELECT strComment FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMComment] WHERE intCommentId = ' + CONVERT(VARCHAR, @intTempSourceCommentId) + '
						),
						dtmModified = ''' + LEFT(CONVERT(VARCHAR, @dtmSourceDate, 121), 23) + '''
						WHERE intCommentId = ' + CONVERT(VARCHAR, @intTempDestinationCommentId);
					EXEC sp_executesql @sql

					--update logging table
					SET @sql = N'
						UPDATE [' + @strLogTableDataSource + '].dbo.[tblSMInterCompanyTransferLogForComment] SET dtmCreated = ''' + LEFT(CONVERT(VARCHAR, @dtmSourceDate, 121), 23) + '''
						WHERE intInterCompanyTransferLogForCommentId = ' + CONVERT(VARCHAR, @intTempTransferLogId)
					EXEC sp_executesql @sql
				END

				DELETE FROM #TempTransferLogForUpdating WHERE intInterCompanyTransferLogForCommentId = @intTempTransferLogId
			END
			---------------------------------------------------------end update existing comment---------------------------------------------------------

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