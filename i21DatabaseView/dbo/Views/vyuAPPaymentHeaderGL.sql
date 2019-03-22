CREATE VIEW [dbo].[vyuAPPaymentHeaderGL]
AS

SELECT
	A.intPaymentId
	,A.strPaymentRecordNum
	,GL.strTransactionId AS strGLBillId
	,A.dtmDatePaid
	,GL.dtmDate AS dtmGLDate
	,GL.dtmTransactionDate AS dtmGLTransactionDate
	,CASE WHEN B.ysnCheckVoid = 1 THEN 0 ELSE A.dblAmountPaid END AS dblTotal
	,GL.dblGLTotal
	,A.ysnOrigin
	,A.ysnPosted
	,GL.ysnIsUnposted
	,B.ysnCheckVoid
FROM tblAPPayment A
	INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
		LEFT JOIN vyuAPGLByAccount GL
		ON A.intPaymentId = GL.intTransactionId 
		AND A.strPaymentRecordNum = GL.strTransactionId 
		AND A.intAccountId = GL.intAccountId
WHERE ysnOrigin = 0
