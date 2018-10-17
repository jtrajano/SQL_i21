/*
	This stored procedure is used to update the bill whenever the payment has been posted/unposted
*/
CREATE PROCEDURE [dbo].[uspAPUpdateBillPaymentFromAR]
	@paymentIds AS Id READONLY,
	@post BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- UPDATE C
-- SET	C.dblPayment = (CASE WHEN @post = 1 THEN C.dblPayment + ABS(B.dblPayment) ELSE C.dblPayment - ABS(B.dblPayment) END),
-- 	C.ysnPrepayHasPayment = 1
-- FROM
-- 	tblARPayment A
-- INNER JOIN
-- 	tblARPaymentDetail B 
-- 		ON A.intPaymentId = B.intPaymentId
-- INNER JOIN
-- 	tblAPBill C
-- 		ON B.intBillId = C.intBillId
-- WHERE
-- 	B.dblPayment <> 0 
-- 	AND A.intPaymentId IN (SELECT intId FROM @paymentIds)

UPDATE C
SET 
	C.dblAmountDue = CASE WHEN @post = 1 
						THEN C.dblAmountDue - (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount))--(C.dblTotal + C.dblInterest) - (C.dblPayment + C.dblDiscount),
						ELSE C.dblAmountDue + (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount))
					END,
	C.ysnPaid = CASE WHEN @post = 1 AND C.dblAmountDue - (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount)) = 0 THEN 1 ELSE 0 END,
	C.dblPayment = CASE WHEN @post = 1
						THEN C.dblPayment + (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount))
						ELSE C.dblPayment - (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount))
					END,
	C.dtmDatePaid = CASE WHEN @post = 1 AND C.dblAmountDue - (ABS(B.dblPayment) + ABS(B.dblInterest) - ABS(B.dblDiscount)) = 0 
					THEN A.dtmDatePaid
					ELSE NULL 
					END
FROM
	tblARPayment A
INNER JOIN
	tblARPaymentDetail B 
	ON A.intPaymentId = B.intPaymentId
INNER JOIN
	tblAPBill C
		ON B.intBillId = C.intBillId
OUTER APPLY (
	SELECT TOP 1
		dblFranchiseAmount
	FROM tblAPBillDetail voucherDetail
	WHERE voucherDetail.intBillId = C.intBillId
) claimDetail
WHERE
	B.dblPayment <> 0 
	AND A.intPaymentId IN (SELECT intId FROM @paymentIds)

--UPDATE PREPAID FOR CLAIM TRANSACTION
UPDATE D
	SET D.dblPayment = CAST(
						CASE WHEN @post = 1
							THEN D.dblPayment + ABS(B.dblPayment)
							ELSE D.dblPayment - ABS(B.dblPayment)
						END
						--weight claim
						+ (
							CASE WHEN C.intTransactionType = 11 
								THEN (
										CASE WHEN @post = 1 AND C.dblAmountDue = 0 --add the franchise amount on prepaid if claim amount due is 0
											THEN ISNULL(claimPrepaid.dblFranchiseAmount,0) 
											ELSE ISNULL(-claimPrepaid.dblFranchiseAmount,0) 
										END
									)
								ELSE 0
							END
						) AS DECIMAL(18,2))
	,D.dblAmountDue = CAST(
						CASE WHEN @post = 1
							THEN D.dblAmountDue - ABS(B.dblPayment) 
							ELSE D.dblAmountDue + ABS(B.dblPayment) 
						END
						--weight claim
						- (
							CASE WHEN C.intTransactionType = 11 
								THEN (
										CASE WHEN @post = 1 AND C.dblAmountDue = 0
											THEN ISNULL(claimPrepaid.dblFranchiseAmount,0) 
										ELSE ISNULL(-claimPrepaid.dblFranchiseAmount,0) 
										END
									)
								ELSE 0
							END
						) AS DECIMAL(18,2))
	,D.ysnPaid = CASE WHEN 
				(
					CAST(
						CASE WHEN @post = 1
							THEN D.dblAmountDue - ABS(B.dblPayment) 
							ELSE D.dblAmountDue + ABS(B.dblPayment) 
						END
						--weight claim
						- (
							CASE WHEN C.intTransactionType = 11 
								THEN (
										CASE WHEN @post = 1 AND C.dblAmountDue = 0
											THEN ISNULL(claimPrepaid.dblFranchiseAmount,0) 
										ELSE ISNULL(-claimPrepaid.dblFranchiseAmount,0) 
										END
									)
								ELSE 0
							END
						) AS DECIMAL(18,2))	
				) = 0
				THEN 1 ELSE 0 END
FROM
	tblARPayment A
INNER JOIN
	tblARPaymentDetail B 
	ON A.intPaymentId = B.intPaymentId
INNER JOIN
	tblAPBill C
		ON B.intBillId = C.intBillId
CROSS APPLY (
	SELECT TOP 1
		C2.intPrepayTransactionId,
		C2.dblFranchiseAmount
	FROM tblAPBillDetail C2
	WHERE C2.intBillId = C.intBillId
) claimPrepaid
INNER JOIN tblAPBill D
	ON claimPrepaid.intPrepayTransactionId = D.intBillId
WHERE
	B.dblPayment <> 0 
	AND A.intPaymentId IN (SELECT intId FROM @paymentIds)
--UPDATE B
--SET
--	B.dblAmountDue = -((C.dblTotal + ABS(B.dblInterest)) - (ABS(B.dblPayment) + ABS(B.dblDiscount))),
--	B.dblBaseAmountDue = [dbo].fnRoundBanker((-((C.dblTotal + ABS(B.dblInterest)) - (ABS(B.dblPayment) + ABS(B.dblDiscount))) * (CASE WHEN ISNULL(B.[dblCurrencyExchangeRate], 0) =  0 THEN 1.000000 ELSE B.[dblCurrencyExchangeRate] END)), [dbo].[fnARGetDefaultDecimal]())
--FROM
--	tblARPayment A
--INNER JOIN
--	tblARPaymentDetail B 
--		ON A.intPaymentId = B.intPaymentId
--INNER JOIN
--	tblAPBill C
--		ON B.intBillId = C.intBillId
--WHERE
--	A.intPaymentId IN (SELECT intId FROM @paymentIds)
