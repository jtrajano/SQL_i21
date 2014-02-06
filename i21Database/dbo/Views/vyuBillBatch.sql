CREATE VIEW vyuBillBatch
AS
SELECT 
	A.*,
	B.strAccountID AS strAccountId
FROM tblAPBillBatch A
		INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountID