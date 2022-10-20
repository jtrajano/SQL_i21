CREATE VIEW [dbo].[vyuGLIntraCompanyAccountSegment]
AS 
SELECT 
	ICAS.* 
	,strTransactionCompanySegment = TransactionCompany.strCode
	,strInterCompanySegment = InterCompany.strCode
	,strDueFromSegment = DueFrom.strCode
	,strDueToSegment = DueTo.strCode
FROM [dbo].[tblGLIntraCompanyAccountSegment] ICAS
LEFT JOIN [dbo].[tblGLAccountSegment] TransactionCompany
	ON ICAS.intTransactionCompanySegmentId = TransactionCompany.intAccountSegmentId
LEFT JOIN [dbo].[tblGLAccountSegment] InterCompany
	ON ICAS.intInterCompanySegmentId = InterCompany.intAccountSegmentId
LEFT JOIN [dbo].[tblGLAccountSegment] DueFrom
	ON ICAS.intDueFromSegmentId = DueFrom.intAccountSegmentId
LEFT JOIN [dbo].[tblGLAccountSegment] DueTo
	ON ICAS.intDueToSegmentId = DueTo.intAccountSegmentId