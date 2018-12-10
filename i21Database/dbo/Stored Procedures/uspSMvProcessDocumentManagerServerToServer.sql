CREATE PROCEDURE uspSMProcessDocumentManagerServerToServer
    @destinationServer NVARCHAR(MAX),
    @destinationDB NVARCHAR(MAX),
    @destinationUserId NVARCHAR(MAX),
    @destinationServerPassword NVARCHAR(MAX)

	AS

	BEGIN

	DECLARE @SQLString NVARCHAR(MAX) = '';

	IF  ((@destinationServer IS NULL OR LEN(RTRIM(LTRIM(@destinationServer))) = 0) OR
		(@destinationDB IS NULL OR LEN(RTRIM(LTRIM(@destinationDB))) = 0) OR
		(@destinationUserId IS NULL OR LEN(RTRIM(LTRIM(@destinationUserId))) = 0) OR
		(@destinationServerPassword IS NULL OR LEN(RTRIM(LTRIM(@destinationServerPassword))) = 0 ))
			BEGIN
			
				PRINT 'PLEASE COMPLETE THE PARAMETERS!!'
				RETURN;
			END 

		
	/****setup linked server****/

	IF EXISTS(SELECT * FROM sys.servers WHERE name = N'DocumentManagerDestServer')
    EXECUTE sp_dropserver 'DocumentManagerDestServer', 'droplogins';

	EXECUTE sp_addlinkedserver @server = N'DocumentManagerDestServer',
			@srvproduct = N'',
			@provider = N'SQLNCLI',
			@datasrc = @destinationServer;

	EXECUTE sp_addlinkedsrvlogin 'DocumentManagerDestServer', 'false', NULL, @destinationUserId, @destinationServerPassword;
	
