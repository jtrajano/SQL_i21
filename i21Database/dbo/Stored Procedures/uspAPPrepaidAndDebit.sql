CREATE PROCEDURE [dbo].[uspAPPrepaidAndDebit]
	@billId INT
AS

IF ((SELECT ysnPosted FROM tblAPBill WHERE intBillId = @billId) = 1)
BEGIN
	RAISERROR('Bill already posted.', 16, 1);
	RETURN;
END

DECLARE @vendorId INT = (SELECT intEntityVendorId FROM tblAPBill WHERE intBillId = @billId);

--DECLARE @tmpPrepaidAndDebit TABLE
--(
--	[intBillId] INT NOT NULL, 
--    [intBillDetailApplied] INT NULL, 
--	[intLineApplied] INT NULL, 
--	[intTransactionId] INT NOT NULL,
--	[strTransactionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
--	[intItemId] INT NULL,
--	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
--	[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
--	[intContractHeaderId] INT NULL,
--	[intContractNumber] INT NULL,
--	[intPrepayType] INT NULL,
--	[dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0,
--	[dblBillAmount] DECIMAL(18, 6) NOT NULL DEFAULT 0,
--	[dblBalance] DECIMAL(18, 6) NOT NULL DEFAULT 0,
--	[dblAmountApplied] DECIMAL(18, 6) NOT NULL DEFAULT 0,
--    [ysnApplied] BIT NOT NULL DEFAULT 0,
--	[intConcurrencyId] INT NOT NULL DEFAULT 0
--);
--SELECT * INTO #tmpPrepaidAndDebit FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId
DELETE A
FROM tblAPAppliedPrepaidAndDebit A 
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
WHERE B.intBillId = @billId
AND B.ysnPosted = 0

--WITH AppliedPrepaidAndDebitMemo (intTransactionId, dblAmountApplied)
--AS
--(
--	SELECT
--		A.intBillId AS intTransactionId,
--		SUM(dblPayment) dblAmountApplied
--	FROM tblAPBill A
--	WHERE A.intEntityVendorId = (SELECT intEntityVendorId FROM tblAPBill WHERE intBillId = @billId) -- GET ALL APPLIED FOR VENDOR OF CURRENT BILL
--	AND A.intTransactionType IN (2,3,8)
--	AND 1 = CASE WHEN A.intTransactionType= 3 AND A.ysnPosted != 1 --DEBIT MEMO should be posted
--			 THEN 0 ELSE 1 END
--	GROUP BY A.intBillId
--)

----CREATE RECORD/Repopulate
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
--PREPAYMENT
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
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN B.dblCost * B.dblQtyReceived
											ELSE B.dblCost * CurrentBill.dblQtyReceived END
									WHEN 3 THEN
										CASE WHEN B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN B.dblTotal
											ELSE ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) END
									ELSE 0 END)
									- ISNULL(A.dblPayment,0),
	[dblAmountApplied]		=	CASE B.intPrepayTypeId 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN B.dblCost * B.dblQtyReceived
											ELSE B.dblCost * CurrentBill.dblQtyReceived END
									WHEN 3 THEN
										CASE WHEN B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN B.dblTotal
											ELSE ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) END
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
--LEFT JOIN AppliedPrepaidAndDebitMemo D ON D.intTransactionId = A.intBillId
WHERE A.intTransactionType IN (2)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0 --EXCLUDE THOSE FULLY APPLIED
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)
UNION ALL
--DEBIT MEMO AND OVERPAYMENT
SELECT
		[intBillId]				=	@billId, 
		[intBillDetailApplied]	=	NULL, 
		[intLineApplied]		=	NULL, 
		[intTransactionId]		=	A.intBillId,
		[strTransactionNumber]	=	A.strBillId,
		[intItemId]				=	NULL,
		[strItemDescription]	=	NULL,
		[strItemNo]				=	NULL,
		[intContractHeaderId]	=	NULL,	
		[intContractNumber]		=	NULL,
		[intPrepayType]			=	NULL,
		[dblTotal]				=	A.dblTotal,
		[dblBillAmount]			=	(SELECT dblTotal FROM tblAPBill WHERE intBillId = @billId),
		[dblBalance]			=	A.dblAmountDue - (CASE WHEN ISNULL(A.dblPayment,0) = 0 THEN A.dblAmountDue ELSE ISNULL(A.dblPayment,0) END),
		[dblAmountApplied]		=	A.dblAmountDue,
		[ysnApplied]			=	0,
		[intConcurrencyId]		=	0
	FROM tblAPBill A
	--LEFT JOIN tblAPAppliedPrepaidAndDebit B ON B.intTransactionId = A.intBillId
	WHERE A.intTransactionType IN (3,8)
	AND A.intEntityVendorId = @vendorId
	AND A.dblAmountDue != 0 --EXCLUDE THOSE FULLY APPLIED
	AND 1 = CASE WHEN A.intTransactionType = 3 AND A.ysnPosted = 0 THEN 0 --EXCLUDE UNPOSTED DEBIT MEMO
			ELSE 1 END

