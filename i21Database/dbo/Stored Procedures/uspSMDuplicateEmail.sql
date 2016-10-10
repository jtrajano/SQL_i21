CREATE PROCEDURE [dbo].[uspSMDuplicateEmail]
	@intEmailId INT,
	@newEmailId INT OUTPUT
AS
BEGIN

	DECLARE @newImageId NVARCHAR(50)
	DECLARE @imageId NVARCHAR(50)
	DECLARE @screen NVARCHAR(150)
	DECLARE @recordNo NVARCHAR(50)
	DECLARE @entityId INT
	DECLARE @startingNo NVARCHAR(50)
	
	DECLARE @fileIdentifier NVARCHAR(50)
	SELECT @newImageId = NEWID()
	SELECT @imageId = [strImageId] FROM tblSMActivity WHERE intActivityId = @intEmailId
	SELECT @recordNo = CAST (intActivityId AS NVARCHAR(50)) FROM tblSMActivity WHERE intActivityId = @intEmailId
	SELECT @entityId = intEntityId FROM tblSMActivity WHERE intActivityId = @intEmailId

	EXEC uspSMGetStartingNumber 103, @startingNo OUT

	-- DUPLICATE tblSMActivity
	INSERT tblSMActivity([intTransactionId], [strType], [strSubject], [intEntityId], [dtmStartDate], [dtmEndDate], [dtmStartTime], [dtmEndTime], [strStatus], [strPriority], [strActivityNo], [strDetails], [dtmCreated], [intCreatedBy], [strImageId], [strMessageType], [strFilter])
	SELECT [intTransactionId]
	,'Email'
	,'FW: ' + [strSubject]
	,[intEntityId]
	,[dtmStartDate]
	,[dtmEndDate]
	,[dtmStartTime]
	,[dtmEndTime]
	,'Forward' AS [strStatus]
	,[strPriority]
	,@startingNo
	,[strDetails]
	,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) as [dtmCreated]
	,[intCreatedBy]
	,@newImageId as [strImageId]
	,[strMessageType]
	,[strFilter]
	FROM tblSMActivity
	WHERE [intActivityId] = @intEmailId;
	
	SELECT @newEmailId = SCOPE_IDENTITY();

	---- DUPLICATE tblSMEmailRecipient
	--INSERT INTO tblSMEmailRecipient(intEmailId, intEntityId, strEmailAddress, strRecipientType)
	--SELECT @newEmailId,
	--intEntityId,
	--strEmailAddress,
	--strRecipientType
	--FROM tblSMEmailRecipient
	--WHERE intEmailId = @intEmailId

	-- DUPLICATE tblSMEmailUpload
	INSERT INTO tblSMEmailUpload([strImageId], [strFileIdentifier], [strFilename], [strFileLocation], [blbFile])
	SELECT @newImageId,
	[strFileIdentifier],
	[strFilename],
	[strFileLocation],
	[blbFile]
	FROM tblSMEmailUpload
	WHERE [strImageId] = @imageId

	-- LOOP THROUGH ATTACHMENTS

	SET @screen = 'GlobalComponentEngine.view.ActivityEmail'

	DECLARE @currentRow1 INT
	DECLARE @totalRows1 INT
	DECLARE @newFileIdentifier NVARCHAR(50)	

	SET @currentRow1 = 1
	SELECT @totalRows1 = Count(*) FROM tblSMAttachment WHERE strScreen = @screen AND strRecordNo = @recordNo AND intEntityId = @entityId

	WHILE (@currentRow1 <= @totalRows1)
	BEGIN

	DECLARE @attachmentId INT
	DECLARE @newAttachmentId INT
	
	SELECT @attachmentId = intAttachmentId FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY intAttachmentId ASC) AS 'ROWID', *
		FROM tblSMAttachment
		WHERE strScreen = @screen AND strRecordNo = @recordNo AND intEntityId = @entityId
	) a
	WHERE ROWID = @currentRow1

	SELECT @newFileIdentifier = NEWID()

	-- DUPLICATE tblSMAttachment
	INSERT INTO tblSMAttachment(strName, strFileType, strFileIdentifier, strScreen, strComment, strRecordNo, dtmDateModified, intSize, intEntityId, intConcurrencyId)
	SELECT [strName],
	[strFileType],
	@newFileIdentifier AS [strFileIdentifier],
	[strScreen],
	[strComment],
	@newEmailId AS [strRecordNo],
	[dtmDateModified],
	[intSize],
	[intEntityId],
	1 AS [intConcurrencyId]
	FROM tblSMAttachment
	WHERE intAttachmentId = @attachmentId

	SELECT @newAttachmentId = SCOPE_IDENTITY();

	-- DUPLICATE tblSMUpload
	INSERT INTO tblSMUpload(intAttachmentId, strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId)
	SELECT @newAttachmentId,
	@newFileIdentifier AS strFileIdentifier,
	blbFile,
	dtmDateUploaded,
	1 as intConcurrencyId
	FROM tblSMUpload
	WHERE intAttachmentId = @attachmentId

	SET @currentRow1 = @currentRow1 + 1
	END

END