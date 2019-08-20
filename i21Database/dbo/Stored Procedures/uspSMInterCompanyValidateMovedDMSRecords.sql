
CREATE PROCEDURE [uspSMInterCompanyValidateMovedDMSRecords]
@intInterCompanyLoggingId INT, --query api level to get the logging id
@intInvokedFromInterCompanyId INT = NULL,
@strFinishedLogId NVARCHAR(MAX) = ',',
@strUpdatedLogId NVARCHAR(MAX) = '' OUTPUT,
@intOldMovedReferenceTransId INT = NULL, -- for moved documents
@intRecordIdExcludeDelete INT = NULL  --document id of moved documents, must not be deleted

AS 
BEGIN
    DECLARE @currentTransId INT
	DECLARE @referenceTransId INT
	DECLARE @referenceCompanyId INT


	if(object_id('tempdb.#TempInterCompanyLog') is not null)
		DROP TABLE #TempInterCompanyLog

	CREATE TABLE #TempInterCompanyLog
	(
		[intInterCompanyTransferLogId] INT NOT NULL,
		[intSourceRecordId] INT NOT NULL,
		[intDestinationRecordId] INT NOT NULL,
		[intDestinationCompanyId] INT NULL DEFAULT(0)
	)
	--END CREATE TEMPORARY TABLES

    DECLARE @intInterCompanyTransferLogId INT;
	DECLARE @intInterCompanyIdFromOtherDb INT;
	DECLARE @intSourceRecordId INT;
	DECLARE @intDestinationRecordId INT;
	DECLARE @intReferenceCompanyId INT;
	DECLARE @intReferenceActualInterCompanyId INT;
	DECLARE @strReferenceDatabaseName NVARCHAR(250);
	DECLARE @strReferenceServerName NVARCHAR(250);
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @intCurrentCompanyId INT;

		SELECT
		@intInterCompanyTransferLogId = intInterCompanyTransferLogId,
		@intSourceRecordId = intSourceRecordId,
		@intDestinationRecordId = intDestinationRecordId,
		@intReferenceCompanyId = intDestinationCompanyId
	FROM tblSMInterCompanyTransferLogForDMS
	WHERE intInterCompanyTransferLogId = @intInterCompanyLoggingId

