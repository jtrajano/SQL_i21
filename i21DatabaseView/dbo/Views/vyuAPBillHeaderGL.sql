CREATE VIEW [dbo].[vyuAPBillHeaderGL]
AS
SELECT * FROM (
	SELECT
	A.intBillId
	,A.strBillId
	,GL.strTransactionId AS strGLBillId
	,A.dtmDate
	,GL.dtmDate AS dtmGLDate
	,A.dtmBillDate
	,GL.dtmTransactionDate AS dtmGLTransactionDate
	,A.dtmDueDate
	,A.dblTotal
	,GL.dblGLTotal
	,A.ysnOrigin
	,A.ysnPosted
	,GL.ysnIsUnposted
	FROM tblAPBill A
		LEFT JOIN vyuAPGLByAccount GL
			ON A.intBillId = GL.intTransactionId 
			AND A.strBillId = GL.strTransactionId 
			AND A.intAccountId = GL.intAccountId) BillHeaderGL
WHERE ysnOrigin = 0 AND ysnIsUnposted = 0