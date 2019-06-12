CREATE PROCEDURE [dbo].[uspARUploadAttachments]
	  @intTransactionId		INT
	, @intActivityId		INT
AS

IF(OBJECT_ID('tempdb..#ATTACHMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #ATTACHMENTS
END

SELECT intAttachmentId
INTO #ATTACHMENTS
FROM tblSMAttachment
WHERE strRecordNo = CAST(@intTransactionId AS NVARCHAR(50))
  AND strScreen = 'AccountsReceivable.Invoice'

WHILE EXISTS (SELECT TOP 1 NULL FROM #ATTACHMENTS)
	BEGIN
		DECLARE @intAttachmentId	INT = NULL
			  , @intNewAttachmentId	INT = NULL

		SELECT TOP 1 @intAttachmentId = intAttachmentId FROM #ATTACHMENTS

		INSERT INTO tblSMAttachment (
			  strName
			, strFileType
			, strFileIdentifier
			, strScreen	
			, strRecordNo
			, dtmDateModified
			, intSize
			, intEntityId
			, intConcurrencyId
		)
		SELECT strName				= A.strName
			 , strFileType			= A.strFileType
			 , strFileIdentifier	= A.strFileIdentifier
			 , strScreen			= 'GlobalComponentEngine.view.ActivityEmail'
			 , strRecordNo			= CAST(@intActivityId AS NVARCHAR(50))
			 , dtmDateModified		= GETDATE()
			 , intSize				= A.intSize
			 , intEntityId			= A.intEntityId
			 , intConcurrencyId		= 1
		FROM tblSMAttachment A
		WHERE A.intAttachmentId = @intAttachmentId

		SET @intNewAttachmentId = SCOPE_IDENTITY()

		INSERT INTO tblSMUpload (
			   intAttachmentId
			 , strFileIdentifier
			 , blbFile
			 , dtmDateUploaded
			 , intConcurrencyId
		)
		SELECT intAttachmentId		= @intNewAttachmentId
			 , strFileIdentifier	= U.strFileIdentifier
			 , blbFile				= U.blbFile
			 , dtmDateUploaded		= GETDATE()
			 , intConcurrencyId		= 1
		FROM tblSMUpload U
		WHERE U.intAttachmentId = @intAttachmentId

		DELETE FROM #ATTACHMENTS WHERE intAttachmentId = @intAttachmentId
	END