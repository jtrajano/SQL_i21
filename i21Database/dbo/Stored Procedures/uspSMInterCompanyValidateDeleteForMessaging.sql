CREATE PROCEDURE uspSMInterCompanyValidateDeleteForMessaging
@intInterCompanyTransferLogForCommentId INT,
@intInvokedFromInterCompanyId INT = NULL,
@strTableName NVARCHAR(250) = '',
@strFinishedLogId NVARCHAR(MAX) = ',',
@strUpdatedLogId NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	--START CREATE TEMPOPARY TABLES
	IF OBJECT_ID('tempdb..#TempInterCompanyTransferLogForComment') IS NOT NULL
		DROP TABLE #TempInterCompanyTransferLogForComment

	Create TABLE #TempInterCompanyTransferLogForComment
	(
		[intInterCompanyTransferLogForCommentId]		INT					NOT NULL,
		[strTable]										NVARCHAR(250)		NOT NULL,
		[intSourceRecordId]								INT					NOT NULL,
		[intDestinationRecordId]						INT					NOT NULL,
		[intDestinationCompanyId]						INT					NULL DEFAULT(0),
	)
	--END CREATE TEMPOPARY TABLES

	DECLARE @intSourceRecordId INT;
	DECLARE @intDestinationRecordId INT;
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @intCurrentCompanyId INT;
	DECLARE @intDestinationCompanyId INT;
	DECLARE @strReferenceServerName NVARCHAR(250);
	DECLARE @strReferenceDatabaseName NVARCHAR(250);
	DECLARE @intReferenceActualInterCompanyId INT;
	
	SELECT
		@intSourceRecordId = intSourceRecordId,
		@intDestinationRecordId = intDestinationRecordId,
		@intDestinationCompanyId = intDestinationCompanyId
	FROM tblSMInterCompanyTransferLogForComment
	WHERE intInterCompanyTransferLogForCommentId = @intInterCompanyTransferLogForCommentId
		
	IF ISNULL(@intSourceRecordId, 0) <> 0 AND ISNULL(@intDestinationRecordId, 0) <> 0
	BEGIN
		SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);

		--CHECK IF THE CURRENT and REFERENCE transactionId is already executed for current database
		IF CHARINDEX(',' + CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) > 0 AND
		   CHARINDEX(',' + CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) > 0 AND
		   (ISNULL(@intDestinationCompanyId, 0) = 0 OR (ISNULL(@intDestinationCompanyId, 0) <> 0 AND ISNULL(@intDestinationCompanyId, 0) <> @intCurrentCompanyId))
		BEGIN
			RETURN 1
		END
		ELSE
		BEGIN
			--SAME DATABASE
			IF ISNULL(@intDestinationCompanyId, 0) = 0
			BEGIN				
				--A <-> B
				EXEC dbo.[uspSMInterCompanyDeleteMessagingDetails] @intSourceRecordId, @strTableName		--DELETE A
				EXEC dbo.[uspSMInterCompanyDeleteMessagingDetails] @intDestinationRecordId, @strTableName	--DELETE B

				SET @strFinishedLogId = @strFinishedLogId + 
											CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
											CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',';
			END
			ELSE
			BEGIN
				--CHECK IF THE CURRENT and REFERENCE transactionId is already executed in the other database
				IF (CHARINDEX(',' + CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) = 0 OR
				   CHARINDEX(',' + CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intDestinationCompanyId, 0)) + ',', @strFinishedLogId) = 0) AND
				   (ISNULL(@intDestinationCompanyId, 0) <> 0 AND ISNULL(@intDestinationCompanyId, 0) <> @intCurrentCompanyId)
				BEGIN
					--DELETE LOCAL COPY ONLY
					EXEC dbo.[uspSMInterCompanyDeleteMessagingDetails] @intSourceRecordId, @strTableName

					SET @strFinishedLogId = @strFinishedLogId + 
												CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
												CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intDestinationCompanyId, 0)) + ',';
					
					--we need to invoke the sp in the reference database to copy the files from intReferenceTransactionId to its siblings
					INSERT INTO #TempInterCompanyTransferLogForComment(intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId)
					VALUES (@intInterCompanyTransferLogForCommentId, @intSourceRecordId, @intDestinationRecordId, @intDestinationCompanyId)
				END
			END

			--DELETE RECORDS IN LOGS
			DELETE FROM dbo.[tblSMInterCompanyTransferLogForComment] WHERE intInterCompanyTransferLogForCommentId = @intInterCompanyTransferLogForCommentId
			
			--CHECK SIBLINGS--
			--FETCH other records from [tblSMInterCompanyTransferLogForComment] in the CURRENT database--
			--Check if current/reference is a source OR a reference in the current database
			INSERT INTO #TempInterCompanyTransferLogForComment(intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId)
			SELECT intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM tblSMInterCompanyTransferLogForComment
			WHERE intInterCompanyTransferLogForCommentId <> @intInterCompanyTransferLogForCommentId AND
			(
				intSourceRecordId = @intDestinationRecordId OR intDestinationRecordId = @intDestinationRecordId OR
				intSourceRecordId = @intSourceRecordId OR intDestinationRecordId = @intSourceRecordId
			)
			AND
			(
				ISNULL(intDestinationCompanyId, 0) = 0 OR
				ISNULL(intDestinationCompanyId, 0) = @intCurrentCompanyId
			)

			--Check if current/reference is a source transaction in the current database which is the reference transaction id is in the other database
			INSERT INTO #TempInterCompanyTransferLogForComment(intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId)
			SELECT intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM tblSMInterCompanyTransferLogForComment
			WHERE intInterCompanyTransferLogForCommentId <> @intInterCompanyTransferLogForCommentId AND
			(
				intSourceRecordId = @intDestinationRecordId OR intSourceRecordId = @intSourceRecordId
			)
			AND 
			(
				ISNULL(intDestinationCompanyId, 0) <> 0 AND 
				ISNULL(intDestinationCompanyId, 0) <> @intCurrentCompanyId
			)

			DECLARE TempInterCompanyTransferLogForComment_Cursor CURSOR LOCAL STATIC FORWARD_ONLY FOR
			SELECT intInterCompanyTransferLogForCommentId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM #TempInterCompanyTransferLogForComment
				
			OPEN TempInterCompanyTransferLogForComment_Cursor

			FETCH NEXT FROM TempInterCompanyTransferLogForComment_Cursor into @intInterCompanyTransferLogForCommentId, @intSourceRecordId, @intDestinationRecordId, @intDestinationCompanyId;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--RUN ONLY IF THE CURRENT DATABASE IS VALID
				IF ISNULL(@intCurrentCompanyId, 0) <> 0
				BEGIN
					
					--1: DELETE THE SOURCE AND DESTINATION RECORDS
					EXEC dbo.[uspSMInterCompanyValidateDeleteForMessaging] @intInterCompanyTransferLogForCommentId, @intCurrentCompanyId, @strTableName, @strFinishedLogId, @strUpdatedLogId = @strFinishedLogId OUTPUT;
					

					--2: INVOKE THE OTHER DATABASE SP TO DELETE THE RECORDS TO ITS SIBLINGS
					IF ISNULL(@intDestinationCompanyId, 0) <> 0
					BEGIN

						----EXECUTE [uspSMInterCompanyValidateRecordsForMessaging] IN THE OTHER DATABASE
						----ALL tblSMInterCompany in each databases should have the same primary keys, but to be sure, lets get the intInterCompanyId based on the server and database name
						SELECT 
							@strReferenceServerName = strServerName, 
							@strReferenceDatabaseName = strDatabaseName 
						FROM tblSMInterCompany 
						WHERE intInterCompanyId = @intDestinationCompanyId;

						IF UPPER(@@SERVERNAME) = UPPER(@strReferenceServerName)
						BEGIN
							SET @intReferenceActualInterCompanyId = 0;
							DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
							SET @sql = N'SELECT @paramOut = intInterCompanyId FROM ' + @strReferenceDatabaseName + '.dbo.[tblSMInterCompany]
											WHERE UPPER(strServerName) = UPPER(''' + @strReferenceServerName + ''') AND UPPER(strDatabaseName) = UPPER(''' + @strReferenceDatabaseName + ''')';

							EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intReferenceActualInterCompanyId OUTPUT;
						
							--company id in the other database should be equal in the current databae
							--do not invoke the sp in the destination database if it is the db that invoked this sp
							IF ISNULL(@intReferenceActualInterCompanyId, 0) = @intDestinationCompanyId AND (
								ISNULL(@intInvokedFromInterCompanyId, 0) = 0 OR 
								(ISNULL(@intInvokedFromInterCompanyId, 0) <> 0 AND ISNULL(@intInvokedFromInterCompanyId, 0) <> @intDestinationCompanyId))
							BEGIN

								SET @intInterCompanyTransferLogForCommentId = 0;
								--Get the logging id in tblSMInterCompanyTransferLogForComment table in the other database
								SET @sql = N'
								SELECT @paramOut = intInterCompanyTransferLogForCommentId FROM ' + @strReferenceDatabaseName + '.dbo.[tblSMInterCompanyTransferLogForComment]
								WHERE intSourceRecordId = ' + CONVERT(VARCHAR, @intDestinationRecordId) + ' AND 
								intDestinationRecordId = ' + CONVERT(VARCHAR, @intSourceRecordId) + ' AND 
								@intDestinationCompanyId = ' + CONVERT(VARCHAR, @intCurrentCompanyId);

								EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intInterCompanyTransferLogForCommentId OUTPUT;
								
								--execute the sp in the other database.
								IF ISNULL(@intInterCompanyTransferLogForCommentId, 0) <> 0
								BEGIN
									SET @sql = N'EXEC ' + @strReferenceDatabaseName + '.dbo.[uspSMInterCompanyValidateDeleteForMessaging] ' + 
														 CONVERT(VARCHAR(MAX), @intInterCompanyTransferLogForCommentId) + ', ' +
														 CONVERT(VARCHAR(MAX), @intCurrentCompanyId) + ', ''' +
														 CONVERT(VARCHAR(MAX), @strTableName) + ',''' + 
														 CONVERT(VARCHAR(MAX), @strFinishedLogId) + ''''
									EXEC sp_executesql @sql;
								END
							END
						END
						ELSE
						BEGIN
							PRINT('OTHER SERVER IS NOT YET HANDLE!!')
						END

					END
				END
				FETCH NEXT FROM TempInterCompanyTransferLogForComment_Cursor into @intInterCompanyTransferLogForCommentId, @intSourceRecordId, @intDestinationRecordId, @intDestinationCompanyId;
			END
			CLOSE TempInterCompanyTransferLogForComment_Cursor
			DEALLOCATE TempInterCompanyTransferLogForComment_Cursor
			
			SET @strUpdatedLogId = @strFinishedLogId;
		END	
	END

	RETURN 1


END
