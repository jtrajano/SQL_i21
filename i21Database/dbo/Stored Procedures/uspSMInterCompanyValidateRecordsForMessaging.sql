CREATE PROCEDURE uspSMInterCompanyValidateRecordsForMessaging
@intInterCompanyMappingId INT,
@ysnCheckSiblings BIT = 1
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
		--SAME DATABASE
		IF ISNULL(@intReferenceCompanyId, 0) = 0
		BEGIN
			PRINT('------COPY RECORDS IN THE SAME DATABASE-------')
				
			--A <-> B
			EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intCurrentTransactionId, @intReferenceTransactionId
			EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intReferenceTransactionId, @intCurrentTransactionId

			
			--FETCH other records for InterCompanyMapping in the current database--
			IF @ysnCheckSiblings = 1
			BEGIN
				--Check if current reference is a source OR a reference in the current database / C <-> B, need to check B <-> A
				INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
				SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId
				FROM tblSMInterCompanyMapping
				WHERE intInterCompanyMappingId <> @intInterCompanyMappingId AND
				(
					intCurrentTransactionId = @intReferenceTransactionId OR 
					intReferenceTransactionId = @intReferenceTransactionId
				)
				AND intReferenceCompanyId IS NULL

				--Check if current reference is a source and reference transaction is in the other database
				INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
				SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId
				FROM tblSMInterCompanyMapping
				WHERE intInterCompanyMappingId <> @intInterCompanyMappingId AND
				intCurrentTransactionId = @intReferenceTransactionId
				AND intReferenceCompanyId IS NOT NULL

				DECLARE TempInterCompanyMapping_Cursor CURSOR LOCAL STATIC FORWARD_ONLY FOR
				SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId 
				FROM #TempInterCompanyMapping
				
				OPEN TempInterCompanyMapping_Cursor

				FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyMappingIdToUse, @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId;
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF ISNULL(@intReferenceCompanyId, 0) = 0
					BEGIN
						EXEC dbo.[uspSMInterCompanyValidateRecordsForMessaging] @intInterCompanyMappingIdToUse, 0
					END
					ELSE
					BEGIN
						PRINT('------EXECUTE [uspSMInterCompanyValidateRecordsForMessaging] IN THE OTHER DATABASE-------')
						
						SELECT 
							@intCurrentCompanyId = intInterCompanyId 
						FROM tblSMInterCompany 
						WHERE strDatabaseName = DB_NAME() AND strServerName = @@SERVERNAME;

						--ALL tblSMInterCompany in each databases should have the same primary keys, but to be sure, lets get the intInterCompanyId based on the server and database name
						SELECT 
							@strReferenceServerName = strServerName, 
							@strReferenceDatabaseName = strDatabaseName 
						FROM tblSMInterCompany 
						WHERE intInterCompanyId = @intReferenceCompanyId;

						IF @@SERVERNAME = @strReferenceServerName
						BEGIN
							SET @intReferenceActualInterCompanyId = 0;
							DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut INT OUTPUT';
							SET @sql = N'SELECT @paramOut = intInterCompanyId FROM ' + @strReferenceDatabaseName + '.dbo.[tblSMInterCompany]
										 WHERE strServerName = ' + @strReferenceServerName + ' AND strDatabaseName = ' + @strReferenceDatabaseName;

							EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intReferenceActualInterCompanyId OUTPUT;

							--company id in the other database should be equal in the current databae
							IF ISNULL(@intReferenceActualInterCompanyId, 0) = @intReferenceCompanyId
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
									SET @sql = N'EXEC ' + @strReferenceDatabaseName + 'dbo.[uspSMInterCompanyValidateRecordsForMessaging] ' + CONVERT(VARCHAR, @intInterCompanyMappingIdToUse) + ', 1';
									EXEC sp_executesql @sql;
								END
							END
						END
						ELSE
						BEGIN
							PRINT('OTHER SERVER IS NOT YET HANDLE!!')
						END

					END
					FETCH NEXT FROM TempInterCompanyMapping_Cursor into @intInterCompanyMappingIdToUse, @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId;
				END
				CLOSE TempInterCompanyMapping_Cursor
				DEALLOCATE TempInterCompanyMapping_Cursor
			END

		END
		ELSE
		BEGIN
			--TODO
			PRINT('------COPY RECORDS TO THE OTHER DATABASE-------')
			--EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intCurrentTransactionId, @intReferenceTransactionId

		END
	END

	RETURN 1


END
