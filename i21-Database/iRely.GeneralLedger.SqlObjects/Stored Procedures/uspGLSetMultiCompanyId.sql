CREATE PROCEDURE uspGLSetMultiCompanyId
	@intMultCompanyId int
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE tblGLDetail set intMultiCompanyId = @intMultCompanyId WHERE intMultiCompanyId IS NULL
	UPDATE tblGLJournal set intCompanyId = @intMultCompanyId WHERE intCompanyId IS NULL
	UPDATE tblGLJournalDetail set intCompanyId = @intMultCompanyId WHERE intCompanyId IS NULL
END
GO
