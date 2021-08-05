
CREATE PROCEDURE [uspSMInterCompanyValidateRecordsForDMS]
@intInterCompanyMappingId INT,
@intInvokedFromInterCompanyId INT = NULL,
@strFinishedTransactionId NVARCHAR(MAX) = ',',
@strUpdatedTransactionId NVARCHAR(MAX) = '' OUTPUT,
@intReferToDocumentId INT = NULL, -- this is the document id of updated record
@strDatabaseToUseForUpdate NVARCHAR(MAX) =  NULL -- database to use when moving of folder is triggered on other db


AS 
BEGIN
    DECLARE @currentTransId INT
	DECLARE @referenceTransId INT
	DECLARE @referenceCompanyId INT


	if(object_id('tempdb.#TempInterCompanyMapping') is not null)
		DROP TABLE #TempInterCompanyMapping

	CREATE TABLE #TempInterCompanyMapping
	(
		[intInterCompanyMappingId] INT NOT NULL,
		[intCurrentTransactionId] INT NOT NULL,
		[intReferenceTransactionId] INT NOT NULL,
		[intReferenceCompanyId] INT NULL DEFAULT(0)
	)
	--END CREATE TEMPORARY TABLES

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
	DECLARE @intCurrentTransactionScreenId INT;
	DECLARE @intReferenceTransactionScreenId INT;

		SELECT
		@intInterCompanyMappingIdToUse = intInterCompanyMappingId,
		@intCurrentTransactionId = intCurrentTransactionId,
		@intReferenceTransactionId = intReferenceTransactionId,
		@intReferenceCompanyId = intReferenceCompanyId
	FROM tblSMInterCompanyMapping
	WHERE intInterCompanyMappingId = @intInterCompanyMappingId

