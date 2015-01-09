CREATE VIEW [dbo].[vyuAPBillDetailGL]
AS
SELECT
A.intBillId
,A.strBillId
,GL.strTransactionId AS strGLBillId
,A.dtmDate
,GL.dtmDate AS dtmGLDate
,A.dtmBillDate
,GL.dtmTransactionDate AS dtmGLTransactionDate
,A.dtmDueDate
,SUM(B.dblTotal) AS dblTotal
,GL.dblDebit AS dblGLTotal
,A.ysnOrigin
,A.ysnPosted
,GL.ysnIsUnposted
FROM tblAPBill A
	LEFT JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	LEFT JOIN 
	(
		SELECT TOP 100 PERCENT dtmTransactionDate, dtmDate, SUM(dblDebit) AS dblDebit, intTransactionId, strTransactionId, C.intAccountId, C.ysnIsUnposted
		FROM tblGLDetail C 
			INNER JOIN tblGLAccount D ON C.intAccountId = D.intAccountId
		WHERE C.strCode = 'AP'
		GROUP BY dtmTransactionDate, dtmDate, intTransactionId, strTransactionId, C.intAccountId,C.ysnIsUnposted
		ORDER BY C.intAccountId
	) GL
	ON A.intBillId = GL.intTransactionId AND A.strBillId = GL.strTransactionId AND B.intAccountId = GL.intAccountId
	WHERE A.ysnPosted = 1 AND ysnIsUnposted = 0 AND ysnOrigin = 0
	GROUP BY A.intBillId, A.strBillId, GL.strTransactionId, A.dtmDate, GL.dtmDate, A.dtmBillDate, GL.dtmTransactionDate, A.dtmDueDate,
	GL.dblDebit, A.ysnOrigin, A.ysnPosted, GL.ysnIsUnposted