IF ISNULL(@intSourceRecordId, 0) <> 0 AND ISNULL(@intDestinationRecordId, 0) <> 0
BEGIN
	SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);
		--CHECK IF THE CURRENT and REFERENCE transactionId is already executed for current database
		IF CHARINDEX(',' + CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) > 0 AND
		   CHARINDEX(',' + CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) > 0 AND
		   (ISNULL(@intReferenceCompanyId, 0) = 0 OR (ISNULL(@intReferenceCompanyId, 0) <> 0 AND ISNULL(@intReferenceCompanyId, 0) <> @intCurrentCompanyId))
		BEGIN
			RETURN 1
		END
		ELSE
		BEGIN
			--SAME DATABASE
			IF ISNULL(@intReferenceCompanyId, 0) = 0
			BEGIN				
				--A <-> B
				EXEC dbo.[uspSMInterCompanyDeleteMovedDMS] @intSourceRecordId, @intRecordIdExcludeDelete = @intRecordIdExcludeDelete
				EXEC dbo.[uspSMInterCompanyDeleteMovedDMS] @intDestinationRecordId, @intRecordIdExcludeDelete = @intRecordIdExcludeDelete

				SET @strFinishedLogId = @strFinishedLogId + 
											CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
											CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',';
			END
			ELSE
			BEGIN
				--CHECK IF THE CURRENT and REFERENCE transactionId is already executed in the other database
				IF (CHARINDEX(',' + CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedLogId) = 0 OR
				   CHARINDEX(',' + CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',', @strFinishedLogId) = 0) AND
				   (ISNULL(@intReferenceCompanyId, 0) <> 0 AND ISNULL(@intReferenceCompanyId, 0) <> @intCurrentCompanyId)
				BEGIN
					EXEC dbo.[uspSMInterCompanyDeleteMovedDMS] @intDestinationRecordId, @intReferenceCompanyId, @intRecordIdExcludeDelete = @intRecordIdExcludeDelete

					SET @strFinishedLogId = @strFinishedLogId + 
												CONVERT(VARCHAR, @intSourceRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
												CONVERT(VARCHAR, @intDestinationRecordId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',';

					--we need to invoke the sp in the reference database to copy the files from intReferenceTransactionId to its siblings
					INSERT INTO #TempInterCompanyLog(intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId) 
					VALUES (@intInterCompanyLoggingId, @intSourceRecordId, @intDestinationRecordId, @intReferenceCompanyId)
				END
			END

			
			--CHECK SIBLINGS--
			--FETCH other records for InterCompanyMapping in the CURRENT database--

			--Check if current/reference is a source OR a reference in the current database / C <-> B, need to check B <-> A
			INSERT INTO #TempInterCompanyLog(intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId)
			SELECT intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM tblSMInterCompanyTransferLogForDMS
			WHERE intInterCompanyTransferLogId <> @intInterCompanyLoggingId AND
			(
				intSourceRecordId = @intDestinationRecordId OR intDestinationRecordId = @intDestinationRecordId OR (intDestinationRecordId = @intSourceRecordId) OR
				intSourceRecordId = @intSourceRecordId OR intDestinationRecordId = @intDestinationRecordId OR (intDestinationRecordId = @intSourceRecordId)
			)
			AND
			(
				ISNULL(intDestinationCompanyId, 0) = 0 OR
				ISNULL(intDestinationCompanyId, 0) = @intCurrentCompanyId
			)

			--Check if current/reference is a source transaction in the current database which is the reference transaction id is in the other database
			INSERT INTO #TempInterCompanyLog(intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId)
			SELECT intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM tblSMInterCompanyTransferLogForDMS
			WHERE intInterCompanyTransferLogId <> @intInterCompanyLoggingId AND
			(
				intSourceRecordId = @intDestinationRecordId OR intSourceRecordId = @intSourceRecordId
			)
			AND 
			(
				ISNULL(intDestinationCompanyId, 0) <> 0 AND 
				ISNULL(intDestinationCompanyId, 0) <> @intCurrentCompanyId
			)

			DECLARE TempInterCompanyMapping_Cursor CURSOR LOCAL STATIC FORWARD_ONLY FOR
			SELECT intInterCompanyTransferLogId, intSourceRecordId, intDestinationRecordId, intDestinationCompanyId
			FROM #TempInterCompanyLog
				
			OPEN TempInterCompanyMapping_Cursor

			FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyLoggingId, @intSourceRecordId, @intDestinationRecordId, @intReferenceCompanyId;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--RUN ONLY IF THE CURRENT DATABASE IS VALID
				IF ISNULL(@intCurrentCompanyId, 0) <> 0
				BEGIN
					
					--1: COPY THE SOURCE FILES TO DESTINATION
					EXEC dbo.[uspSMInterCompanyValidateMovedDMSRecords] @intInterCompanyLoggingId, @intCurrentCompanyId, @strFinishedLogId, @strUpdatedLogId =  @strUpdatedLogId OUTPUT, @intRecordIdExcludeDelete = @intRecordIdExcludeDelete
					

					--2: INVOKE THE OTHER DATABASE SP TO COPY THE FILES TO ITS SIBLINGS
					IF ISNULL(@intReferenceCompanyId, 0) <> 0
					BEGIN

						----EXECUTE [uspSMInterCompanyValidateRecordsForDMS] IN THE OTHER DATABASE
						----ALL tblSMInterCompany in each databases should have the same primary keys, but to be sure, lets get the intInterCompanyId based on the server and database name
						SELECT 
							@strReferenceServerName = strServerName, 
							@strReferenceDatabaseName = strDatabaseName 
						FROM tblSMInterCompany 
						WHERE intInterCompanyId = @intReferenceCompanyId;

						IF UPPER(@@SERVERNAME) = UPPER(@strReferenceServerName)
						BEGIN
							SET @intReferenceActualInterCompanyId = 0;
							DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
							SET @sql = N'SELECT @paramOut = intInterCompanyId FROM [' + @strReferenceDatabaseName + '].dbo.[tblSMInterCompany]
											WHERE UPPER(strServerName) = UPPER(''' + @strReferenceServerName + ''') AND UPPER(strDatabaseName) = UPPER(''' + @strReferenceDatabaseName + ''')';

							EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intReferenceActualInterCompanyId OUTPUT;
						
							--company id in the other database should be equal in the current databae
							--do not invoke the sp in the destination database if it is the db that invoked this sp
							IF ISNULL(@intReferenceActualInterCompanyId, 0) = @intReferenceCompanyId AND (
								ISNULL(@intInvokedFromInterCompanyId, 0) = 0 OR 
								(ISNULL(@intInvokedFromInterCompanyId, 0) <> 0 AND ISNULL(@intInvokedFromInterCompanyId, 0) <> @intReferenceCompanyId))
							BEGIN

								SET @intInterCompanyLoggingId = 0;
								--Get the mapping id in tblSMInterCompanyMapping table in the other database
								SET @sql = N'
								SELECT @paramOut = intInterCompanyTransferLogId FROM [' + @strReferenceDatabaseName + '].dbo.[tblSMInterCompanyTransferLogForDMS]
								WHERE intSourceRecordId = ' + CONVERT(VARCHAR, @intSourceRecordId) + ' AND 
								intDestinationRecordId = ' + CONVERT(VARCHAR, @intDestinationRecordId) + ' AND 
								intDestinationCompanyId = ' + CONVERT(VARCHAR, @intCurrentCompanyId);

								EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intInterCompanyLoggingId OUTPUT;
								
								--execute the sp in the other database.
								IF ISNULL(@intInterCompanyLoggingId, 0) <> 0
								BEGIN
									SET @sql = N'EXEC [' + @strReferenceDatabaseName + '].dbo.[uspSMInterCompanyValidateMovedDMSRecords] ' + 
														 CONVERT(VARCHAR(MAX), @intInterCompanyLoggingId) + ', ' +
														 CONVERT(VARCHAR(MAX), @intCurrentCompanyId) + ', ''' +
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
				FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyLoggingId, @intSourceRecordId, @intDestinationRecordId, @intReferenceCompanyId;
			END
			CLOSE TempInterCompanyMapping_Cursor
			DEALLOCATE TempInterCompanyMapping_Cursor
			

			SET @strUpdatedLogId = @strFinishedLogId;
		END
END

	RETURN 1

END