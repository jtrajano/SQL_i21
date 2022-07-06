CREATE PROCEDURE [dbo].[uspSMCheckPendingAttachmentFileIfPresent]
	 @fullFileName	NVARCHAR(500)
	,@isPresent BIT = 0 OUTPUT
AS	

IF EXISTS(SELECT TOP 1 1 FROM tblSMNewDocument WHERE strName = @fullFileName AND ysnForAttachment = 1)
BEGIN
	SET @isPresent = 1
END