IF ISNULL(@intCurrentTransactionId, 0) <> 0 AND ISNULL(@intReferenceTransactionId, 0) <> 0
BEGIN

	--WE NEED TO CHECK IF THE TRANSACTION ID IS EXISTING
	IF not exists(SELECT TOP 1 1 FROM tblSMTransaction where intTransactionId = @intCurrentTransactionId) and ISNULL(@intReferenceCompanyId, 0) = 0
	begin
		print 'current transaction does not exists in the current database'
		return 1;
	end
	IF not exists(SELECT TOP 1 1 FROM tblSMTransaction where intTransactionId = @intReferenceTransactionId) and ISNULL(@intReferenceCompanyId, 0) = 0
	begin
		print 'reference transaction does not exists in the current database'
		return 1;
	end

	--WE NEED TO CHECK IF THE TRANSACTION SCRREN ID IS CORRECT OR EXISTS IN THE tblSMInterCompanyMasterScreen
	SELECT @intCurrentTransactionScreenId = intScreenId FROM tblSMTransaction WHERE intTransactionId = @intCurrentTransactionId
	SELECT @intReferenceTransactionScreenId = intScreenId FROM tblSMTransaction WHERE intTransactionId = @intReferenceTransactionId
	IF ISNULL(@intCurrentTransactionScreenId, 0) <> 0  AND ISNULL(@intReferenceTransactionScreenId, 0) <> 0 AND ISNULL(@intReferenceCompanyId, 0) = 0
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMInterCompanyMasterScreen WHERE intScreenId = @intCurrentTransactionScreenId)
			RETURN 1

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMInterCompanyMasterScreen WHERE intScreenId = @intReferenceTransactionScreenId)
			RETURN 1
	END
	--END CHECKING

	SELECT @intCurrentCompanyId = intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME);
		--CHECK IF THE CURRENT and REFERENCE transactionId is already executed for current database
		IF CHARINDEX(',' + CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedTransactionId) > 0 AND
		   CHARINDEX(',' + CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedTransactionId) > 0 AND
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
				EXEC dbo.[uspSMInterCompanyCopyDMS] @intCurrentTransactionId, @intReferenceTransactionId, NULL, @intReferToDocumentId, @strDatabaseToUseForUpdate
				EXEC dbo.[uspSMInterCompanyCopyDMS] @intReferenceTransactionId, @intCurrentTransactionId,NULL, @intReferToDocumentId, @strDatabaseToUseForUpdate 

				SET @strFinishedTransactionId = @strFinishedTransactionId + 
											CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
											CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',';
			END
			ELSE
			BEGIN
				--CHECK IF THE CURRENT and REFERENCE transactionId is already executed in the other database
				IF (CHARINDEX(',' + CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',', @strFinishedTransactionId) = 0 OR
				   CHARINDEX(',' + CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',', @strFinishedTransactionId) = 0) AND
				   (ISNULL(@intReferenceCompanyId, 0) <> 0 AND ISNULL(@intReferenceCompanyId, 0) <> @intCurrentCompanyId)
				BEGIN
					EXEC dbo.[uspSMInterCompanyCopyDMS] @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId, @intReferToDocumentId, @strDatabaseToUseForUpdate

					SET @strFinishedTransactionId = @strFinishedTransactionId + 
												CONVERT(VARCHAR, @intCurrentTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + ',' + 
												CONVERT(VARCHAR, @intReferenceTransactionId) + ':' + CONVERT(VARCHAR, ISNULL(@intReferenceCompanyId, 0)) + ',';

					--we need to invoke the sp in the reference database to copy the files from intReferenceTransactionId to its siblings
					INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId) 
					VALUES (@intInterCompanyMappingIdToUse, @intCurrentTransactionId, @intReferenceTransactionId, @intReferenceCompanyId)
				END
			END

			
			--CHECK SIBLINGS--
			--FETCH other records for InterCompanyMapping in the CURRENT database--

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
				
				--RUN ONLY IF THE CURRENT DATABASE IS VALID
				IF ISNULL(@intCurrentCompanyId, 0) <> 0
				BEGIN
					
					--1: COPY THE SOURCE FILES TO DESTINATION
					EXEC dbo.[uspSMInterCompanyValidateRecordsForDMS] @intInterCompanyMappingIdToUse, @intCurrentCompanyId, @strFinishedTransactionId,@strUpdatedTransactionId =  @strFinishedTransactionId OUTPUT, @intReferToDocumentId = @intReferToDocumentId, @strDatabaseToUseForUpdate = @strDatabaseToUseForUpdate;
					

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

								SET @intInterCompanyMappingIdToUse = 0;
								--Get the mapping id in tblSMInterCompanyMapping table in the other database
								SET @sql = N'
								SELECT @paramOut = intInterCompanyMappingId FROM [' + @strReferenceDatabaseName + '].dbo.[tblSMInterCompanyMapping]
								WHERE intCurrentTransactionId = ' + CONVERT(VARCHAR, @intReferenceTransactionId) + ' AND 
								intReferenceTransactionId = ' + CONVERT(VARCHAR, @intCurrentTransactionId) + ' AND 
								intReferenceCompanyId = ' + CONVERT(VARCHAR, @intCurrentCompanyId);

								EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @intInterCompanyMappingIdToUse OUTPUT;
								
								--execute the sp in the other database.
								IF ISNULL(@intInterCompanyMappingIdToUse, 0) <> 0
								BEGIN
									SET @sql = N'EXEC [' + @strReferenceDatabaseName + '].dbo.[uspSMInterCompanyValidateRecordsForDMS] ' + 
														 CONVERT(VARCHAR(MAX), @intInterCompanyMappingIdToUse) + ', ' +
														 CONVERT(VARCHAR(MAX), @intCurrentCompanyId) + ', ''' +
														 CONVERT(VARCHAR(MAX), @strFinishedTransactionId) + ','',' +
														 '@intReferToDocumentId = ' + CONVERT(VARCHAR(MAX), ISNULL(CAST(@intReferToDocumentId AS NVARCHAR), 'NULL')) + ', ' +
														 '@strDatabaseToUseForUpdate = ''' + CONVERT(VARCHAR(MAX),DB_NAME()) + ''''

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