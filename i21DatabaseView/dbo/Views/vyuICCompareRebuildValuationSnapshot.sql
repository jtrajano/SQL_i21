CREATE VIEW [dbo].[vyuICCompareRebuildValuationSnapshot]
AS
SELECT	glSnapShot.intAccountId
		,glAccnt.strAccountId
		,glAccnt.strDescription
		,glSnapShot.dtmRebuildDate
		,glSnapShot.intYear
		,glSnapShot.intMonth
		,[dblDebit_Snapshot] = glSnapShot.dblDebit
		,[dblCredit_Snapshot] = glSnapShot.dblCredit
		,[dblDebit_ActualGLDetail] = glActual.dblDebit
		,[dblCredit_ActualGLDetail] = glActual.dblCredit
		,[Debit Diff] = glSnapShot.dblDebit - glActual.dblDebit
		,[Credit Diff] = glSnapShot.dblCredit - glActual.dblCredit
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
		INNER JOIN tblGLAccount glAccnt
			ON glAccnt.intAccountId = glSnapShot.intAccountId 
WHERE	(
			ISNULL(glSnapShot.dblDebit, 0) <> ISNULL(glActual.dblDebit, 0)
			OR ISNULL(glSnapShot.dblCredit,0) <> ISNULL(glActual.dblCredit, 0)
			OR ISNULL(glSnapShot.dblDebit, 0) - ISNULL(glSnapShot.dblCredit, 0) <> ISNULL(glActual.dblDebit, 0) - ISNULL(glActual.dblCredit, 0)
		)