CREATE PROCEDURE [dbo].[uspARUploadAttachments]
	 @intTransactionId	INT
	,@intActivityId		INT
	,@intEntityId		INT
AS

IF(OBJECT_ID('tempdb..#ATTACHMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #ATTACHMENTS
END

SELECT
	 SMA.intAttachmentId
	,SMA.strFileIdentifier
INTO #ATTACHMENTS
FROM tblSMAttachment AS SMA
INNER JOIN dbo.tblSMTransaction AS SMT ON SMA.intTransactionId = SMT.intTransactionId
INNER JOIN dbo.tblSMScreen AS SMS ON SMT.intScreenId = SMS.intScreenId
WHERE SMT.intRecordId = @intTransactionId
AND SMS.strNamespace = 'AccountsReceivable.view.Invoice'

WHILE EXISTS (SELECT TOP 1 NULL FROM #ATTACHMENTS)
BEGIN
	DECLARE  @intAttachmentId		INT = NULL
			,@intNewAttachmentId	INT = NULL
			,@strFileIdentifier		UNIQUEIDENTIFIER = NULL

	SELECT TOP 1 
		 @intAttachmentId	= intAttachmentId
		,@strFileIdentifier = strFileIdentifier
	FROM #ATTACHMENTS

	INSERT INTO tblSMAttachment (
		 strName
		,strFileType
		,strFileIdentifier
		,strScreen	
		,strRecordNo
		,dtmDateModified
		,intSize
		,intEntityId
		,intConcurrencyId
	)
	SELECT 
		 strName			= SMA.strName
		,strFileType		= SMA.strFileType
		,strFileIdentifier	= SMA.strFileIdentifier
		,strScreen			= 'GlobalComponentEngine.view.ActivityEmail'
		,strRecordNo		= CAST(@intActivityId AS NVARCHAR(50))
		,dtmDateModified	= GETDATE()
		,intSize			= SMA.intSize
		,intEntityId		= ISNULL(SMA.intEntityId, @intEntityId)
		,intConcurrencyId	= 1
	FROM tblSMAttachment SMA
	WHERE SMA.intAttachmentId = @intAttachmentId

	SET @intNewAttachmentId = SCOPE_IDENTITY()

	INSERT INTO tblSMUpload (
		 intAttachmentId
		,strFileIdentifier
		,blbFile
		,dtmDateUploaded
		,intConcurrencyId
	)
	SELECT TOP 1
		 intAttachmentId	= @intNewAttachmentId
		,strFileIdentifier	= SMU.strFileIdentifier
		,blbFile			= SMU.blbFile
		,dtmDateUploaded	= GETDATE()
		,intConcurrencyId	= 1
	FROM tblSMUpload SMU
	WHERE SMU.strFileIdentifier = @strFileIdentifier

	DELETE FROM #ATTACHMENTS WHERE intAttachmentId = @intAttachmentId
END