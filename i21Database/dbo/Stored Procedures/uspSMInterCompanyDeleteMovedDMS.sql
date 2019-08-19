
CREATE PROCEDURE [uspSMInterCompanyDeleteMovedDMS]
@currentTransId INT, 
@referenceTransId INT,
@referenceCompanyId INT = NULL

AS 
BEGIN


IF(OBJECT_ID('tempdb..#deleteMovedDMSTable') IS NOT NULL) 
				DROP TABLE #exclusionTable


    CREATE TABLE #deleteMovedDMSTable
	(
	  	[intInterCompanyTransferLogForDMS] INT,
		[intSourceRecordId] INT,
		[intDestinationRecordId] INT,
		[dtmCreated] DATETIME,
		[strDatabaseName] NVARCHAR(250)
	)




	DECLARE @strCurrentDatabaseName NVARCHAR(250) = DB_NAME();
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
	
		
		DELETE FROM #deleteMovedDMSTable


				--VALIDATION 1
		SET @deleteMovedSQL = N'INSERT INTO #deleteMovedDMSTable(intInterCompanyTransferLogForDMS, intSourceRecordId, intDestinationRecordId, dtmCreated, strDatabaseName)
			SELECT intInterCompanyTransferLogId, A.intSourceRecordId, A.intDestinationRecordId, dtmCreated, '''  + @strCurrentDatabaseName +''' FROM ['+@strCurrentDatabaseName+'].dbo.[tblSMInterCompanyTransferLogForDMS] A
			INNER JOIN ['+@strCurrentDatabaseName+'].dbo.[tblSMDocument] B on A.intSourceRecordId = B.intDocumentId
			INNER JOIN ['+@strDestinationDatabaseName+'].dbo.[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
			WHERE (
				(B.intTransactionId = ' + CONVERT(VARCHAR,@currentTransId) + ' OR
				C.intTransactionId = ' + CONVERT(VARCHAR,@referenceTransId) + ') OR
				ISNULL(A.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@referenceCompanyId, 0)) + '

			)'
			
		EXEC sp_executesql @deleteMovedSQL

				--VALIDATION 2
		SET @deleteMovedSQL = N'INSERT INTO #deleteMovedDMSTable(intInterCompanyTransferLogForDMS, intSourceRecordId, intDestinationRecordId, dtmCreated)
				SELECT intInterCompanyTransferLogId, A.intDestinationRecordId, A.intSourceRecordId, dtmCreated FROM ['+@strDestinationDatabaseName+'].dbo.[tblSMInterCompanyTransferLogForDMS] A
				INNER JOIN ['+@strDestinationDatabaseName+'].dbo.[tblSMDocument] B on A.intSourceRecordId = B.intDocumentId
				INNER JOIN ['+@strCurrentDatabaseName+'].dbo.[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
				WHERE (
					(B.intTransactionId = ' + CONVERT(VARCHAR,@referenceTransId) + ' OR
					C.intTransactionId = ' + CONVERT(VARCHAR,@currentTransId) + ') OR
					ISNULL(A.intDestinationCompanyId, 0) = ' + CONVERT(VARCHAR, ISNULL(@intCurrentCompanyId, 0)) + '

				)'

		EXEC sp_executesql @deleteMovedSQL


			

			---------------------------START DELETE existing DMS--------------------------------
			DECLARE @intTempTransferLogId INT = 0;
			DECLARE @intTempSourceDocumentId INT = 0;
			DECLARE @intTempDestinationDocumentId INT = 0;
			DECLARE @dtmLogDate DATETIME;
			DECLARE @dtmSourceDate DATETIME;
			DECLARE @strLogTableDataSource NVARCHAR(250);
			DECLARE @sql NVARCHAR(MAX) = N'';
			DECLARE @ParamDateTimeDefinition NVARCHAR(250) = N'@paramOut DATETIME OUTPUT';

			WHILE EXISTS(SELECT TOP 1 1 FROM #deleteMovedDMSTable)
			BEGIN
				SELECT TOP 1
				 @intTempTransferLogId = intInterCompanyTransferLogForDMS,
				 @intTempSourceDocumentId =	intSourceRecordId,
			     @intTempDestinationDocumentId = intDestinationRecordId,
			     @dtmLogDate = dtmCreated,
			     @strLogTableDataSource = strDatabaseName
			FROM #deleteMovedDMSTable
			
				SET @sql = N'SELECT @paramOut = DATEADD(MILLISECOND,DATEDIFF(MILLISECOND,getutcdate(),GETDATE()), dtmDateModified) FROM [' + @strCurrentDatabaseName + '].dbo.[tblSMDocument] WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempSourceDocumentId);
				EXEC sp_executesql @sql, @ParamDateTimeDefinition, @paramOut = @dtmSourceDate OUTPUT;

	

				--DELETE HERE IF DOCUMENT IS MOVED
			
					--SET @sql = N'
					--	DELETE FROM [' +@strDestinationDatabaseName+ '].dbo.[tblSMDocument] 
					--	WHERE intDocumentId = ' + CONVERT(VARCHAR, @intTempDestinationDocumentId) + '';

					--	EXEC sp_executesql @sql
						
				INSERT INTO tblSMInterCompanyStageDelete (intSourceId,intDestinationId,strDatabaseName, dtmDate) VALUES (@intTempSourceDocumentId, @intTempDestinationDocumentId,@strDestinationDatabaseName, GETUTCDATE() )
				
				DELETE FROM #deleteMovedDMSTable WHERE intInterCompanyTransferLogForDMS = @intTempTransferLogId

			END 

			
		
			--------------------------END DELETE existing DMS---------------------------------------------------

			
END

