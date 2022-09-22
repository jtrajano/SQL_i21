CREATE PROCEDURE uspGLRecalcAll
AS

EXEC dbo.uspGLSummaryRecalculate;
EXEC dbo.uspGLRecalcTrialBalance;
EXEC dbo.uspFRDGLBulkPosting;

