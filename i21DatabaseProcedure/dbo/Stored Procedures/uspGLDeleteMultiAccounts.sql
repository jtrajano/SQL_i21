CREATE PROCEDURE uspGLDeleteMultiAccounts
@SQLString NVARCHAR(MAX)
AS
DECLARE  @tblAccounts TABLE (intAccountId INT, ysnDeleted BIT )
DECLARE @intAccountId INT
INSERT INTO @tblAccounts(intAccountId) EXEC(@SQLString)
WHILE EXISTS (SELECT TOP 1 1 FROM @tblAccounts WHERE ysnDeleted IS NULL)
BEGIN
	SELECT TOP 1 @intAccountId=intAccountId FROM @tblAccounts WHERE ysnDeleted IS NULL
	EXEC uspGLDeleteAccount @intAccountId
	UPDATE @tblAccounts SET ysnDeleted = 1 WHERE intAccountId = @intAccountId
END
