GO

PRINT N'BEGIN - IC Data Fix for 18.1. #5'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	-- Populate Debit Unit and Credit Unit in Inventory Transactions for the fist time
	IF EXISTS (
		SELECT TOP 1 1 
		FROM	
			tblGLDetail g INNER JOIN tblICInventoryTransaction t 
				ON g.intJournalLineNo = t.intInventoryTransactionId
		WHERE	
			(
				(g.dblDebit <> 0 AND g.dblCredit = 0 AND g.dblDebitUnit = 0)
				OR (g.dblCredit <> 0 AND g.dblDebit = 0 AND g.dblCreditUnit = 0)
			)
			AND ISNULL(t.dblQty, 0) <> 0 
	)
	BEGIN 
		PRINT N'BEGIN - Populate the Debit Unit and Credit Unit fields on all Inventory Transactions for the fist time.'

		UPDATE	g
		SET		g.dblDebitUnit = CASE WHEN g.dblDebit <> 0 AND g.dblCredit = 0 THEN ROUND(ABS(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblUOMQty, 1))), 6) ELSE 0 END 
				,g.dblCreditUnit = CASE WHEN g.dblCredit <> 0 AND g.dblDebit = 0 THEN ROUND(ABS(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblUOMQty, 1))), 6) ELSE 0 END 
		FROM	tblGLDetail g INNER JOIN tblICInventoryTransaction t 
					ON g.intJournalLineNo = t.intInventoryTransactionId
		WHERE	(
					(g.dblDebit <> 0 AND g.dblCredit = 0 AND g.dblDebitUnit = 0)
					OR (g.dblCredit <> 0 AND g.dblDebit = 0 AND g.dblCreditUnit = 0)
				)
				AND ISNULL(t.dblQty, 0) <> 0 

		DELETE [dbo].[tblGLSummary]
	
		DECLARE @intCompanyId INT
		SELECT TOP 1 @intCompanyId = intMultiCompanyId FROM tblSMCompanySetup 
		INSERT INTO tblGLSummary (
			intMultiCompanyId
			,intAccountId
			,dtmDate
			,dblDebit
			,dblCredit
			,dblDebitForeign
			,dblCreditForeign
			,dblDebitUnit
			,dblCreditUnit
			,strCode
			,intConcurrencyId
		)
		SELECT
			@intCompanyId
			,intAccountId
			,dtmDate
			,SUM(ISNULL(dblDebit, 0)) as dblDebit
			,SUM(ISNULL(dblCredit, 0)) as dblCredit
			,SUM(ISNULL(dblDebitForeign, 0)) as dblDebitForeign
			,SUM(ISNULL(dblCreditForeign, 0)) as dblCreditForeign
			,SUM(ISNULL(dblDebitUnit, 0)) as dblDebitUnit
			,SUM(ISNULL(dblCreditUnit, 0)) as dblCreditUnit
			,strCode
			,0 as intConcurrencyId
		FROM
			tblGLDetail
		WHERE ysnIsUnposted = 0	
		GROUP BY intAccountId, dtmDate, strCode
		PRINT N'END - Populate the Debit Unit and Credit Unit fields on all Inventory Transactions for the fist time.'
	END 
END
GO

PRINT N'END - IC Data Fix for 18.1. #5'
GO
