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
		SET	tblAPBill.dblPayment = (C.dblPayment + (CASE WHEN @post = 1 THEN ABS(B.dblPayment)ELSE B.dblPayment END)),
			tblAPBill.ysnPrepayHasPayment = 1
	FROM tblARPayment A
				INNER JOIN tblARPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
						ON B.intBillId = C.intBillId
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
				INNER JOIN tblAPBill C
						ON B.intBillId = C.intBillId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
