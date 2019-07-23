CREATE PROCEDURE [uspSMInterCompanyCopyDMS]
@currentTransId INT, 
@referenceTransId INT,
@referenceCompanyId INT
AS 
BEGIN

IF(OBJECT_ID('tempdb..#exclusionTable') IS NOT NULL) 
				DROP TABLE #exclusionTable

	CREATE TABLE #exclusionTable
	(
		[intSourceRecordId] INT
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


	declare @dbName nvarchar(200) = (SELECT DB_NAME())
	declare @exclusionSQL nvarchar(max) = N'';

	 IF(ISNULL(@referenceCompanyId,'') <> '')
		begin
			set @dbName = (select top 1 strDatabaseName from tblSMInterCompany where intInterCompanyId = @referenceCompanyId)
		end


		delete from #exclusionTable

		--validation#1
		set @exclusionSQL =	'insert into #exclusionTable
			select A.intSourceRecordId from tblSMInterCompanyTransferLogForDMS A 
			inner join tblSMDocument B on B.intDocumentId = A.intSourceRecordId
			inner join [@dbname].[dbo].[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
			where (
				B.intTransactionId = @currentTransId and
				C.intTransactionId = @referenceTransId and
				ISNULL(A.intDestinationCompanyId,0) = ISNULL(@referenceCompanyId,0)
				)
		
			--validation#2
			insert into #exclusionTable
			select A.intDestinationRecordId from tblSMInterCompanyTransferLogForDMS A
			inner join tblSMDocument B on B.intDocumentId = A.intSourceRecordId
			inner join [@dbname].[dbo].[tblSMDocument] C on C.intDocumentId = A.intDestinationRecordId
			  
			where (
			 B.intTransactionId = @referenceTransId and 
			 C.intTransactionId = @currentTransId and 
			 ISNULL(A.intDestinationCompanyId,0) = ISNULL(@referenceCompanyId,0)

			 )'

			 set @exclusionSQL = REPLACE(REPLACE(REPLACE(REPLACE(@exclusionSQL,'@currentTransId', @currentTransId),'@referenceTransId', @referenceTransId),'@dbname', @dbName),'@referenceCompanyId', ISNULL(@referenceCompanyId,0))

			 exec sp_executesql @exclusionSQL

			 delete from @dmsTable

			--insert those not in existing logs
			insert into @dmsTable
			select intDocumentId, strName,intDocumentSourceFolderId,intTransactionId,intEntityId, intSize,strType, intUploadId from tblSMDocument where intTransactionId = @currentTransId
			and intDocumentId not in
			(
				select  intSourceRecordId from #exclusionTable
			) 

			while(exists(select top 1 1 from @dmsTable))
				begin
					declare @intDocumentId int;
					declare @intDocumentSourceFolderId int;
					declare @strName nvarchar(max)
					declare @strType nvarchar(max)
					declare @intSize int
					declare @intUploadId int
					declare @intEntityId int
					declare @blbFile varbinary(max)

					declare @smUploadSQL nvarchar(max) = N''
					declare @smDocumentSQL nvarchar(max) = N''
					declare @intNewUploadId INT
					declare @intNewDocumentId INT
					

					select top 1 @intDocumentId = intDocumentId,
								@intEntityId = intEntityId,
								@intDocumentSourceFolderId = intDocumentSourceFolderId,
								@strName = strName,
								@intDocumentSourceFolderId = intDocumentSourceFolderId,
								@strType = strType,
								@intSize = intSize,
								@intUploadId = intUploadId
								
				 from @dmsTable

				 select @blbFile = blbFile from tblSMUpload where intUploadId = @intUploadId
			

				--work around on blob
				 set @smUploadSQL = N'insert into [@db].[dbo].[tblSMUpload](strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId) values(NEWID(), (select blbFile from tblSMUpload where intUploadId = @intUploadId), GETUTCDATE(), 1) ' +
									'set @id = (SELECT SCOPE_IDENTITY()) '
				 
				 set @smUploadSQL = (REPLACE(REPLACE(REPLACE(@smUploadSQL,'@blbFile',@blbFile),'@db',@dbName),'@intUploadId', @intUploadId))

				 exec sp_executesql @smUploadSQL, N'@id int output', @intNewUploadId output



				 SET @smDocumentSQL = N' insert into [@db].[dbo].[tblSMDocument] (strName, strType,dtmDateModified, intSize, intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId) ' +
										'values (@strName, @strType, GETUTCDATE(), @intSize, @intDocumentSourceFolderId, @referenceTransId, @intEntityId, @intNewUploadId, 1) ' +
										'set @id = (select scope_identity()) '

				SET @smDocumentSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@smDocumentSQL, '@strName', ''''+@strName+''''),'@strType', ''''+@strType+''''),'@intSize', @intSize),'@intDocumentSourceFolderId', @intDocumentSourceFolderId),'@referenceTransId', @referenceTransId),'@intEntityId', @intEntityId),'@intNewUploadId', @intNewUploadId),'@db', @dbName)
			
				exec sp_executesql @smDocumentSQL, N'@id int output', @intNewDocumentId OUTPUT
				
				--SAVE TO LOGGING TABLE
				insert into tblSMInterCompanyTransferLogForDMS (intSourceRecordId, intDestinationRecordId, intDestinationCompanyId,dtmDateCreated)
					values(@intDocumentId, @intNewDocumentId,@referenceCompanyId,  GETUTCDATE())
			

				 delete from @dmsTable where intDocumentId = @intDocumentId
			end

END