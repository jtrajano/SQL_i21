CREATE VIEW vyuAPBillBatch
WITH SCHEMABINDING
AS
SELECT 
	A.dblTotal,
	A.intAccountId,
	A.intBillBatchId,
	A.intEntityId,
	A.intUserId,
	A.strBillBatchNumber,
	A.strReference,
	A.ysnPosted,
	A.dtmBatchDate,
	B.strAccountId AS strAccountId,
	D.strUserName AS strUserId
FROM dbo.tblAPBillBatch A
		INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
		LEFT JOIN dbo.tblSMUserSecurity D ON A.intEntityId = D.intEntityId