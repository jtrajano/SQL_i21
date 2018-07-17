GO

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
		,SUM(dblDebit) as dblDebit
		,SUM(dblCredit) as dblCredit
		,SUM(dblDebitForeign) as dblDebitForeign
		,SUM(dblCreditForeign) as dblCreditForeign
		,SUM(dblDebitUnit) as dblDebitUnit
		,SUM(dblCreditUnit) as dblCreditUnit
		,strCode
		,0 as intConcurrencyId
	FROM
		tblGLDetail
	WHERE ysnIsUnposted = 0	
	GROUP BY intAccountId, dtmDate, strCode
	PRINT N'END - Populate the Debit Unit and Credit Unit fields on all Inventory Transactions for the fist time.'
END 

GO
