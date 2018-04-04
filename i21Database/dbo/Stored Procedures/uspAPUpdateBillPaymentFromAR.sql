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

	UPDATE tblAPBill
		SET	tblAPBill.dblPayment = (B.dblBillPayment + (CASE WHEN @post = 1 THEN ABS(B.dblPayment)ELSE B.dblPayment END)),
			tblAPBill.ysnPrepayHasPayment = 1
	FROM tblARPayment A
				INNER JOIN (
					SELECT 
						SUM(A.dblPayment * (CASE WHEN C.[intTransactionType] IN (1, 14) THEN -11 ELSE 1 END)) dblPayment
						,SUM(A.dblBasePayment * (CASE WHEN C.[intTransactionType] IN (1, 14) THEN -11 ELSE 1 END)) dblBasePayment
						,SUM(A.dblDiscount) dblDiscount
						,SUM(A.dblBaseDiscount) dblBaseDiscount
						,SUM(A.dblInterest) dblInterest
						,SUM(A.dblBaseInterest) dblBaseInterest
						,SUM(C.dblPayment) as dblBillPayment
						,A.intBillId 
						,A.intPaymentId
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.intPaymentId = B.intPaymentId						
					INNER JOIN tblAPBill C
						ON A.intBillId = C.intBillId
					WHERE
						A.intPaymentId IN (SELECT intId FROM @paymentIds)
					GROUP BY
						A.intBillId,
						A.intPaymentId
				) B 
						ON A.intPaymentId = B.intPaymentId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = (tblAPBill.dblTotal + tblAPBill.dblInterest) - (tblAPBill.dblPayment + tblAPBill.dblDiscount),
			tblAPBill.ysnPaid = (CASE WHEN ((tblAPBill.dblTotal + tblAPBill.dblInterest) - (tblAPBill.dblPayment + tblAPBill.dblDiscount)) = 0 THEN 1 ELSE 0 END),
			tblAPBill.dtmDatePaid = (CASE WHEN ((tblAPBill.dblTotal + tblAPBill.dblInterest) - (tblAPBill.dblPayment + tblAPBill.dblDiscount)) = 0 THEN A.dtmDatePaid ELSE NULL END)			
	FROM tblARPayment A
				INNER JOIN tblARPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill tblAPBill
						ON B.intBillId = tblAPBill.intBillId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE B
		SET B.dblAmountDue = -((C.dblTotal + ABS(B.dblInterest)) - (ABS(B.dblPayment) + ABS(B.dblDiscount))),
			B.dblBaseAmountDue = [dbo].fnRoundBanker((-((C.dblTotal + ABS(B.dblInterest)) - (ABS(B.dblPayment) + ABS(B.dblDiscount))) * (CASE WHEN ISNULL(B.[dblCurrencyExchangeRate], 0) =  0 THEN 1.000000 ELSE B.[dblCurrencyExchangeRate] END)), [dbo].[fnARGetDefaultDecimal]())
	FROM tblARPayment A
				INNER JOIN tblARPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN (SELECT
		[intBillId]
		,CASE WHEN [intTransactionType] = 1 THEN 'Voucher'
			  WHEN [intTransactionType] = 2 THEN 'Vendor Prepayment'
			  WHEN [intTransactionType] = 3 THEN 'Debit Memo'
			  WHEN [intTransactionType] = 7 THEN 'Invalid Type'
			  WHEN [intTransactionType] = 9 THEN '1099 Adjustment'
			  WHEN [intTransactionType] = 11 THEN 'Claim'
			  WHEN [intTransactionType] = 13 THEN 'Basis Advance'
			  WHEN [intTransactionType] = 14 THEN 'Deferred Interest'
			  ELSE 'Invalid Type' 
		 END AS [strTransactionType]
		,[dblTotal]
	FROM tblAPBill) C
						ON B.intBillId = C.intBillId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
