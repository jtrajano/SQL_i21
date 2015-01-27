CREATE PROCEDURE [dbo].[uspGLGetImportOriginHistoricalJournalError]
	@uid UNIQUEIDENTIFIER,
	@category VARCHAR(50) OUT, 
	@result INT = 0 OUT
AS

