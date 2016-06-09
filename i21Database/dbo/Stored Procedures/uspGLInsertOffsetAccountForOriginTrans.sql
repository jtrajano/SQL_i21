CREATE PROCEDURE uspGLInsertOffsetAccountForOriginTrans
AS
BEGIN
	DECLARE @result INT = 0
	IF OBJECT_ID('tempdb..##OutOfbalance') IS NOT NULL DROP TABLE ##OutOfbalance

	SELECT  SUM(A.dblDebit) as TotalDebit, SUM(A.dblCredit) as TotalCredit, B.strJournalId
	INTO ##OutOfbalance
	FROM 
		tblGLJournalDetail A INNER JOIN 
		tblGLJournal B ON A.intJournalId = B.intJournalId
		AND B.strJournalType in ( 'Origin Journal','Adjusted Origin Journal')
	GROUP BY  B.strJournalId
	HAVING SUM(A.dblDebit)<> SUM(A.dblCredit)

	IF EXISTS (SELECT TOP 1 1 FROM ##OutOfbalance)
	BEGIN
		DECLARE @balance NUMERIC(18,6)
		SELECT @balance =sum (TotalDebit-TotalCredit) FROM ##OutOfbalance
		IF @balance = 0
		BEGIN
			DECLARE @Id INT
			SELECT TOP 1 @Id = OriginConversion_OffsetAccountId FROM tblGLCompanyPreferenceOption 
			INSERT tblGLJournalDetail (intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,
				dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,dblUnitsInLBS,strDocument,
				strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea)
			SELECT	max(intLineNo)+1,	A.intJournalId,	B.dtmDate,	@Id,
				CASE WHEN SUM(dblDebit)-SUM(dblCredit) <0 THEN (SUM(dblDebit)-SUM(dblCredit) )*-1
				ELSE 0 END,
				0,
				CASE WHEN SUM(dblDebit)-SUM(dblCredit) >0 THEN SUM(dblDebit)-SUM(dblCredit)
				ELSE 0 END,
				0,0,0,
				'Wash from historic import',1,0,'',NULL,'Wash',0,'N',NULL,'',''
			FROM tblGLJournalDetail A INNER JOIN 
				tblGLJournal B ON A.intJournalId = B.intJournalId INNER JOIN
				##OutOfbalance C ON B.strJournalId = C.strJournalId
 			GROUP BY  A.intJournalId, B.dtmDate

			SELECT @result = @@ROWCOUNT
			
		END
	END
	
	IF OBJECT_ID('tempdb..##OutOfbalance') IS NOT NULL DROP TABLE ##OutOfbalance

	RETURN @result
END