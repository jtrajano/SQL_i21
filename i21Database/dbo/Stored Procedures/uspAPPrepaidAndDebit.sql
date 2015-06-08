﻿CREATE PROCEDURE [dbo].[uspAPPrepaidAndDebit]
	@billId INT
AS

DECLARE @vendorId INT = (SELECT intEntityVendorId FROM tblAPBill WHERE intBillId = @billId)

--Back up old data
SELECT * INTO #tmpPrepaidAndDebit FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId

DELETE FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId

--CREATE RECORD/Repopulate
INSERT INTO tblAPAppliedPrepaidAndDebit(
	[intBillId], 
	[intBillDetailApplied], 
	[intLineApplied], 
	[intTransactionId],
	[strTransactionNumber],
	[intItemId],
	[strItemDescription],
	[strItemNo],
	[intContractHeaderId],
	[intContractNumber],
	[intPrepayType],
	[dblTotal],
	[dblBillAmount],
	[dblBalance],
	[dblAmountApplied],
	[ysnApplied],
	[intConcurrencyId]
)
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	E.strDescription,
	[strItemNo]				=	E.strItemNo,
	[intContractHeaderId]	=	CurrentBill.intContractHeaderId,	
	[intContractNumber]		=	CurrentBill.intContractNumber,
	[intPrepayType]			=	B.intPrepayTypeId,
	[dblTotal]				=	B.dblTotal,
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	B.dblTotal - (CASE B.intPrepayTypeId
									WHEN 2 THEN B.dblCost * CurrentBill.dblQtyReceived
									ELSE 0 END),
	[dblAmountApplied]		=	CASE B.intPrepayTypeId
									WHEN 2 THEN B.dblCost * CurrentBill.dblQtyReceived
									ELSE 0 END,
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblICItem E ON B.intItemId = E.intItemId
INNER JOIN 
(
	SELECT
		C.intItemId
		,C.dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,D.intContractNumber
		,D.intContractHeaderId
	FROM tblAPBillDetail C
	INNER JOIN tblCTContractHeader D ON C.intContractHeaderId = D.intContractHeaderId
	WHERE intBillId = @billId
	AND C.intContractDetailId IS NOT NULL
) CurrentBill ON B.intItemId = CurrentBill.intItemId
WHERE intTransactionType IN (2)
AND intEntityVendorId = @vendorId
AND A.dblAmountDue != 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)

--Update new data from old data
UPDATE A
	SET A.dblAmountApplied = B.dblAmountApplied
	,A.dblBalance = (A.dblTotal - B.dblAmountApplied)
FROM tblAPAppliedPrepaidAndDebit A 
INNER JOIN #tmpPrepaidAndDebit B 
	ON A.intItemId = B.intItemId AND A.intTransactionId = B.intTransactionId

SELECT * FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId

RETURN;
