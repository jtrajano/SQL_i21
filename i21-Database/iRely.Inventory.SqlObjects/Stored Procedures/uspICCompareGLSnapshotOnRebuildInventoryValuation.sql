CREATE PROCEDURE [dbo].[uspICCompareGLSnapshotOnRebuildInventoryValuation]
	@dtmRebuildDate AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS (SELECT TOP 1 1 FROM vyuICCompareRebuildValuationSnapshot WHERE dtmRebuildDate = @dtmRebuildDate)
BEGIN 
	-- 'Check the Rebuild Valuation GL Snapshot. The original GL values changed when compared against the rebuild values.'
	DECLARE @strRebuildDate AS NVARCHAR(50) 
	
	-- Show the rebuild date as ODBC canonical (with milliseconds) 
	SET @strRebuildDate = CONVERT(NVARCHAR(50), @dtmRebuildDate, 121)

	EXEC uspICRaiseError 80084, @strRebuildDate;
END
