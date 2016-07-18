CREATE PROCEDURE [dbo].[uspICCompareGLSnapshotOnRebuildInventoryValuation]
	@dtmRebuildDate AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS (
	SELECT TOP 1 1
	FROM	dbo.tblICRebuildValuationGLSnapshot glSnapShot INNER JOIN (
				SELECT	intAccountId 		
						,[year] = YEAR(dtmDate) 
						,[month] = MONTH(dtmDate)
						,dblDebit = SUM(dblDebit)
						,dblCredit = SUM(dblCredit)		
				FROM	dbo.tblGLDetail 
				GROUP BY intAccountId, YEAR(dtmDate), MONTH(dtmDate) 
			) glActual
				ON glSnapShot.intAccountId = glActual.intAccountId
				AND glSnapShot.intYear = glActual.[year]
				AND glSnapShot.intMonth = glActual.[month]
	WHERE	dtmRebuildDate = @dtmRebuildDate
			AND (
				ISNULL(glSnapShot.dblDebit, 0) <> ISNULL(glActual.dblDebit, 0)
				OR ISNULL(glSnapShot.dblCredit,0) <> ISNULL(glActual.dblCredit, 0)
				OR ISNULL(glSnapShot.dblDebit, 0) - ISNULL(glSnapShot.dblCredit, 0) <> ISNULL(glActual.dblDebit, 0) - ISNULL(glActual.dblCredit, 0)
			)
)
BEGIN 
	-- 'Check the Rebuild Valuation GL Snapshot. The original GL values changed when compared against the rebuild values.'
	RAISERROR(80084, 11, 1)
END