SET @SQLString = N'DECLARE @currentrow INT = 1
	DECLARE @fromContractId INT = 0
	DECLARE @toContractId INT = 0
	DECLARE @intScreenId INT = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = ''ContractManagement.view.Contract'')	


	DECLARE @intTransactionId INT = (SELECT intTransactionId FROM tblSMTransaction where intRecordId = @fromContractId and intScreenId = @intScreenId) --must be present if it really

 IF (@intTransactionId IS NULL)
	BEGIN
		PRINT ''Transaction Id does not exists''
		RETURN;
	END

	 WHILE (@currentrow <= (SELECT COUNT(*) FROM tblSMTempDocument WHERE intTransactionId = @intTransactionId AND ysnCopied = 0))
		BEGIN
			
		DECLARE @intDocumentId INT = (SELECT TOP 1 intDocumentId FROM tblSMTempDocument WHERE intTransactionId = @intTransactionId and ysnCopied = 0)
		DECLARE @intUploadId INT = (SELECT intUploadId from tblSMDocument where intDocumentId = @intDocumentId)
		DECLARE @intEntityId INT = (SELECT intEntityId from tblSMDocument where intDocumentId = @intDocumentId)
		DECLARE @intDocumentSourceFolderId  INT = (SELECT intDocumentSourceFolderId FROM tblSMTempDocument WHERE intDocumentId = @intDocumentId)
		DECLARE @intTransId INT = 0;

		IF(@intTransactionId > 0 AND @intDocumentId > 0) --must have documents attache to the transaction
			BEGIN
				DECLARE @ysnTransactionExists INT = (SELECT COUNT(*) from tblSMDocument where intTransactionId = @intTransactionId) --if not null , there is an entry on tblSMDocument
				
				IF(@ysnTransactionExists > 0 )
					BEGIN
						DECLARE @blbFile VARBINARY(MAX) = (SELECT blbFile from tblSMUpload WHERE intUploadId = @intUploadId)
							--tblUpload
								INSERT INTO DocumentManagerDestServer.[destDB].[dbo].[tblSMUpload] (strFileIdentifier, blbFile,dtmDateUploaded, intConcurrencyId)
											VALUES(NEWID(),@blbFile,GETUTCDATE(),1)
						DECLARE @intNewUploadId INT = (SELECT SCOPE_IDENTITY())

						--check toContractId transaction
					   DECLARE @toIntTransactionId INT = (SELECT  intTransactionId FROM tblSMTransaction WHERE intRecordId = @toContractId AND intScreenId = @intScreenId)
						
						IF (@toIntTransactionId IS NULL )  -- insert on transaction table
							BEGIN
								DECLARE @strContractNumber NVARCHAR(100) = (SELECT strContractNumber FROM tblCTContractHeader WHERE intContractHeaderId = @toContractId)
									INSERT INTO DocumentManagerDestServer.[destDB].[dbo].[tblSMTransaction] (intScreenId, strTransactionNo, intRecordId) VALUES (@intScreenId,@strContractNumber ,@toIntTransactionId)
								SET @intTransId = (SELECT SCOPE_IDENTITY())
							END
						ELSE
							BEGIN
								set @intTransId = @toIntTransactionId
							END		
						  
						 INSERT INTO DocumentManagerDestServer.[destDB].[dbo].[tblSMDocument](strName, strType,dtmDateModified, intSize,intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId)
									SELECT strName, strType, GETUTCDATE(), intSize, intDocumentSourceFolderId, @intTransId, intEntityId, @intUploadId, 1 FROM tblSMTempDocument WHERE intDocumentId = @intDocumentId 
						
						UPDATE tblSMTempDocument SET ysnCopied = 1  WHERE intDocumentId = @intDocumentId
					
					END

				ELSE
					BEGIN
						CONTINUE;
					END
		END

	END'
			
		--SET @SQLString = 'EXEC('' ' + REPLACE(@SQLString,'destDB',@destinationDB) + ' '')'
		SET @SQLString =  'EXEC('' ' + replace(REPLACE(@SQLString,'destDB',@destinationDB),'''','''''') + ' '')'  

		  exec sp_executesql @SQLString
	END


	/*** LOCAL SERVER SP
	DECLARE @currentrow INT = 1
DECLARE @fromContractId INT = 51
DECLARE @toContractId INT = 423
DECLARE @intScreenId INT = (select intScreenId from tblSMScreen where strNamespace = 'ContractManagement.view.Contract')

--IF OBJECT_ID('tempdb..#tempDMS') IS NOT NULL
-- DROP TABLE #tempDMS

 --insert not copied documents
 --SELECT * into #tempDMS from tblSMDocument --where ysnCopied = 0
  --DECLARE @totalrows INT = (SELECT COUNT(*) FROM tblSMTempDocument WHERE intTransactionId = @fromContractId AND ysnCopied = 0)
  --select * from tblSMDocument
 DECLARE @intTransactionId INT = (SELECT intTransactionId FROM tblSMTransaction where intRecordId = @fromContractId and intScreenId = @intScreenId) --must be present if it really

 IF (@intTransactionId IS NULL)
	BEGIN
		PRINT 'Transaction Id does not exists'
		RETURN;
	END

 WHILE (@currentrow <= (SELECT COUNT(*) FROM tblSMTempDocument WHERE intTransactionId = @intTransactionId AND ysnCopied = 0))
	BEGIN

		--DECLARE @intUpload INT = (SELECT * FROM tblSMUpload where int)
		--validate if intRecordId exists on tblSMTransaction
		--DECLARE @intRecordId  INT = (SELECT intRecordId from tblSMTransaction WHERE intScreenId = @intScreenId AND intRecordId = @fromContractId)
		
		
		DECLARE @intDocumentId INT = (SELECT TOP 1 intDocumentId FROM tblSMTempDocument WHERE intTransactionId = @intTransactionId and ysnCopied = 0)
		DECLARE @intUploadId INT = (SELECT intUploadId from tblSMDocument where intDocumentId = @intDocumentId)
		DECLARE @intEntityId INT = (SELECT intEntityId from tblSMDocument where intDocumentId = @intDocumentId)
		DECLARE @intDocumentSourceFolderId  INT = (SELECT intDocumentSourceFolderId FROM tblSMTempDocument WHERE intDocumentId = @intDocumentId)
		DECLARE @intTransId INT = 0;

		IF(@intTransactionId > 0 AND @intDocumentId > 0) --must have documents attache to the transaction
			BEGIN
				DECLARE @ysnTransactionExists INT = (SELECT COUNT(*) from tblSMDocument where intTransactionId = @intTransactionId) --if not null , there is an entry on tblSMDocument
				
				IF(@ysnTransactionExists > 0 )
					BEGIN
						DECLARE @blbFile VARBINARY(MAX) = (SELECT blbFile from tblSMUpload WHERE intUploadId = @intUploadId)
							--tblUpload
								INSERT into tblSMUpload (strFileIdentifier, blbFile,dtmDateUploaded, intConcurrencyId)
											VALUES(NEWID(),@blbFile,GETUTCDATE(),1)
						DECLARE @intNewUploadId INT = (SELECT SCOPE_IDENTITY())

						--check toContractId transaction
					   DECLARE @toIntTransactionId INT = (SELECT  intTransactionId FROM tblSMTransaction WHERE intRecordId = @toContractId AND intScreenId = @intScreenId)
						
						IF (@toIntTransactionId IS NULL )  -- insert on transaction table
							BEGIN
								DECLARE @strContractNumber NVARCHAR(100) = (SELECT strContractNumber FROM tblCTContractHeader WHERE intContractHeaderId = @toContractId)
									INSERT INTO tblSMTransaction (intScreenId, strTransactionNo, intRecordId) VALUES (@intScreenId,@strContractNumber ,@toIntTransactionId)
								SET @intTransId = (SELECT SCOPE_IDENTITY())
							END
						ELSE
							BEGIN
								set @intTransId = @toIntTransactionId
							END		
						  
						 INSERT INTO tblSMDocument(strName, strType,dtmDateModified, intSize,intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId)
									SELECT strName, strType, GETUTCDATE(), intSize, intDocumentSourceFolderId, @intTransId, intEntityId, @intUploadId, 1 FROM tblSMTempDocument WHERE intDocumentId = @intDocumentId 
						
						UPDATE tblSMTempDocument SET ysnCopied = 1  WHERE intDocumentId = @intDocumentId
					
					END

				ELSE
					BEGIN
						CONTINUE;
					END
				
				
			END
END




	***/