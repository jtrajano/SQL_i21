CREATE PROCEDURE [dbo].[uspGLCreateImportLogHeader]
	(@msg VARCHAR(200),@user INT,@version VARCHAR(50),@intID INT OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLCOAImportLog(dtmDate,strIrelySuiteVersion,intUserId,strEvent)
	VALUES(GETDATE(),@version,@user,@msg)
	SELECT @intID = @@IDENTITY
END