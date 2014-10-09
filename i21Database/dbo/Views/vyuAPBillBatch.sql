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
	B.strAccountId AS strAccountId
FROM dbo.tblAPBillBatch A
		INNER JOIN dbo.tblGLAccount B ON A.intAccountId = B.intAccountId