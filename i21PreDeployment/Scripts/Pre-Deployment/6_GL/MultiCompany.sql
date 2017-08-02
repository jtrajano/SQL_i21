
DECLARE @intCompanyId INT
SELECT TOP 1 @intCompanyId = intMultiCompanyId FROM tblSMCompanySetup 
UPDATE tblGLDetail set intMultiCompanyId = @intCompanyId where intMultiCompanyId is null
UPDATE tblGLJournal SET intCompanyId = @intCompanyId 
UPDATE tblGLJournalDetail SET intCompanyId = @intCompanyId 

GO