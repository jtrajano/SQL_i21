CREATE PROCEDURE uspSMInterCompanyValidateRecordsForMessaging
@intInterCompanyMappingId INT,
@intFromCompanyMappingId INT = NULL,
@strFinishedTransactionId NVARCHAR(MAX) = ',',
@strUpdatedTransactionId NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	--START CREATE TEMPOPARY TABLES
	IF OBJECT_ID('tempdb..#TempInterCompanyMapping') IS NOT NULL
		DROP TABLE #TempInterCompanyMapping

	Create TABLE #TempInterCompanyMapping
	(
		[intInterCompanyMappingId]		INT				NOT NULL,
		[intCurrentTransactionId]		[int]			NOT NULL,
		[intReferenceTransactionId]		[int]			NOT NULL,
		[intReferenceCompanyId]			[int]			NULL DEFAULT(0),
	)
	--END CREATE TEMPOPARY TABLES

	DECLARE @intInterCompanyMappingIdToUse INT;
	DECLARE @intInterCompanyIdFromOtherDb INT;
	DECLARE @intCurrentTransactionId INT;
	DECLARE @intReferenceTransactionId INT;
	DECLARE @intReferenceCompanyId INT;
	DECLARE @intReferenceActualInterCompanyId INT;
	DECLARE @strReferenceDatabaseName NVARCHAR(250);
	DECLARE @strReferenceServerName NVARCHAR(250);
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @intCurrentCompanyId INT;
	
	SELECT
		@intInterCompanyMappingIdToUse = intInterCompanyMappingId,
		@intCurrentTransactionId = intCurrentTransactionId,
		@intReferenceTransactionId = intReferenceTransactionId,
		@intReferenceCompanyId = intReferenceCompanyId
	FROM tblSMInterCompanyMapping
	WHERE intInterCompanyMappingId = @intInterCompanyMappingId
		
	IF ISNULL(@intCurrentTransactionId, 0) <> 0 AND ISNULL(@intReferenceTransactionId, 0) <> 0
	BEGIN
		--CHECK IF THE CURRENT and REFERENCE transactionId is already executed
		IF CHARINDEX(',' + CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',', @strFinishedTransactionId) > 0 AND
		   CHARINDEX(',' + CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',', @strFinishedTransactionId) > 0
		BEGIN
			RETURN 1
		END
		ELSE
		BEGIN
			
		
			--SAME DATABASE
			IF ISNULL(@intReferenceCompanyId, 0) = 0
			BEGIN
				--PRINT('------COPY RECORDS IN THE SAME DATABASE-------')
				
				--A <-> B
				EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intCurrentTransactionId, @intReferenceTransactionId
				EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intReferenceTransactionId, @intCurrentTransactionId

			END
			ELSE
			BEGIN
				--PRINT('------COPY RECORDS TO THE OTHER DATABASE-------')

				EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId
			END

			SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);

			SET @strFinishedTransactionId = @strFinishedTransactionId + 
											CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',' + 
											CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',';

			--FETCH other records for InterCompanyMapping in the current database--
			--PRINT('------CHECK RECORDS TO THE tblSMInterCompanyMapping-------')

			--Check if current/reference is a source OR a reference in the current database / C <-> B, need to check B <-> A
			INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
			SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId
			FROM tblSMInterCompanyMapping
			WHERE intInterCompanyMappingId <> @intInterCompanyMappingId AND
			(
				intCurrentTransactionId = @intReferenceTransactionId OR intReferenceTransactionId = @intReferenceTransactionId OR
				intCurrentTransactionId = @intCurrentTransactionId OR intReferenceTransactionId = @intCurrentTransactionId
			)
			AND
			(
				ISNULL(intReferenceCompanyId, 0) = 0 OR
				ISNULL(intReferenceCompanyId, 0) = @intCurrentCompanyId
			)

			--Check if current/reference is a source transaction in the current database which is the reference transaction id is in the other database
			INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
			SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId
			FROM tblSMInterCompanyMapping
			WHERE intInterCompanyMappingId <> @intInterCompanyMappingId AND
			(
				intCurrentTransactionId = @intReferenceTransactionId OR intCurrentTransactionId = @intCurrentTransactionId
			)
			AND 
			(
				ISNULL(intReferenceCompanyId, 0) <> 0 AND 
				ISNULL(intReferenceCompanyId, 0) <> @intCurrentCompanyId
			)

			DECLARE TempInterCompanyMapping_Cursor CURSOR LOCAL STATIC FORWARD_ONLY FOR
			SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId 
			FROM #TempInterCompanyMapping
				
			OPEN TempInterCompanyMapping_Cursor

			FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyMappingIdToUse, @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--RUN ONLY IF CURRENT DATABASE IS VALID
				IF ISNULL(@intCurrentCompanyId, 0) <> 0
				BEGIN
					IF ISNULL(@intReferenceCompanyId, 0) = 0
					--CURRENT DATABASE
					BEGIN
						EXEC dbo.[uspSMInterCompanyValidateRecordsForMessaging] @intInterCompanyMappingIdToUse, @intCurrentCompanyId, @strFinishedTransactionId, @strUpdatedTransactionId = @strFinishedTransactionId OUTPUT;
					END
					ELSE
					--OTHER DATABASE
					BEGIN
						--PRINT('------EXECUTE [uspSMInterCompanyValidateRecordsForMessaging] IN THE OTHER DATABASE-------')
						--ALL tblSMInterCompany in each databases should have the same primary keys, but to be sure, lets get the intInterCompanyId based on the server and database name
						SELECT 
							@strReferenceServerName = strServerName, 
							@strReferenceDatabaseName = strDatabaseName 
						FROM tblSMInterCompany 
						WHERE intInterCompanyId = @intReferenceCompanyId;

						IF UPPER(@@SERVERNAME) = UPPER(@strReferenceServerName)
						BEGIN
							SET @intReferenceActualInterCompanyId = 0;
							DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
							SET @sql = N'SELECT @paramOut = intInterCompanyId FROM ' + @strReferenceDatabaseName + '.dbo.[tblSMInterCompany]
											WHERE UPPER(strServerName) = UPPER(''' + @strReferenceServerName + ''') AND UPPER(strDatabaseName) = UPPER(''' + @strReferenceDatabaseName + ''')';

							EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intReferenceActualInterCompanyId OUTPUT;

						
						
							--company id in the other database should be equal in the current databae
							--do not invoke the sp in the destination database if it is the db that invoked this sp
							IF ISNULL(@intReferenceActualInterCompanyId, 0) = @intReferenceCompanyId AND 
							   (ISNULL(@intFromCompanyMappingId, 0) <> 0 AND ISNULL(@intFromCompanyMappingId, 0) <> @intReferenceCompanyId)
							BEGIN

								SET @intInterCompanyMappingIdToUse = 0;
								--Get the mapping id in tblSMInterCompanyMapping table in the other database
								SET @sql = N'
								SELECT @paramOut = intInterCompanyMappingId FROM ' + @strReferenceDatabaseName + '.dbo.[tblSMInterCompanyMapping]
								WHERE intCurrentTransactionId = ' + CONVERT(VARCHAR, @intReferenceTransactionId) + ' AND 
								intReferenceTransactionId = ' + CONVERT(VARCHAR, @intCurrentTransactionId) + ' AND 
								intReferenceCompanyId = ' + CONVERT(VARCHAR, @intCurrentCompanyId);

								EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intInterCompanyMappingIdToUse OUTPUT;
								
								--execute the sp with the key and 1 parameters in the other database.
								IF ISNULL(@intInterCompanyMappingIdToUse, 0) <> 0
								BEGIN
									SET @sql = N'EXEC ' + @strReferenceDatabaseName + 'dbo.[uspSMInterCompanyValidateRecordsForMessaging] ' + CONVERT(VARCHAR, @intInterCompanyMappingIdToUse) + ', ' + CONVERT(VARCHAR, @intCurrentCompanyId);
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
				FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyMappingIdToUse, @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId;
			END
			CLOSE TempInterCompanyMapping_Cursor
			DEALLOCATE TempInterCompanyMapping_Cursor
			

			SET @strUpdatedTransactionId = @strFinishedTransactionId;
		END
	END

	RETURN 1


END