----PREPAYMENT
--MERGE tblAPAppliedPrepaidAndDebit AS Target
--USING (
	
--) AS Source
--ON (Target.intItemId = Source.intItemId AND Target.intBillId = Source.intBillId AND Target.intLineApplied = Source.intLineApplied)
--WHEN MATCHED THEN
--	UPDATE 
--		SET Target.dblAmountApplied = Source.dblAmountApplied
--		,Target.dblBalance = Source.dblBalance
--WHEN NOT MATCHED BY TARGET THEN
--	INSERT (
--		[intBillId], 
--		[intBillDetailApplied], 
--		[intLineApplied], 
--		[intTransactionId],
--		[strTransactionNumber],
--		[intItemId],
--		[strItemDescription],
--		[strItemNo],
--		[intContractHeaderId],
--		[intContractNumber],
--		[intPrepayType],
--		[dblTotal],
--		[dblBillAmount],
--		[dblBalance],
--		[dblAmountApplied],
--		[ysnApplied],
--		[intConcurrencyId]
--	)VALUES(
--		Source.[intBillId], 
--		Source.[intBillDetailApplied], 
--		Source.[intLineApplied], 
--		Source.[intTransactionId],
--		Source.[strTransactionNumber],
--		Source.[intItemId],
--		Source.[strItemDescription],
--		Source.[strItemNo],
--		Source.[intContractHeaderId],
--		Source.[intContractNumber],
--		Source.[intPrepayType],
--		Source.[dblTotal],
--		Source.[dblBillAmount],
--		Source.[dblBalance],
--		Source.[dblAmountApplied],
--		Source.[ysnApplied],
--		Source.[intConcurrencyId]
--	)
--WHEN NOT MATCHED BY SOURCE AND Target.intBillId = @billId THEN DELETE;

----DEBIT MEMO AND OVERPAYMENT
--MERGE tblAPAppliedPrepaidAndDebit AS Target
--USING (
	
--) AS Source
--ON (Target.intBillId = Source.intBillId)
--WHEN MATCHED THEN
--	UPDATE 
--		SET Target.dblAmountApplied = Source.dblAmountApplied
--		,Target.dblBalance = Source.dblBalance
--WHEN NOT MATCHED BY TARGET THEN
--	INSERT (
--		[intBillId], 
--		[intBillDetailApplied], 
--		[intLineApplied], 
--		[intTransactionId],
--		[strTransactionNumber],
--		[intItemId],
--		[strItemDescription],
--		[strItemNo],
--		[intContractHeaderId],
--		[intContractNumber],
--		[intPrepayType],
--		[dblTotal],
--		[dblBillAmount],
--		[dblBalance],
--		[dblAmountApplied],
--		[ysnApplied],
--		[intConcurrencyId]
--	)VALUES(
--		Source.[intBillId], 
--		Source.[intBillDetailApplied], 
--		Source.[intLineApplied], 
--		Source.[intTransactionId],
--		Source.[strTransactionNumber],
--		Source.[intItemId],
--		Source.[strItemDescription],
--		Source.[strItemNo],
--		Source.[intContractHeaderId],
--		Source.[intContractNumber],
--		Source.[intPrepayType],
--		Source.[dblTotal],
--		Source.[dblBillAmount],
--		Source.[dblBalance],
--		Source.[dblAmountApplied],
--		Source.[ysnApplied],
--		Source.[intConcurrencyId]
--	)
--WHEN NOT MATCHED BY SOURCE AND Target.intBillId = @billId THEN DELETE;

----UPDATE A
----	SET A.dblAmountApplied = B.dblAmountApplied
----	--,A.dblBalance = (A.dblTotal - B.dblAmountApplied)
----	,A.dblBalance = B.dblBalance
----FROM tblAPAppliedPrepaidAndDebit A 
----INNER JOIN @tmpPrepaidAndDebit B 
----	ON A.intItemId = B.intItemId AND A.intTransactionId = B.intTransactionId

------UPDATE DEBIT MEMO AND OVERPAYMENT
----UPDATE A
----	SET A.dblAmountApplied = B.dblAmountApplied
----	,A.dblBalance = B.dblBalance
----FROM tblAPAppliedPrepaidAndDebit A 
----INNER JOIN @tmpPrepaidAndDebit B 
----	ON A.intTransactionId = B.intTransactionId
----INNER JOIN tblAPBill C 
----	ON B.intTransactionId = C.intBillId AND C.intTransactionType IN (3,8)

SELECT * FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId

RETURN;
