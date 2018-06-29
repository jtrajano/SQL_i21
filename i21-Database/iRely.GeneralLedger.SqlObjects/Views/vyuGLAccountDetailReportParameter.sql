CREATE VIEW [dbo].[vyuGLAccountDetailReportParameter] as
SELECT  [strBatchId]
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
	  ,a.strAccountId
	  ,strUOMCode
	  ,[Primary Account] as PrimaryAccount
  FROM [dbo].[tblGLDetail] d join
  tblGLAccount a on d.intAccountId = a.intAccountId join
  tblGLAccountGroup g on g.intAccountGroupId = a.intAccountGroupId join
  tblGLTempCOASegment s on a.intAccountId = s.intAccountId
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