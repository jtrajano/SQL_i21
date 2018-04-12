
------------------------------------------------------------
-- STARTING MIGRATION OF ATTACHMENTS TO DMS --
------------------------------------------------------------

	DECLARE @SQL NVARCHAR(MAX)
	
	SET @SQL = N'CREATE TABLE #tempdms
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		strRecordNo NVARCHAR(MAX),
		strScreen NVARCHAR(MAX),
		strName NVARCHAR(MAX),
		strType NVARCHAR(MAX),
		intSize INT,
		intEntityId INT,
		dtmDateModified DATETIME,
		intAttachmentId INT
	)

	INSERT INTO #tempdms(strRecordNo, strScreen, strName, strType, intSize, intEntityId,dtmDateModified, intAttachmentId) 
     SELECT a.strRecordNo ,
	 CASE WHEN (CHARINDEX(N''.view.'',a.strScreen) = 0) THEN REPLACE(a.strScreen,''.'',''.view.'')
		 ELSE a.strScreen END as strScreen , a.strName, a.strFileType, a.intSize, a.intEntityId, a.dtmDateModified, a.intAttachmentId FROM tblSMAttachment a
		 LEFT JOIN tblSMUpload b on b.intAttachmentId = a.intAttachmentId
		 WHERE strScreen in (SELECT CONCAT(SUBSTRING(strNamespace,0,CHARINDEX(''view'',strNamespace)-1),''.'',
		 REPLACE(SUBSTRING(strNamespace,CHARINDEX(''view.'',strNamespace),LEN(strNamespace)),''view.'','''')) FROM tblSMScreen WHERE ysnDocumentSource = 1)

		 

		 	
	DECLARE @strRecordNo NVARCHAR(MAX)
	DECLARE @totalrows INT = (SELECT COUNT(*) FROM #tempdms)
	DECLARE @currentrow INT = 1


	WHILE @currentrow <= @totalrows

		BEGIN
			DECLARE @resultcount INT;
			DECLARE @screen NVARCHAR(MAX) = (SELECT strScreen FROM #tempdms WHERE id = @currentrow)
			DECLARE @intScreenId INT = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @screen)


			DECLARE @strName NVARCHAR(MAX) = (SELECT strName FROM #tempdms WHERE id = @currentrow)
			SET @strRecordNo = (SELECT strRecordNo FROM #tempdms WHERE id = @currentrow)
			SET @resultcount = (SELECT  TOP 1 intTransactionId FROM tblSMTransaction WHERE CAST(intRecordId AS nvarchar(max)) = @strRecordNo AND intScreenId = @intScreenId) 

			    DECLARE @intRecordId INT = (SELECT CAST(strRecordNo AS INT) FROM #tempdms WHERE id = @currentrow)
				DECLARE @dtmDateModified DATETIME = (SELECT dtmDateModified FROM #tempdms WHERE id = @currentrow)
				DECLARE @intUploadId INT = (SELECT intUploadId FROM tblSMUpload WHERE intAttachmentId = (SELECT intAttachmentId FROM #tempdms WHERE id = @currentrow))
				DECLARE @strType NVARCHAR(MAX) = (SELECT strType FROM #tempdms WHERE id = @currentrow)
				DECLARE @intSize INT = (SELECT intSize FROM #tempdms WHERE id = @currentrow)
				DECLARE @intEntityId INT = (SELECT intEntityId FROM #tempdms WHERE id = @currentrow)
				DECLARE @transId INT = (SELECT intTransactionId FROM tblSMTransaction where intScreenId = @intScreenId and intRecordId = @intRecordId)
				DECLARE @intAttachmentId INT = (SELECT intAttachmentId FROM #tempdms WHERE id = @currentrow)
					
				IF(@resultcount = 0 OR @resultcount IS NULL)
					BEGIN
					
						IF(@transId IS NULL)
							BEGIN
								INSERT INTO tblSMTransaction (intScreenId, strTransactionNo, intRecordId) VALUES (@intScreenId,@intRecordId, @intRecordId)
								SET @transId = (SELECT SCOPE_IDENTITY())
							END

					END


					DECLARE @countExists INT
					DECLARE @sourceFolderPrimary INT
					
		

						SELECT @countExists = intDocumentSourceFolderId FROM tblSMDocumentSourceFolder WHERE strName = ''Attachment'' 
											AND intScreenId = @intScreenId AND intDocumentFolderParentId IS NULL


					  IF(@countExists = 0 OR @countExists IS NULL)
						BEGIN
							INSERT INTO tblSMDocumentSourceFolder(intScreenId, strName, intSort,intConcurrencyId) VALUES (@intScreenId,''Attachment'', 0, 1)
							SET @sourceFolderPrimary =  (SELECT SCOPE_IDENTITY())
						END
					 ELSE
						BEGIN
							SET @sourceFolderPrimary = @countExists
						END


					
				
						INSERT INTO tblSMDocument(strName, strType,dtmDateModified, intSize,intDocumentSourceFolderId, intTransactionId, intEntityId, intUploadId, intConcurrencyId)
						VALUES(@strName, @strType, @dtmDateModified, @intSize, @sourceFolderPrimary, @transId, @intEntityId, @intUploadId, 0)

						UPDATE tblSMUpload SET intAttachmentId = NULL WHERE intUploadId = @intUploadId
						--delete entry of attachment
						DELETE FROM tblSMAttachment WHERE intAttachmentId = @intAttachmentId
				

			SET @currentrow = @currentrow + 1
		END

		   DROP TABLE #tempdms'

		
		   EXEC sp_executesql @SQL
