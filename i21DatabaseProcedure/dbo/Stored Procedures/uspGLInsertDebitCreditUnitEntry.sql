CREATE PROCEDURE uspGLInsertDebitCreditUnitEntry
(@importLogIds NVARCHAR(50))-- = '112'
AS
DECLARE @tbl TABLE (intJournalDetailId INT)

INSERT INTO @tbl select intJournalDetailId from tblGLJournal a join
tblGLJournalDetail b on a.intJournalId = b.intJournalId join
tblGLCOAImportLogDetail c on a.strJournalId = c.strJournalId
where c.intImportLogId in(@importLogIds)
and b.dblDebitUnit > 0 and dblCredit > 0
--select * from cte
INSERT INTO [tblGLJournalDetail]([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId]
           ,[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea],[strSourceKey],[dblDebitForeign],[dblDebitReport]
           ,[dblCreditForeign],[dblCreditReport])
SELECT [intLineNo],[intJournalId],[dtmDate],[intAccountId],
		[dblDebit] = 0,
		[dblDebitRate]= 0,
		[dblCredit]= 0,
		[dblCreditRate]= 0,
		[dblDebitUnit],
		[dblCreditUnit],
		[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],
		[strWorkArea],[strSourceKey],
		[dblDebitForeign]=0,
		[dblDebitReport]=0,
		[dblCreditForeign]=0,
		[dblCreditReport]=0
FROM tblGLJournalDetail a join @tbl b on a.intJournalDetailId = b.intJournalDetailId
UPDATE a SET dblDebitUnit = 0  from tblGLJournalDetail a JOIN @tbl b ON a.intJournalDetailId = b.intJournalDetailId  

DELETE FROM @tbl

INSERT INTO @tbl select intJournalDetailId from tblGLJournal a join
tblGLJournalDetail b on a.intJournalId = b.intJournalId join
tblGLCOAImportLogDetail c on a.strJournalId = c.strJournalId
where c.intImportLogId in(@importLogIds)
and b.dblCreditUnit > 0 and dblDebit > 0

INSERT INTO [tblGLJournalDetail]([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId]
           ,[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea],[strSourceKey],[dblDebitForeign],[dblDebitReport]
           ,[dblCreditForeign],[dblCreditReport])
SELECT [intLineNo],[intJournalId],[dtmDate],[intAccountId],
		[dblDebit]=0,
		[dblDebitRate]=0,
		[dblCredit]=0,
		[dblCreditRate]=0,
		[dblDebitUnit],
		[dblCreditUnit],
		[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea],[strSourceKey],
        [dblDebitForeign]=0,
        [dblDebitReport]=0,
        [dblCreditForeign]=0,
        [dblCreditReport]=0
        FROM tblGLJournalDetail a join @tbl b on a.intJournalDetailId = b.intJournalDetailId
UPDATE a SET dblCreditUnit = 0  from tblGLJournalDetail a JOIN @tbl b ON a.intJournalDetailId = b.intJournalDetailId  

GO

