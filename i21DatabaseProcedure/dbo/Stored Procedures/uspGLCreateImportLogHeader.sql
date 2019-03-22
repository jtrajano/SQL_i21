
CREATE PROCEDURE [dbo].[uspGLCreateImportLogHeader]
	(@msg VARCHAR(200),@user INT,@version VARCHAR(50),@intErrorCount INT = 0,@intSuccessCount INT = 0, @intID INT OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLCOAImportLog(dtmDate,strIrelySuiteVersion,intUserId,strEvent, intErrorCount, intSuccessCount)
	VALUES(GETDATE(),@version,@user,@msg,@intErrorCount,@intSuccessCount)
	SELECT @intID = @@IDENTITY
END