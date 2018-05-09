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

UPDATE C
SET	C.dblPayment = (CASE WHEN @post = 1 THEN C.dblPayment + ABS(B.dblPayment) ELSE C.dblPayment - ABS(B.dblPayment) END),
	C.ysnPrepayHasPayment = 1
FROM
	tblARPayment A
INNER JOIN
	tblARPaymentDetail B 
		ON A.intPaymentId = B.intPaymentId
INNER JOIN
	tblAPBill C
		ON B.intBillId = C.intBillId
WHERE
	B.dblPayment <> 0 
	AND A.intPaymentId IN (SELECT intId FROM @paymentIds)

UPDATE C
SET 
	C.dblAmountDue = (C.dblTotal + C.dblInterest) - (C.dblPayment + C.dblDiscount),
	C.ysnPaid = (CASE WHEN ((C.dblTotal + C.dblInterest) - (C.dblPayment + C.dblDiscount)) = 0 THEN 1 ELSE 0 END),
	C.dtmDatePaid = (CASE WHEN ((C.dblTotal + C.dblInterest) - (C.dblPayment + C.dblDiscount)) = 0 THEN A.dtmDatePaid ELSE NULL END)			
FROM
	tblARPayment A
INNER JOIN
	tblARPaymentDetail B 
	ON A.intPaymentId = B.intPaymentId
INNER JOIN
	tblAPBill C
		ON B.intBillId = C.intBillId
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
