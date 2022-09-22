CREATE PROCEDURE uspGLRecalcAll
AS

EXEC dbo.uspGLSummaryRecalculate;
GO
EXEC dbo.uspGLRecalcTrialBalance;
GO
EXEC dbo.uspFRDGLBulkPosting
GO
