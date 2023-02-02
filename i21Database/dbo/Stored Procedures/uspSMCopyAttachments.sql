CREATE PROCEDURE [dbo].[uspSMCopyAttachments]
	@srcNamespace	NVARCHAR(150),
	@srcRecordId	INT,
	@destNamespace	NVARCHAR(150),
	@destRecordId	INT,
	@ErrorMessage	NVARCHAR(MAX) OUTPUT,
	@srcIntAttachmentId INT = NULL
AS
BEGIN TRY

	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT
	DECLARE @ErrorNumber INT
	DECLARE @newAttachmentId INT

	BEGIN TRANSACTION

	-- START - SOURCE VALIDATION
	IF NOT EXISTS (	SELECT		TOP 1 1 
					FROM		tblSMScreen 
					WHERE		strNamespace = @srcNamespace)
		INSERT INTO		tblSMScreen (strNamespace, strScreenId, strScreenName, strModule )
			SELECT		@srcNamespace AS strNamespace,
						'' AS strScreenId,
						dbo.fnSMAddSpaceToTitleCase(SUBSTRING(SUBSTRING(@srcNamespace,CHARINDEX('.',@srcNamespace) + 1, LEN(@srcNamespace)), CHARINDEX('.', SUBSTRING(@srcNamespace,CHARINDEX('.',@srcNamespace) + 1, LEN(@srcNamespace))) + 1, LEN(SUBSTRING(@srcNamespace,CHARINDEX('.',@srcNamespace) + 1, LEN(@srcNamespace)))), 0) AS strScreenName,
						CASE WHEN SUBSTRING(@srcNamespace,0,CHARINDEX('.',@srcNamespace)) = 'i21' THEN 'System Manager'  --module
	 					ELSE dbo.fnSMAddSpaceToTitleCase(SUBSTRING(@srcNamespace,0,CHARINDEX('.',@srcNamespace)),0) END AS strModule

	IF NOT EXISTS (	SELECT		TOP 1 1 
					FROM		tblSMTransaction AS a 
					INNER JOIN	tblSMScreen AS b 
					ON			a.intScreenId = b.intScreenId 
					WHERE		b.strNamespace = @srcNamespace 
							AND a.intRecordId = @srcRecordId)
		INSERT INTO		tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
			SELECT		(SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = @srcNamespace) AS intScreenId,
						@srcRecordId as intRecordId,
						1

	UPDATE		tblSMAttachment
	SET			intTransactionId = (SELECT		a.intTransactionId
									FROM		tblSMTransaction AS a
									INNER JOIN  tblSMScreen AS b
									ON			a.intScreenId = b.intScreenId
									WHERE		b.strNamespace = @srcNamespace
											AND a.intRecordId = @srcRecordId)
	WHERE		strScreen = @srcNamespace
			AND strRecordNo = CAST(@srcRecordId AS NVARCHAR(50))
			AND intTransactionId IS NULL
	-- END - SOURCE VALIDATION

	-- START - DESTINATION VALIDATION
	IF NOT EXISTS (	SELECT		TOP 1 1 
					FROM		tblSMScreen 
					WHERE		strNamespace = @destNamespace)
		INSERT INTO		tblSMScreen (strNamespace, strScreenId, strScreenName, strModule )
			SELECT		@destNamespace AS strNamespace,
						'' AS strScreenId,
						dbo.fnSMAddSpaceToTitleCase(SUBSTRING(SUBSTRING(@destNamespace,CHARINDEX('.',@destNamespace) + 1, LEN(@destNamespace)), CHARINDEX('.', SUBSTRING(@destNamespace,CHARINDEX('.',@destNamespace) + 1, LEN(@destNamespace))) + 1, LEN(SUBSTRING(@destNamespace,CHARINDEX('.',@destNamespace) + 1, LEN(@destNamespace)))), 0) AS strScreenName,
						CASE WHEN SUBSTRING(@destNamespace,0,CHARINDEX('.',@destNamespace)) = 'i21' THEN 'System Manager'  --module
	 					ELSE dbo.fnSMAddSpaceToTitleCase(SUBSTRING(@destNamespace,0,CHARINDEX('.',@destNamespace)),0) END AS strModule

	IF NOT EXISTS (	SELECT		TOP 1 1 
					FROM		tblSMTransaction AS a 
					INNER JOIN	tblSMScreen AS b 
					ON			a.intScreenId = b.intScreenId 
					WHERE		b.strNamespace = @destNamespace 
							AND a.intRecordId = @destRecordId)
		INSERT INTO		tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
			SELECT		(SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = @destNamespace) AS intScreenId,
						@destRecordId as intRecordId,
						1

	UPDATE		tblSMAttachment
	SET			intTransactionId = (SELECT		a.intTransactionId
									FROM		tblSMTransaction AS a
									INNER JOIN  tblSMScreen AS b
									ON			a.intScreenId = b.intScreenId
									WHERE		b.strNamespace = @destNamespace
											AND a.intRecordId = @destRecordId)
	WHERE		strScreen = @destNamespace
			AND strRecordNo = CAST(@destRecordId AS NVARCHAR(50))
			AND intTransactionId IS NULL
	-- END - DESTINATION VALIDATION

	-- START - COPY ATTACHMENTS
	INSERT INTO tblSMAttachment (intTransactionId, strName, strFileType, strFileIdentifier, strScreen, strComment, strRecordNo, strType, ysnOcrProcessed, dtmDateModified, intSize, intEntityId, ysnDisableDelete, intConcurrencyId)
	SELECT		(SELECT		a.intTransactionId
				 FROM		tblSMTransaction AS a
				 INNER JOIN  tblSMScreen AS b
				 ON			a.intScreenId = b.intScreenId
				 WHERE		b.strNamespace = @destNamespace
						AND a.intRecordId = @destRecordId) AS intTransactionId,
				a.strName,
				a.strFileType,
				a.strFileIdentifier,
				@destNamespace,
				a.strComment,
				@destRecordId,
				a.strType,
				a.ysnOcrProcessed,
				GETUTCDATE(),
				a.intSize,
				a.intEntityId,
				a.ysnDisableDelete,
				1
	FROM		dbo.tblSMAttachment AS a
	INNER JOIN	dbo.tblSMTransaction AS b
	ON			a.intTransactionId = b.intTransactionId
	INNER JOIN	dbo.tblSMScreen AS c
	ON			b.intScreenId = c.intScreenId
	WHERE		c.strNamespace = @srcNamespace
			AND	b.intRecordId = @srcRecordId
			AND (@srcIntAttachmentId IS NULL OR a.intAttachmentId = @srcIntAttachmentId)
	-- END - COPY ATTACHMENTS		

	SET @newAttachmentId = (SELECT SCOPE_IDENTITY())
	IF ISNULL(@newAttachmentId, 0) <> 0
	BEGIN
		INSERT INTO tblSMUpload(intAttachmentId, strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId)
		VALUES (
			@newAttachmentId
			, NEWID()
			, (SELECT blbFile FROM tblSMUpload WHERE intAttachmentId = @srcIntAttachmentId)
			, GETUTCDATE()
			, 1
		)
	END

	COMMIT TRANSACTION
END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)

END CATCH