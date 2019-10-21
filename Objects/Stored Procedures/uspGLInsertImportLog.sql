CREATE PROCEDURE dbo.[uspGLInsertImportLog]
	@intImportLogId INT = NULL,
	@strEventDescription NVARCHAR(MAX),
	@strTransactionId NVARCHAR(30) = NULL,
	@intEntityId INT = NULL, 
	@strVersion NVARCHAR(40) = NULL, 
	@strFilePath NVARCHAR(500) = NULL, 
	@strType NVARCHAR(50) = NULL -- module
AS
IF @intImportLogId IS NULL
BEGIN
	DECLARE @dtmNow DATETIME
	INSERT INTO tblGLCOAImportLog(dtmDate,strIrelySuiteVersion, intEntityId, strEvent, strJournalType,strFilePath)
	SELECT @dtmNow, @strVersion,@intEntityId,@strEventDescription, @strType, @strFilePath
	SELECT @intImportLogId = SCOPE_IDENTITY()
END
ELSE
BEGIN
	INSERT INTO tblGLCOAImportLogDetail(intImportLogId, strEventDescription,strJournalId)
	SELECT @intImportLogId, @strEventDescription,@strTransactionId
END

SELECT @intImportLogId 
