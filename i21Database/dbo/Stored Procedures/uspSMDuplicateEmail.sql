﻿CREATE PROCEDURE [dbo].[uspSMDuplicateEmail]
	@intEmailId INT,
	@newEmailId INT OUTPUT
AS
BEGIN

	
	DECLARE @newImageId NVARCHAR(50)
	DECLARE @imageId NVARCHAR(50)
	DECLARE @screen NVARCHAR(150)
	DECLARE @recordNo NVARCHAR(50)
	DECLARE @entityId INT
	
	DECLARE @fileIdentifier NVARCHAR(50)
	SELECT @newImageId = NEWID()
	SELECT @imageId = [strImageId] FROM tblSMEmail WHERE intEmailId = @intEmailId
	SELECT @screen = strScreen FROM tblSMEmail WHERE intEmailId = @intEmailId
	SELECT @recordNo = CAST (intEmailId AS NVARCHAR(50)) FROM tblSMEmail WHERE intEmailId = @intEmailId
	SELECT @entityId = intEntityId FROM tblSMEmail WHERE intEmailId = @intEmailId

	-- DUPLICATE tblSMEmail
	INSERT dbo.tblSMEmail([intEntityId], [strScreen], [strSubject], [strMessage], [strImageId], [strMessageType], [strStatus], [strFilter],[dtmDate])
	SELECT [intEntityId],
	[strScreen],
    'FW: ' + [strSubject],
    [strMessage],
	@newImageId as [strImageId],
	[strMessageType],
	'Forward' AS [strStatus],
	[strFilter],
	CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) as [dtmDate]
	FROM dbo.tblSMEmail
	WHERE [intEmailId] = @intEmailId;
	
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