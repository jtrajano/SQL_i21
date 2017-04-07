CREATE PROCEDURE [dbo].[uspAPPrepaidAndDebit]
	@billId INT
AS

IF ((SELECT ysnPosted FROM tblAPBill WHERE intBillId = @billId) = 1)
BEGIN
	RAISERROR('Voucher already posted.', 16, 1);
	RETURN;
END

DECLARE @vendorId INT = (SELECT intEntityVendorId FROM tblAPBill WHERE intBillId = @billId);

DELETE A
FROM tblAPAppliedPrepaidAndDebit A 
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
WHERE B.intBillId = @billId
AND B.ysnPosted = 0

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
	[strContractNumber],
	[intPrepayType],
	[dblTotal],
	[dblBillAmount],
	[dblBalance],
	[dblAmountApplied],
	[ysnApplied],
	[intConcurrencyId]
)
--===================================================
--PREPAYMENT FOR CONTRACT W/O ITEM (RESTRICTED)--
--===================================================   
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	CurrentBill.intLineNo,--B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	NULL,
	[strItemNo]				=	NULL,
	[intContractHeaderId]	=	CurrentBill.intContractHeaderId,	
	[strContractNumber]		=	CurrentBill.strContractNumber,
	[intPrepayType]			=	B.intPrepayTypeId,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION W/O ITEM
									WHEN 1 THEN 
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION W/O ITEM		                                 
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) --B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2))
										END
									--PERCENTAGE ALLOCATION COMPUTATION W/O ITEM                                          
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal) /*OR (B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal))*/   --VALIDATE USED PREPAID
											THEN (((B.dblTotal + B.dblTax)- dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END
									ELSE 0 END,	
	[dblAmountApplied]		=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN B.dblTotal + B.dblTax
											ELSE B.dblTotal + B.dblTax END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN B.dblTotal + B.dblTax
											ELSE B.dblTotal + B.dblTax END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
--INNER JOIN tblICItem E ON B.intItemId = E.intItemId
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,D.strContractNumber
		,D.intContractHeaderId
		,C.intContractDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	INNER JOIN tblCTContractHeader D ON C.intContractHeaderId = D.intContractHeaderId
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE C2.intContractHeaderId = C.intContractHeaderId and intBillId = @billId
	) Total
	WHERE intBillId = @billId
	AND C.intContractHeaderId = B.intContractHeaderId
) CurrentBill 
WHERE A.intTransactionType IN (2)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0										   --EXCLUDE THOSE FULLY APPLIED
AND B.intContractHeaderId IS NOT NULL AND B.intItemId IS NULL --GET ONLY THE PREPAYMENT FOR CONTRACT WITHOUT ITEM
AND B.ysnRestricted = 1
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)
UNION ALL
--================================================
--PREPAYMENT FOR CONTRACT W/ ITEM (RESTRICTED)--
--================================================
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	CurrentBill.intLineNo,--B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	E.strDescription,
	[strItemNo]				=	E.strItemNo,
	[intContractHeaderId]	=	CurrentBill.intContractHeaderId,	
	[strContractNumber]		=	CurrentBill.strContractNumber,
	[intPrepayType]			=	B.intPrepayTypeId,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]		=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION W/ ITEM		
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION W/ ITEM			 
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) --B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount)  AS DECIMAL(18,2)) 
										END
									--PERCENTAGE ALLOCATION COMPUTATION W/ ITEM 
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal) /*OR (B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal))*/   --VALIDATE USED PREPAID
											THEN (((B.dblTotal + B.dblTax)- dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END
									ELSE 0 END,
	[dblAmountApplied]			=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)  
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblICItem E ON B.intItemId = E.intItemId --FOR CONTRACT W/ ITEM
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,D.strContractNumber
		,D.intContractHeaderId
		,C.intContractDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	INNER JOIN tblCTContractHeader D ON C.intContractHeaderId = D.intContractHeaderId
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE C2.intContractHeaderId = C.intContractHeaderId AND C2.intItemId = C.intItemId and intBillId = @billId AND C2.intContractDetailId = C.intContractDetailId
	) Total
	WHERE intBillId = @billId 
	AND C.intContractHeaderId = B.intContractHeaderId AND C.intItemId = B.intItemId AND B.intContractDetailId = C.intContractDetailId--FOR CONTRACT W/ ITEM
) CurrentBill 
WHERE A.intTransactionType IN (2)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0 --EXCLUDE THOSE FULLY APPLIED
AND B.intContractHeaderId IS NOT NULL AND B.intItemId IS NOT NULL --GET ONLY THE PREPAYMENT FOR CONTRACT W/ ITEM
AND B.ysnRestricted = 1
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)
UNION ALL 
--=========================================================
--PREPAYMENT FOR CONTRACT W/O ITEM (UNRESTRICTED)--
--=========================================================
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	CurrentBill.intLineNo,--B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	NULL,
	[strItemNo]				=	NULL,
	[intContractHeaderId]	=	CurrentBill.intContractHeaderId,	
	[strContractNumber]		=	CurrentBill.strContractNumber,
	[intPrepayType]			=	B.intPrepayTypeId,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION W/O ITEM
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION W/O ITEM		                                 
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) --B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2))  
										END
									--PERCENTAGE ALLOCATION COMPUTATION W/O ITEM                                          
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal) /*OR (B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal))*/   --VALIDATE USED PREPAID
											THEN (((B.dblTotal + B.dblTax) - dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END                                       
									ELSE 0 END,
	[dblAmountApplied]			=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
--INNER JOIN tblICItem E ON B.intItemId = E.intItemId
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,D.strContractNumber
		,D.intContractHeaderId
		,C.intContractDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	LEFT JOIN tblCTContractHeader D ON C.intContractHeaderId = D.intContractHeaderId
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE /*C2.intContractHeaderId = C.intContractHeaderId and*/ intBillId = @billId
	) Total
	WHERE intBillId = @billId
	--AND C.intContractHeaderId = B.intContractHeaderId
) CurrentBill 
WHERE A.intTransactionType IN (2)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0										   --EXCLUDE THOSE FULLY APPLIED
AND B.intContractHeaderId IS NOT NULL AND B.intItemId IS NULL --GET ONLY THE PREPAYMENT FOR CONTRACT WITHOUT ITEM
AND B.ysnRestricted = 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)
UNION ALL
--=========================================================
--PREPAYMENT FOR CONTRACT W/ ITEM (UNRESTRICTED)--
--=========================================================
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	CurrentBill.intLineNo,--B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	E.strDescription,
	[strItemNo]				=	E.strItemNo,
	[intContractHeaderId]	=	CurrentBill.intContractHeaderId,	
	[strContractNumber]		=	CurrentBill.strContractNumber,
	[intPrepayType]			=	B.intPrepayTypeId,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION W/ ITEM		
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION W/ ITEM			 
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) --B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2)) END
									--PERCENTAGE ALLOCATION COMPUTATION W/ ITEM 
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal) /*OR (B.dblTotal < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal))*/   --VALIDATE USED PREPAID
											THEN (((B.dblTotal + B.dblTax)- dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END
									ELSE 0 END,
	[dblAmountApplied]		=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax)  END
									WHEN 3 THEN
                                    
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
LEFT JOIN tblICItem E ON B.intItemId = E.intItemId --FOR CONTRACT W/ ITEM
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,D.strContractNumber
		,D.intContractHeaderId
		,C.intContractDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	LEFT JOIN tblCTContractHeader D ON C.intContractHeaderId = D.intContractHeaderId
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE /*C2.intContractHeaderId = C.intContractHeaderId AND C2.intItemId = C.intItemId and*/ intBillId = @billId
	) Total
	WHERE intBillId = @billId 
	/*AND C.intContractHeaderId = B.intContractHeaderId  AND C.intItemId = B.intItemId*/ --FOR CONTRACT W/ ITEM
) CurrentBill 
WHERE A.intTransactionType IN (2)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0 --EXCLUDE THOSE FULLY APPLIED
AND B.intContractHeaderId IS NOT NULL AND B.intItemId IS NOT NULL --GET ONLY THE PREPAYMENT FOR CONTRACT W/ ITEM
AND B.ysnRestricted = 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment F INNER JOIN tblAPPaymentDetail G ON F.intPaymentId = G.intPaymentId
	INNER JOIN tblCMBankTransaction H ON F.strPaymentRecordNum = H.strTransactionId
	WHERE G.intBillId = A.intBillId AND F.ysnPosted = 1 AND H.ysnCheckVoid = 0
)
UNION ALL
--=========================================================
--DEBIT MEMO AND OVERPAYMENT
--=========================================================
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
	[strContractNumber]		=	NULL,
	[intPrepayType]			=	NULL,
	[dblTotal]				=	A.dblTotal,
	[dblBillAmount]			=	(SELECT dblTotal FROM tblAPBill WHERE intBillId = @billId),
	[dblBalance]			=	A.dblAmountDue,
	[dblAmountApplied]		=	0,
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
--LEFT JOIN tblAPAppliedPrepaidAndDebit B ON B.intTransactionId = A.intBillId
WHERE A.intTransactionType IN (3,8)
AND A.intEntityVendorId = @vendorId
AND A.dblAmountDue != 0 --EXCLUDE THOSE FULLY APPLIED
AND 1 = CASE WHEN A.intTransactionType = 3 AND A.ysnPosted = 0 THEN 0 --EXCLUDE UNPOSTED DEBIT MEMO
		ELSE 1 END
