--VIEWS
IF EXISTS (SELECT * FROM sys.sysobjects WHERE ID = OBJECT_ID(N'vyu_VendorHistory') AND OBJECTPROPERTY(ID, N'IsView') = 1) 
DROP VIEW vyu_VendorHistory

GO

CREATE VIEW vyu_VendorHistory
AS
SELECT 
	strVendorId = A.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = 'Bill'
	,dblTotal = ISNULL(A.dblTotal,0)
	,dblAmountPaid = ISNULL(SUM(B.dblPayment),0)
	,CAST((CASE WHEN (A.dblTotal - SUM(B.dblPayment) = 0) THEN 1 ELSE 0 END) AS BIT) AS ysnPaid
	,dblAmountDue = ISNULL(A.dblTotal,0) - ISNULL(SUM(B.dblPayment),0)
FROM tblAPBills A
		LEFT JOIN tblAPPaymentDetails B ON A.intBillId = B.intBillId
GROUP BY A.intBillId, A.dtmDate, A.dblTotal, A.strVendorId

GO

IF EXISTS (SELECT * FROM sys.sysobjects WHERE ID = OBJECT_ID(N'vyuBillBatch') AND OBJECTPROPERTY(ID, N'IsView') = 1) 
DROP VIEW vyuBillBatch

GO

CREATE VIEW vyuBillBatch
AS
SELECT 
	A.*,
	B.strAccountID AS strAccountId
FROM tblAPBillBatches A
		INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountID

GO