CREATE PROCEDURE [dbo].[uspSMEventSetActive]
	@screen AS NVARCHAR(100),
	@recordNo AS NVARCHAR(100),
	@active AS BIT

AS

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMEvents')
BEGIN

	UPDATE tblSMEvents
	SET ysnActive = @active
	WHERE strScreen = @screen AND strRecordNo = @recordNo

END