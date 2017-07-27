CREATE PROCEDURE uspGLSetParentCompany
	@intMultCompanyId int
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE tblGLDetail set intMultiCompanyId = @intMultCompanyId
	UPDATE tblGLJournal set intCompanyId = @intMultCompanyId
	UPDATE tblGLJournalDetail set intCompanyId = @intMultCompanyId
END
GO
