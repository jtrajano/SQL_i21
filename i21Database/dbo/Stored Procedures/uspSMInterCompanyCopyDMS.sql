  
CREATE PROCEDURE [dbo].[uspSMInterCompanyCopyDMS]  
@currentTransId INT,   
@referenceTransId INT,  
@referenceCompanyId INT = NULL,  
@intReferToDocumentId INT = NULL,  
@strDatabaseToUseForUpdate NVARCHAR(MAX) = NULL  
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
  
  
 DECLARE @dmsTable TABLE  
 (  
   [intDocumentId] int,  
   [strName] nvarchar(max),  
   [intDocumentSourceFolderId] int,  
   [intTransactionId] int,  
   [intEntityId] int,  
   [intSize] int,  
   [strType] nvarchar(max),  
   [intUploadId] int,  
   [strFolderPath] nvarchar(max),
   [strUserName] nvarchar(max)
 )  
  
 DECLARE @strCurrentDatabaseName NVARCHAR(250) = DB_NAME();  
  
 DECLARE @exclusionSQL NVARCHAR(MAX) = N'';  
 DECLARE @deleteMovedSQL NVARCHAR(MAX) = N'';  
 DECLARE @strDestinationDatabaseName NVARCHAR(max) = N'';  
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
     ISNULL(A.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + '  
  
    )'  
  
  EXEC sp_executesql @exclusionSQL  
  
  
    DELETE FROM @dmsTable  
  
   --insert those not in existing logs  
   INSERT INTO @dmsTable  
   SELECT intDocumentId, strName,intDocumentSourceFolderId,intTransactionId,intEntityId, intSize,strType, intUploadId, strFolderPath, strUserName FROM vyuSMDocument WHERE intTransactionId = @currentTransId  
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
		DECLARE  @strFolderPath NVARCHAR(MAX)  
        
		DECLARE  @smUploadSQL NVARCHAR(max) = N''  
		DECLARE  @smDocumentSQL NVARCHAR(max) = N''  
		DECLARE  @smSourceFolderSQL NVARCHAR(max) = N''  
		DECLARE  @smFolderExistsSQL NVARCHAR(max) = N''  
		DECLARE  @smFolderPathSQL NVARCHAR(MAX) = N''  
		DECLARE  @intNewUploadId INT  
		DECLARE  @intNewDocumentId INT  
		DECLARE  @outFolderId INT  
		DECLARE  @outEnabledFolder INT  
  
		DECLARE @strEntityName NVARCHAR(MAX) = N''  
       
  
		SELECT TOP 1 @intDocumentId = intDocumentId,  
		@intEntityId = intEntityId,  
		@intDocumentSourceFolderId = intDocumentSourceFolderId,  
		@strName = strName,  
		@intDocumentSourceFolderId = intDocumentSourceFolderId,  
		@strType = strType,  
		@intSize = intSize,  
		@intUploadId = intUploadId,  
		@strFolderPath = strFolderPath,
		@strEntityName = strUserName
          
		FROM @dmsTable  
  
		SELECT @blbFile = blbFile FROM tblSMUpload WHERE intUploadId = @intUploadId  

		IF ISNULL(@strEntityName, '') = ''
		BEGIN
			SELECT @strEntityName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId  
		END
  
		--Temp Table Folder Path  
		IF(OBJECT_ID('tempdb..#folderPathTable') IS NOT NULL)   
			DROP TABLE #folderPathTable  
      
		CREATE TABLE #folderPathTable  
		(  
		[intDocumentSourceFolderId] INT,  
		[intDocumentTypeId] INT,  
		[strFolderPath] NVARCHAR(MAX)  
		)  
  
		SET @smFolderPathSQL = N'WITH FolderHeirarchy AS (  
		SELECT   
		intDocumentSourceFolderId,    
		A.intDocumentTypeId,  
		CAST(strName AS VARCHAR(MAX)) AS strFolderPath  
		FROM ['+ @strDestinationDatabaseName +'].dbo.tblSMDocumentSourceFolder A  
		WHERE intDocumentFolderParentId IS NULL  
  
		UNION ALL  
  
		SELECT   
		B.intDocumentSourceFolderId,   
		B.intDocumentTypeId,  
		CAST(strFolderPath + ''\'' + CAST(B.strName AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS strFolderPath  
		FROM ['+ @strDestinationDatabaseName +'].dbo.tblSMDocumentSourceFolder B  
		INNER JOIN FolderHeirarchy C ON C.intDocumentSourceFolderId = B.intDocumentFolderParentId  
		) INSERT INTO #folderPathTable   
		SELECT intDocumentSourceFolderId, intDocumentTypeId, strFolderPath FROM FolderHeirarchy WHERE strFolderPath = '''+ @strFolderPath + ''' '  
  
		EXEC sp_executesql @smFolderPathSQL  
		-- User folder path as keypoint instead of Source Folder Id - Because you might fetch wrong id  
		DECLARE @intDestinationDocumentSourceFolderId INT = (SELECT TOP 1 ISNULL(intDocumentSourceFolderId,0) FROM #folderPathTable WHERE strFolderPath = @strFolderPath)  
     
     
		---------------------check if folder exists- and enabled for multicompany------------------------------------  
  
		SET @smSourceFolderSQL = N'SELECT @outFolderId = intDocumentSourceFolderId, @ysnFolderEnabled = ysnInterCompany FROM [@db].[dbo].[tblSMDocumentSourceFolder] WHERE intDocumentSourceFolderId = @intDocumentSourceFolderId  '  
		SET @smSourceFolderSQL = REPLACE(REPLACE(@smSourceFolderSQL,'@db',@strDestinationDatabaseName),'@intDocumentSourceFolderId', @intDestinationDocumentSourceFolderId)  
		EXEC sp_executesql @smSourceFolderSQL, N'@outFolderId INT OUTPUT, @ysnFolderEnabled INT OUTPUT', @outFolderId OUTPUT, @outEnabledFolder OUTPUT  
  
		IF(ISNULL(@outEnabledFolder,0) = 0  OR ISNULL(@outFolderId,0) = 0)  
		BEGIN  
			DELETE FROM @dmsTable WHERE intDocumentId = @intDocumentId  
			CONTINUE; --not enabled or folder not exists  
		END  
  
		-----------------------------------------END QUOTE-------------------------------------------------------------------  
		--work around on blob  
		SET @smUploadSQL = N'INSERT INTO [@db].[dbo].[tblSMUpload](strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId) values(NEWID(), (select blbFile FROM tblSMUpload WHERE intUploadId = @intUploadId), GETUTCDATE(), 1) ' +  
		'SET @id = (SELECT SCOPE_IDENTITY()) '  
       
		SET @smUploadSQL = (REPLACE(REPLACE(REPLACE(@smUploadSQL,'@blbFile',@blbFile),'@db',@strDestinationDatabaseName),'@intUploadId', @intUploadId))  
  
		EXEC sp_executesql @smUploadSQL, N'@id INT OUTPUT', @intNewUploadId OUTPUT  
  
		DECLARE @placeHolderEntityId INT; --Documents copied from other db should have null entity id  
  
  
		-- SET @smDocumentSQL = N' INSERT INTO [@db].[dbo].[tblSMDocument] (strName, strType,dtmDateModified, intSize, intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId) ' +
		--						'VALUES (@strName, @strType, GETUTCDATE(), @intSize, @intDocumentSourceFolderId, @referenceTransId, @intEntityId, @intNewUploadId, 1) ' +
		--						'SET @id = (SELECT SCOPE_IDENTITY()) '
  
		--SET @smDocumentSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@smDocumentSQL, '@strName', ''''+@strName+''''),'@strType', ''''+@strType+''''),'@intSize', @intSize),'@intDocumentSourceFolderId', @intDocumentSourceFolderId),'@referenceTransId', @referenceTransId),'@intEntityId', @intEntityId),'@intNewUploadId', @intNewUploadId),'@db', @strDestinationDatabaseName)  
     
		DECLARE @ifExistingSQL NVARCHAR(max) = N''
		DECLARE @ifExistResult INT

	 SET @ifExistingSQL = N'SELECT TOP 1 1 FROM ['+ @strDestinationDatabaseName +'].[dbo].[tblSMDocument] WHERE strName = ''' + @strName + ''' AND intTransactionId = '+CASE WHEN @referenceTransId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@referenceTransId) END +''

		EXEC sp_executesql @ifExistingSQL
	 
		SELECT @ifExistResult = @@ROWCOUNT
	 
		IF @ifExistResult = 0
		BEGIN
			SET @smDocumentSQL = N'INSERT INTO ['+ @strDestinationDatabaseName +'].[dbo].[tblSMDocument] (strName, strType,dtmDateModified, intSize, intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intInterCompanyEntityId, intInterCompanyId, strInterCompanyEntityName , intConcurrencyId )   
			VALUES ('''+ REPLACE(@strName, '''', '''''')  +''',   
			'''+@strType+''',   
			GETUTCDATE(),  
			'+CASE WHEN @intSize IS NULL THEN 'NULL' ELSE  CONVERT(NVARCHAR,@intSize) END + ',   
			'+CASE WHEN @outFolderId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@outFolderId) END+ ',  
			'+CASE WHEN @referenceTransId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@referenceTransId) END +',   
			'+CASE WHEN @placeHolderEntityId IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR,@placeHolderEntityId) END+',   
			'+CASE WHEN @intNewUploadId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@intNewUploadId) END+',   
			'+CASE WHEN @intEntityId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@intEntityId) END+',  
			'+CASE WHEN @intCurrentCompanyId IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR,@intCurrentCompanyId) END+',   
			'''+ @strEntityName+''', 1 ) SET @id = (SELECT SCOPE_IDENTITY())'   

			EXEC sp_executesql @smDocumentSQL, N'@id INT OUTPUT', @intNewDocumentId OUTPUT  
      
			--SAVE TO LOGGING TABLE  
			INSERT INTO tblSMInterCompanyTransferLogForDMS (intSourceRecordId, intDestinationRecordId, intDestinationCompanyId,dtmCreated)  
			VALUES(@intDocumentId, @intNewDocumentId,@referenceCompanyId,  GETUTCDATE())

		END

		DELETE FROM @dmsTable WHERE intDocumentId = @intDocumentId  
	END
  
   ------------------------------------END COPYING DMS-----------------------------------------  
  
   ---------------------------start update existing DMS--------------------------------  
	DECLARE @intTempTransferLogId INT = 0;  
	DECLARE @intTempSourceDocumentId INT = 0;  
	DECLARE @intTempDestinationDocumentId INT = 0;  
	DECLARE @dtmLogDate DATETIME;  
	DECLARE @dtmSourceDate DATETIME;  
	DECLARE @strLogTableDataSource NVARCHAR(250);  
	DECLARE @sql NVARCHAR(MAX) = N'';  
	DECLARE @folderPathOut NVARCHAR(MAX);  
	DECLARE @ParamDateTimeDefinition NVARCHAR(250) = N'@paramOut DATETIME OUTPUT';  
	DECLARE @ParamFolderPath NVARCHAR(MAX) = N'@pathOut NVARCHAR(MAX) OUTPUT';  
	DECLARE @ParamSourceName NVARCHAR(MAX) = N'@paramOut NVARCHAR(1000) OUTPUT';  
	DECLARE @ParamDestinationName NVARCHAR(MAX) = N'@paramOut NVARCHAR(1000) OUTPUT';  
	DECLARE @SourceName NVARCHAR(MAX) = N'@paramOut NVARCHAR(1000) OUTPUT';  
	DECLARE @DestinationName NVARCHAR(MAX) = N'@paramOut NVARCHAR(1000) OUTPUT';
  
	IF(ISNULL(@strDatabaseToUseForUpdate,'') = '')  
    BEGIN  
     SET @strDatabaseToUseForUpdate = DB_NAME()  
    END  
  
  
	WHILE EXISTS(SELECT TOP 1 1 FROM #exclusionTable)
	BEGIN
		SELECT TOP 1
				@intTempTransferLogId = intInterCompanyTransferLogForDMS,
				@intTempSourceDocumentId =	intSourceRecordId,
				@intTempDestinationDocumentId = intDestinationRecordId,
				@dtmLogDate = dtmCreated,
				@strLogTableDataSource = strDatabaseName
		FROM #exclusionTable
			
		SET @sql = N'SELECT @paramOut = DATEADD(MILLISECOND,DATEDIFF(MILLISECOND,getutcdate(),GETDATE()), dtmDateModified) FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId);
		EXEC sp_executesql @sql, @ParamDateTimeDefinition, @paramOut = @dtmSourceDate OUTPUT;

		/*===============================START CHECKING FOLDER PATH================================================*/
		IF(OBJECT_ID('tempdb..#tmpFolderTable') IS NOT NULL) 
				DROP TABLE #tmpFolderTable

		--update only the folder of the document, prevent update all document records in the transaction Id
		IF ISNULL(@intReferToDocumentId, 0) <> 0
		BEGIN
			--reference to current db
			IF (@intReferToDocumentId = @intTempSourceDocumentId OR @intReferToDocumentId = @intTempDestinationDocumentId) AND @strLogTableDataSource = @strCurrentDatabaseName
			BEGIN
				SET @sql = N'SELECT @pathOut = strFolderPath FROM ['+ @strDatabaseToUseForUpdate +'].dbo.[vyuSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intReferToDocumentId)
				EXEC sp_executesql @sql, @ParamFolderPath,@pathOut = @folderPathOut OUTPUT;
			END
			--reference to other db
			ELSE IF (@intReferToDocumentId = @intTempSourceDocumentId OR @intReferToDocumentId = @intTempDestinationDocumentId) AND @strLogTableDataSource IS NULL
			BEGIN
				SET @sql = N'SELECT @pathOut = strFolderPath FROM ['+ @strDatabaseToUseForUpdate +'].dbo.[vyuSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intReferToDocumentId)
				EXEC sp_executesql @sql, @ParamFolderPath,@pathOut = @folderPathOut OUTPUT;
			END
			ELSE
			BEGIN
				SET @sql = N'SELECT @pathOut = strFolderPath FROM ['+ @strDatabaseToUseForUpdate +'].dbo.[vyuSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId)
				EXEC sp_executesql @sql, @ParamFolderPath,@pathOut = @folderPathOut OUTPUT;
			END
		END

		CREATE TABLE #tmpFolderTable
		(
			[intDocumentSourceFolderId] INT,
			[intDocumentTypeId] INT,
			[strFolderPath] NVARCHAR(MAX)
		)

		SET @smFolderPathSQL = N'WITH FolderHeirarchy AS (
			SELECT 
			intDocumentSourceFolderId,  
			A.intDocumentTypeId,
			CAST(strName AS VARCHAR(MAX)) AS strFolderPath
			FROM ['+ @strDestinationDatabaseName +'].dbo.tblSMDocumentSourceFolder A
			WHERE intDocumentFolderParentId IS NULL

			UNION ALL

			SELECT 
			B.intDocumentSourceFolderId, 
			B.intDocumentTypeId,
			CAST(strFolderPath + ''\'' + CAST(B.strName AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS strFolderPath
			FROM ['+ @strDestinationDatabaseName +'].dbo.tblSMDocumentSourceFolder B
			INNER JOIN FolderHeirarchy C ON C.intDocumentSourceFolderId = B.intDocumentFolderParentId
		) INSERT INTO #tmpFolderTable 
		SELECT intDocumentSourceFolderId, intDocumentTypeId, strFolderPath FROM FolderHeirarchy WHERE strFolderPath = '''+ @folderPathOut + ''''
				
		EXEC sp_executesql @smFolderPathSQL

		/*=====================================END CHECKING FOLDER PATH===============================================================*/



		DECLARE @newDocumentSourceFolderID INT = (SELECT TOP 1 intDocumentSourceFolderId FROM #tmpFolderTable)
		IF ISNULL(@newDocumentSourceFolderID, 0) <> 0
		BEGIN
			SET @sql = N'
			UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMDocument] SET
			intDocumentSourceFolderId = (
				'+ CONVERT(VARCHAR, @newDocumentSourceFolderID) +'
			) WHERE intDocumentId = ' + CONVERT(VARCHAR, ISNULL(@intTempDestinationDocumentId, 0));

			EXEC sp_executesql @sql


			--------------------------------------------------------------------START RENAME--------------------------------------------------------------------
			--update the name if it is different
			--renaming should only be happened on moving DMS files
			--do not trigger this for email renaming(email rename will happen on the api side)

			IF ISNULL(@intReferToDocumentId, 0) <> 0
			BEGIN
				--reference to current db
				--referdocumentId used was the destination, lets swap the two values
				--scenario is P-contract mapped to S-contract, move dms file in s-contract
				IF @intReferToDocumentId = @intTempDestinationDocumentId
				BEGIN
					SET @intTempDestinationDocumentId = @intTempSourceDocumentId
					SET @intTempSourceDocumentId = @intReferToDocumentId
				END
			END

			SET @sql = N'SELECT @paramOut = strName FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId);
			EXEC sp_executesql @sql, @ParamSourceName, @paramOut = @SourceName OUTPUT;

			SET @sql = N'SELECT @paramOut = strName FROM [' + @strDestinationDatabaseName + '].dbo.[tblSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempDestinationDocumentId);
			EXEC sp_executesql @sql, @ParamDestinationName, @paramOut = @DestinationName OUTPUT;

			IF ISNULL(@SourceName, '') != '' AND ISNULL(@DestinationName, '') != ''
			BEGIN
				IF @SourceName != @DestinationName
				BEGIN
					SET @sql = N'
					UPDATE [' + @strDestinationDatabaseName + '].dbo.[tblSMDocument] 
					SET strName = ''' + @SourceName + '''
					WHERE intDocumentId = ' + CONVERT(VARCHAR, ISNULL(@intTempDestinationDocumentId, 0));
                    
					EXEC sp_executesql @sql;
				END
			END
			--------------------------------------------------------------------END RENAME--------------------------------------------------------------------



			--update logging table
			SET @sql = N'
				UPDATE [' + @strLogTableDataSource + '].dbo.[tblSMInterCompanyTransferLogForDMS] SET dtmCreated = ''' + LEFT(CONVERT(VARCHAR, @dtmSourceDate, 121), 23) + '''
				WHERE intInterCompanyTransferLogId = '+ CONVERT(VARCHAR, @intTempTransferLogId)
					
			EXEC sp_executesql @sql;
		END

				
		DELETE FROM #exclusionTable WHERE intInterCompanyTransferLogForDMS = @intTempTransferLogId

	END 

			
		
--------------------------END update existing DMS---------------------------------------------------

			
END

