CREATE VIEW [dbo].[vyuGLAccountDetailReportParameter] as
SELECT [dtmDate]
      ,[strBatchId]
      ,[dblDebit]
      ,[dblCredit]
      ,[dblDebitUnit]
      ,[dblCreditUnit]
      ,d.[strDescription] as strDetailDescription
      ,[strCode]
      ,d.[strReference]
      ,[strTransactionId]
      ,[strTransactionType]
      ,[strTransactionForm]
      ,[strModuleName]
      ,a.strDescription as strAccountDescription
	  ,g.strAccountGroup
	  ,g.strAccountType
	  ,detail.strReference as strReferenceDetail
	  ,detail.strDocument as strDocument
	  ,strAccountId
	  ,strUOMCode
  FROM [dbo].[tblGLDetail] d join
  tblGLAccount a on d.intAccountId = a.intAccountId join
  tblGLAccountGroup g on g.intAccountGroupId = a.intAccountGroupId 
  OUTER APPLY(
	select strUOMCode from tblGLAccountUnit unit where unit.intAccountUnitId = a.intAccountUnitId
  ) u
  OUTER APPLY(
	SELECT TOP 1 strReference,strDocument FROM tblGLJournalDetail B JOIN tblGLJournal C
	ON B.intJournalId = C.intJournalId WHERE 
	 d.intJournalLineNo = B.intJournalDetailId AND
	 C.intJournalId = d.intTransactionId AND C.strJournalId = d.strTransactionId
)detail 
WHERE ysnIsUnposted = 0