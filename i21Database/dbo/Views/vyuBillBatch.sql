CREATE VIEW vyuBillBatch
AS
SELECT 
	A.*,
	B.strAccountId AS strAccountId
FROM tblAPBillBatch A
		INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId