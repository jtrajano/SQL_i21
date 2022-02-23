
CREATE PROCEDURE [uspSMCopyInterCompanyDMSRecords]
@currentTransId INT, 
@referenceTransId INT,
@referenceCompanyId INT = NULL
AS 
BEGIN

IF(OBJECT_ID('tempdb..#exclusionTable') IS NOT NULL) 
				DROP TABLE #exclusionTable

	CREATE TABLE #exclusionTable
	(
		[intInterCompanyTransferLogForDMS] INT,
		[intSourceRecordId] INT,
		[intDestinationRecordId] INT,
		[dtmCreated] DATETIME,
		[strDatabaseName] NVARCHAR(250)
	)

	declare @dmsTable table
	(
			[intDocumentId] int,
			[strName] nvarchar(max),
			[intDocumentSourceFolderId] int,
			[intTransactionId] int,
			[intEntityId] int,
			[intSize] int,
			[strType] nvarchar(max),
			[intUploadId] int
	)


	--declare @dbName nvarchar(200) = (SELECT DB_NAME())
	DECLARE @strCurrentDatabaseName nvarchar(250) = DB_NAME();
	DECLARE @currentCompanyId int = (SELECT NULL)--(SELECT intInterCompanyId FROM tblSMInterCompany WHERE strDatabaseName = @currentDBName)
	DECLARE @exclusionSQL nvarchar(max) = N'';
	DECLARE @strDestinationDatabaseName nvarchar(max) = N'';
	DECLARE @intCurrentCompanyId INT

	 IF(ISNULL(@referenceCompanyId,'') <> '')
		BEGIN
			SET @strDestinationDatabaseName = (SELECT TOP 1 strDatabaseName FROM tblSMInterCompany WHERE intInterCompanyId = @referenceCompanyId)
			SET @intCurrentCompanyId = (SELECT TOP 1 intInterCompanyId FROM tblSMInterCompany WHERE UPPER(strDatabaseName) = UPPER(DB_NAME()) AND UPPER(strServerName) = UPPER(@@SERVERNAME))
		END
	ELSE
		BEGIN
			SET @strDestinationDatabaseName = DB_NAME();
		END
	
		
		DELETE FROM #exclusionTable

		SET @exclusionSQL = N'INSERT INTO #exclusionTable(intInterCompanyTransferLogForDMS, intSourceRecordId, intDestinationRecordId, dtmCreated, strDatabaseName)
			SELECT intInterCompanyTransferLogId, A.intSourceRecordId, A.intDestinationRecordId, dtmCreated, '''  + @strCurrentDatabaseName +''' FROM ['+@strCurrentDatabaseName+'].dbo.[tblSMInterCompanyTransferLogForDMS] A
			INNER JOIN ['+@strCurrentDatabaseName+'].dbo.[tblSMDocument] B on A.intSourceRecordId = B.intDocumentId
			INNER JOIN ['+@strDestinationDatabaseName+'].dbo.[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
			WHERE (
				B.intTransactionId = ' + CONVERT(VARCHAR,@currentTransId) + ' AND
				C.intTransactionId = ' + CONVERT(VARCHAR,@referenceTransId) + ' AND
				ISNULL(A.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@referenceCompanyId, 0)) + '

			)'
			
		EXEC sp_executesql @exclusionSQL

		SET @exclusionSQL = N'INSERT INTO #exclusionTable(intInterCompanyTransferLogForDMS, intSourceRecordId, intDestinationRecordId, dtmCreated)
				SELECT intInterCompanyTransferLogId, A.intDestinationRecordId, A.intSourceRecordId, dtmCreated FROM ['+@strDestinationDatabaseName+'].dbo.[tblSMInterCompanyTransferLogForDMS] A
				INNER JOIN ['+@strDestinationDatabaseName+'].dbo.[tblSMDocument] B on A.intSourceRecordId = B.intDocumentId
				INNER JOIN ['+@strCurrentDatabaseName+'].dbo.[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
				WHERE (
					B.intTransactionId = ' + CONVERT(VARCHAR,@referenceTransId) + ' AND
					C.intTransactionId = ' + CONVERT(VARCHAR,@currentTransId) + ' AND
					ISNULL(A.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@currentCompanyId, 0)) + '

				)'

		EXEC sp_executesql @exclusionSQL

		--validation#1
		--set @exclusionSQL =	'insert into #exclusionTable
		--	select A.intSourceRecordId from tblSMInterCompanyTransferLogForDMS A 
		--	inner join tblSMDocument B on B.intDocumentId = A.intSourceRecordId
		--	inner join [@dbname].[dbo].[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
		--	where (
		--		B.intTransactionId = @currentTransId and
		--		C.intTransactionId = @referenceTransId and
		--		ISNULL(A.intDestinationCompanyId,0) = ISNULL(@referenceCompanyId,0)
		--		)
		
		--	--validation#2
		--	insert into #exclusionTable
		--	select A.intDestinationRecordId from tblSMInterCompanyTransferLogForDMS A
		--	inner join tblSMDocument B on B.intDocumentId = A.intSourceRecordId
		--	inner join [@dbname].[dbo].[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
			  
		--	where (
		--	 B.intTransactionId = @referenceTransId and 
		--	 C.intTransactionId = @currentTransId and 
		--	 ISNULL(A.intDestinationCompanyId,0) = ISNULL(@referenceCompanyId,0)

		--	 )'

		--	 set @exclusionSQL = REPLACE(REPLACE(REPLACE(REPLACE(@exclusionSQL,'@currentTransId', @currentTransId),'@referenceTransId', @referenceTransId),'@dbname', @dbName),'@referenceCompanyId', ISNULL(@referenceCompanyId,0))

		--	 exec sp_executesql @exclusionSQL

			 DELETE FROM @dmsTable

			--insert those not in existing logs
			INSERT INTO @dmsTable
			SELECT intDocumentId, strName,intDocumentSourceFolderId,intTransactionId,intEntityId, intSize,strType, intUploadId FROM tblSMDocument WHERE intTransactionId = @currentTransId
			AND intDocumentId NOT IN
			(
				SELECT  intSourceRecordId FROM #exclusionTable
			) AND intDocumentSourceFolderId IN (SELECT intDocumentSourceFolderId FROM tblSMDocumentSourceFolder WHERE ysnInterCompany = 1) -- only those enabled document folders as source

			WHILE(EXISTS(SELECT TOP 1 1 FROM @dmsTable))
				BEGIN
					DECLARE @intDocumentId INT;
					DECLARE  @intDocumentSourceFolderId INT;
					DECLARE  @strName NVARCHAR(max)
					DECLARE  @strType NVARCHAR(max)
					DECLARE  @intSize INT
					DECLARE  @intUploadId INT
					DECLARE  @intEntityId INT
					DECLARE  @blbFile VARBINARY(max)
					 
					DECLARE  @smUploadSQL NVARCHAR(max) = N''
					DECLARE  @smDocumentSQL NVARCHAR(max) = N''
					DECLARE  @smSourceFolderSQL NVARCHAR(max) = N''
					DECLARE  @smFolderExistsSQL NVARCHAR(max) = N''
					DECLARE  @intNewUploadId INT
					DECLARE  @intNewDocumentId INT
					DECLARE  @outFolderId INT
					DECLARE  @outEnabledFolder INT
					

					SELECT TOP 1 @intDocumentId = intDocumentId,
								@intEntityId = intEntityId,
								@intDocumentSourceFolderId = intDocumentSourceFolderId,
								@strName = strName,
								@intDocumentSourceFolderId = intDocumentSourceFolderId,
								@strType = strType,
								@intSize = intSize,
								@intUploadId = intUploadId
								
				 FROM @dmsTable

				 SELECT @blbFile = blbFile FROM tblSMUpload WHERE intUploadId = @intUploadId
				---------------------check if folder exists- and enabled for multicompany------------------------------------


				SET @smSourceFolderSQL = N'SELECT @outFolderId = intDocumentSourceFolderId, @ysnFolderEnabled = ysnInterCompany FROM [@db].[dbo].[tblSMDocumentSourceFolder] WHERE intDocumentSourceFolderId = @intDocumentSourceFolderId  '
				SET @smSourceFolderSQL = REPLACE(REPLACE(@smSourceFolderSQL,'@db',@strDestinationDatabaseName),'@intDocumentSourceFolderId', @intDocumentSourceFolderId)
				EXEC sp_executesql @smSourceFolderSQL, N'@outFolderId INT OUTPUT, @ysnFolderEnabled INT OUTPUT', @outFolderId OUTPUT, @outEnabledFolder OUTPUT

				IF(ISNULL(@outEnabledFolder,0) = 0  OR ISNULL(@outFolderId,0) = 0)
					BEGIN
					    DELETE FROM @dmsTable WHERE intDocumentId = @intDocumentId
						CONTINUE; --not enabled or folder not exists
					END

				-----------------------------------------END QUOTE-------------------------------------------------------------------
				--work around on blob
				 SET @smUploadSQL = N'INSERT INTO [@db].[dbo].[tblSMUpload](strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId) values((select strFileIdentifier FROM tblSMUpload WHERE intUploadId = @intUploadId), (select blbFile FROM tblSMUpload WHERE intUploadId = @intUploadId), GETUTCDATE(), 1) ' +
									'SET @id = (SELECT SCOPE_IDENTITY()) '
				 
				 SET @smUploadSQL = (REPLACE(REPLACE(REPLACE(@smUploadSQL,'@blbFile',@blbFile),'@db',@strDestinationDatabaseName),'@intUploadId', @intUploadId))

				 EXEC sp_executesql @smUploadSQL, N'@id INT OUTPUT', @intNewUploadId OUTPUT



				 SET @smDocumentSQL = N' INSERT INTO [@db].[dbo].[tblSMDocument] (strName, strType,dtmDateModified, intSize, intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId) ' +
										'VALUES (@strName, @strType, GETUTCDATE(), @intSize, @intDocumentSourceFolderId, @referenceTransId, @intEntityId, @intNewUploadId, 1) ' +
										'SET @id = (SELECT SCOPE_IDENTITY()) '

				SET @smDocumentSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@smDocumentSQL, '@strName', ''''+@strName+''''),'@strType', ''''+@strType+''''),'@intSize', @intSize),'@intDocumentSourceFolderId', @intDocumentSourceFolderId),'@referenceTransId', @referenceTransId),'@intEntityId', @intEntityId),'@intNewUploadId', @intNewUploadId),'@db', @strDestinationDatabaseName)
			
				EXEC sp_executesql @smDocumentSQL, N'@id INT OUTPUT', @intNewDocumentId OUTPUT
				
				--SAVE TO LOGGING TABLE
				INSERT INTO tblSMInterCompanyTransferLogForDMS (intSourceRecordId, intDestinationRecordId, intDestinationCompanyId,dtmCreated)
					VALUES(@intDocumentId, @intNewDocumentId,@referenceCompanyId,  GETUTCDATE())
			

				 DELETE FROM @dmsTable WHERE intDocumentId = @intDocumentId
			end

			------------------------------------END COPYING DMS-----------------------------------------

			---------------------------start update existing DMS--------------------------------
			--DECLARE @intTempTransferLogId INT = 0;
			--DECLARE @intTempSourceDocumentId INT = 0;
			--DECLARE @intTempDestinationDocumentId INT = 0;
			--DECLARE @dtmLogDate DATETIME;
			--DECLARE @dtmSourceDate DATETIME;
			--DECLARE @strLogTableDataSource NVARCHAR(250);
			--DECLARE @sql NVARCHAR(MAX) = N'';
			--DECLARE @ParamDateTimeDefinition NVARCHAR(250) = N'@paramOut DATETIME OUTPUT';

			--WHILE EXISTS(SELECT TOP 1 1 FROM #exclusionTable)
			--BEGIN
			--	SELECT TOP 1
			--	 @intTempTransferLogId = intInterCompanyTransferLogForDMS,
			--	 @intTempSourceDocumentId =	intSourceRecordId,
			--     @intTempDestinationDocumentId = intDestinationRecordId,
			--     @dtmLogDate = dtmCreated,
			--     @strLogTableDataSource = strDatabaseName
			--FROM #exclusionTable
			
			--	SET @sql = N'SELECT @paramOut = DATEADD(MILLISECOND,DATEDIFF(MILLISECOND,getutcdate(),GETDATE()), dtmDateModified) FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId);
			--	EXEC sp_executesql @sql, @ParamDateTimeDefinition, @paramOut = @dtmSourceDate OUTPUT;

			--	IF ISNULL(@dtmSourceDate, 0 ) > ISNULL(@dtmLogDate, 0)
			--	BEGIN
			--		SET @sql = N'
			--			UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMDocument] SET
			--			intDocumentSourceFolderId = (
			--				SELECT intDocumentSourceFolderId FROM [' + @strCurrentDatabaseName +'].dbo.tblSMDocument WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId) + '
			--			) WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempDestinationDocumentId);

			--		EXEC sp_executesql @sql

			--		--update logging table
			--		SET @sql = N'
			--			UPDATE [' + @strLogTableDataSource + '].dbo.[tblSMInterCompanyTransferLogForDMS] SET dtmCreated = ''' + LEFT(CONVERT(VARCHAR, @dtmSourceDate, 121), 23) + '''
			--			WHERE intInterCompanyTransferLogId = '+ CONVERT(VARCHAR, @intTempTransferLogId)
					
			--		EXEC sp_executesql @sql;
			--	END
				
			--	DELETE FROM #exclusionTable WHERE intInterCompanyTransferLogForDMS = @intTempTransferLogId

			--END 
		
			--------------------------END update existing DMS---------------------------------------------------


END

SELECT * from tblSMInterCompanyTransferLogForDMS