UNION ALL
--=========================================================
--PREPAYMENT WITHOUT CONTRACT
--=========================================================
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
	[strContractNumber]		=	NULL,
	[intPrepayType]			=	B.intPrepayTypeId,
	--[dblTotal]				=	A.dblTotal,
	--[dblBillAmount]			=	(SELECT dblTotal FROM tblAPBill WHERE intBillId = @billId),
	--[dblBalance]			=	A.dblAmountDue,
	--[dblAmountApplied]		=	0,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2)) END
									--PERCENTAGE ALLOCATION COMPUTATION              
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal)
											THEN (((B.dblTotal + B.dblTax) - dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END                                        
									ELSE 0 END,
	[dblAmountApplied]			=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE  intBillId = @billId
	) Total
	WHERE intBillId = @billId
) CurrentBill 
WHERE A.intTransactionType IN (2)
--AND ISNULL((SELECT TOP 1 intItemId FROM tblAPBillDetail WHERE intBillId = A.intBillId),0) <= 0
AND B.intContractHeaderId IS NULL
AND ISNULL(B.intItemId,0) <= 0
AND intEntityVendorId = @vendorId
AND A.dblAmountDue != 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment B INNER JOIN tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblCMBankTransaction D ON B.strPaymentRecordNum = D.strTransactionId
	WHERE C.intBillId = A.intBillId AND B.ysnPosted = 1 AND D.ysnCheckVoid = 0
)
UNION ALL
--=========================================================
--PREPAYMENT WITHOUT CONTRACT UNRESTRICTED DIFFERENT ITEM
--=========================================================
SELECT
	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	NULL, 
	[intLineApplied]		=	B.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	(SELECT intItemId FROM tblICItem WHERE intItemId IN (SELECT TOP 1 ISNULL(intItemId,0) FROM tblAPBillDetail WHERE intBillId = A.intBillId)),
	[strItemDescription]	=	(SELECT strDescription FROM tblICItem WHERE intItemId IN (SELECT TOP 1 ISNULL(intItemId,0) FROM tblAPBillDetail WHERE intBillId = A.intBillId)),
	[strItemNo]				=	(SELECT strItemNo FROM tblICItem WHERE intItemId IN (SELECT TOP 1 ISNULL(intItemId,0) FROM tblAPBillDetail WHERE intBillId = A.intBillId)),
	[intContractHeaderId]	=	NULL,	
	[strContractNumber]		=	NULL,
	[intPrepayType]			=	B.intPrepayTypeId,
	--[dblTotal]				=	A.dblTotal,
	--[dblBillAmount]			=	(SELECT dblTotal FROM tblAPBill WHERE intBillId = 90),
	--[dblBalance]			=	A.dblAmountDue,
	--[dblAmountApplied]		=	0,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2))  END
									--PERCENTAGE ALLOCATION COMPUTATION              
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal)
											THEN (((B.dblTotal + B.dblTax) - dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END                                        
									ELSE 0 END,
	[dblAmountApplied]			=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
CROSS APPLY
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE  intBillId = @billId
	) Total
	WHERE intBillId = @billId
) CurrentBill 
WHERE A.intTransactionType IN (2)
AND B.intContractHeaderId IS NULL
AND B.intItemId != (SELECT TOP 1 ISNULL(intItemId,0) FROM tblAPBillDetail WHERE intBillId = @billId)
AND B.ysnRestricted = 0
AND intEntityVendorId = @vendorId
AND A.dblAmountDue != 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment B INNER JOIN tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblCMBankTransaction D ON B.strPaymentRecordNum = D.strTransactionId
	WHERE C.intBillId = A.intBillId AND B.ysnPosted = 1 AND D.ysnCheckVoid = 0
)
UNION ALL
--=========================================================
--PREPAYMENT MISC //SAME ITEM
--=========================================================
SELECT

	[intBillId]				=	@billId, 
	[intBillDetailApplied]	=	CurrentBill.intBillDetailId, 
	[intLineApplied]		=	CurrentBill.intLineNo, 
	[intTransactionId]		=	A.intBillId,
	[strTransactionNumber]	=	A.strBillId,
	[intItemId]				=	B.intItemId,
	[strItemDescription]	=	C.strDescription,
	[strItemNo]				=	C.strItemNo,
	[intContractHeaderId]	=	NULL,	
	[strContractNumber]		=	NULL,
	[intPrepayType]			=	B.intPrepayTypeId,
	--[dblTotal]				=	A.dblTotal,
	--[dblBillAmount]			=	CurrentBill.dblTotal,
	--[dblBalance]			=	A.dblAmountDue,
	--[dblAmountApplied]		=	0,
	[dblTotal]				=	(B.dblTotal + B.dblTax),
	[dblBillAmount]			=	CurrentBill.dblTotal,
	[dblBalance]			=	CASE B.intPrepayTypeId 
									--STANDARD ALLOCATION COMPUTATION 
									WHEN 1 THEN
											CurrentBill.allocatedAmount * A.dblAmountDue 
									--UNIT ALLOCATION COMPUTATION                                  
									WHEN 2 THEN 
										CASE WHEN (A.dblAmountDue < A.dblTotal) 
											THEN  (A.dblAmountDue * CurrentBill.allocatedAmount)
											ELSE  CAST(((dbo.fnAPGetVoucherDetailCost(B.intBillDetailId) * dbo.fnAPGetVoucherDetailQty(B.intBillDetailId) + B.dblTax) * CurrentBill.allocatedAmount) AS DECIMAL(18,2)) END
									--PERCENTAGE ALLOCATION COMPUTATION                                  
									WHEN 3 THEN
										CASE WHEN (A.dblAmountDue < A.dblTotal)
											THEN (((B.dblTotal + B.dblTax) - dblAmountDue) * CurrentBill.allocatedAmount)
											ELSE CASE WHEN (A.dblAmountDue < CurrentBill.dblTotal) --Validate if prepayment amount if less than voucher total.
													  THEN	CASE WHEN  (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount)  > A.dblAmountDue  --validate if the percetage computation is greater than prepayment.
																 THEN A.dblAmountDue ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
															END
													  ELSE (((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal) * CurrentBill.allocatedAmount) 
												 END  
										END                                        
									ELSE 0 END,
	[dblAmountApplied]			=	(B.dblTotal + B.dblTax) - (CASE B.intPrepayTypeId 
									WHEN 1 THEN
											A.dblAmountDue 
									WHEN 2 THEN 
										CASE WHEN B.dblQtyReceived < CurrentBill.dblQtyReceived 
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									WHEN 3 THEN
										CASE WHEN (B.dblTotal + B.dblTax) < ((B.dblPrepayPercentage / 100) * CurrentBill.dblTotal)
											THEN (B.dblTotal + B.dblTax)
											ELSE (B.dblTotal + B.dblTax) END
									ELSE 0 END),
	[ysnApplied]			=	0,
	[intConcurrencyId]		=	0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
INNER JOIN 
(
	SELECT
		C.intItemId
		,C.dblTotal + C.dblTax AS dblTotal
		,C.dblCost
		,C.dblQtyReceived
		,C.intBillDetailId
		,C.intLineNo
		,Total.dblDetailTotal
		,Total.dblTotalQtyReceived
		,(C.dblTotal + C.dblTax) / Total.dblDetailTotal AS allocatedAmount
	FROM tblAPBillDetail C
	CROSS APPLY (
		SELECT SUM(dblTotal + dblTax) AS dblDetailTotal, SUM(dbo.fnAPGetVoucherDetailQty(C2.intBillDetailId)) AS dblTotalQtyReceived FROM dbo.tblAPBillDetail C2
		WHERE  intBillId = @billId
	) Total
	WHERE intBillId = @billId
	AND C.intContractDetailId IS NULL   
) CurrentBill ON B.intItemId = CurrentBill.intItemId
WHERE A.intTransactionType IN (2)
AND B.intItemId IS NOT NULL
AND B.intContractDetailId IS NULL
AND intEntityVendorId = @vendorId
AND A.dblAmountDue != 0
AND EXISTS
(
	--get prepayment record only if it has payment posted
	SELECT 1 FROM tblAPPayment B INNER JOIN tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblCMBankTransaction D ON B.strPaymentRecordNum = D.strTransactionId
	WHERE C.intBillId = A.intBillId AND B.ysnPosted = 1 AND D.ysnCheckVoid = 0
)

SELECT * FROM tblAPAppliedPrepaidAndDebit WHERE intBillId = @billId

RETURN;