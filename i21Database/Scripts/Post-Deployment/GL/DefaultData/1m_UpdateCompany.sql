PRINT 'Begin Update Company ID on tblGLJournal / tblGLJournalDetail / tblGLDetail / tblGLSummary'
GO

DECLARE @intCompanyId INT
SELECT TOP 1 @intCompanyId =intMultiCompanyId FROM tblSMCompanySetup

UPDATE tblGLDetail set intMultiCompanyId = @intCompanyId 

UPDATE tblGLJournal set intCompanyId = @intCompanyId

UPDATE tblGLJournalDetail set intCompanyId = @intCompanyId

--UPDATE tblGLSummary set intCompanyId = @intCompanyId

PRINT 'Finish Update Company ID on tblGLJournal / tblGLJournalDetail / tblGLDetail / tblGLSummary'
GO
