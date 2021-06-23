CREATE PROCEDURE uspCMUploadAttachment
@strFileName NVARCHAR(100),
	@strFileType NVARCHAR(50),
	@strScreen NVARCHAR(100),
	@strRecordNo NVARCHAR(20),
	@intSize INT,
	@intEntityId INT,
	@blbFile VARBINARY(MAX)
AS

	DECLARE @newFileIdentifier NVARCHAR(50)	
	DECLARE @dtmDateEntered DATETIME = GETDATE()
	SELECT @newFileIdentifier = NEWID()

	INSERT INTO tblSMAttachment(
		strName, 
		strFileType, 
		strFileIdentifier, 
		strScreen, 
		strRecordNo,
		intSize, 
		intEntityId, 
		dtmDateModified,
		intConcurrencyId)
	SELECT 
		@strFileName,
		@strFileType,
		@newFileIdentifier,
		@strScreen,
		@strRecordNo,
		@intSize,
		@intEntityId,
		@dtmDateEntered,
		1 AS [intConcurrencyId]


	DECLARE @newAttachmentId INT
	SELECT @newAttachmentId = SCOPE_IDENTITY();

	-- DUPLICATE tblSMUpload
	INSERT INTO tblSMUpload(intAttachmentId, strFileIdentifier, blbFile, dtmDateUploaded, intConcurrencyId)
	SELECT @newAttachmentId,
	@newFileIdentifier,
	@blbFile,
	@dtmDateEntered,
	1 as intConcurrencyId
	
