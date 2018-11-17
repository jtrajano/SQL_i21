/*
	This stored procedure is used to update the bill whenever the payment has been posted/unposted
*/
CREATE PROCEDURE [dbo].[uspAPUpdateBillPayment]
	@paymentIds AS Id READONLY,
	@post BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @post = 0
BEGIN
	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = B.dblAmountDue, --(CASE WHEN C.intTransactionType !=1 THEN B.dblAmountDue * -1 ELSE B.dblAmountDue END),
			tblAPBill.ysnPaid = 0,
			tblAPBill.dblPayment = (C.dblPayment - B.dblPayment),
			tblAPBill.dtmDatePaid = NULL,
			tblAPBill.dblWithheld = 0
	FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
						ON B.intBillId = C.intBillId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
END
ELSE IF @post = 1
BEGIN
	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = B.dblAmountDue,
			tblAPBill.ysnPaid = (CASE WHEN (B.dblAmountDue) = 0 THEN 1 ELSE 0 END),
			tblAPBill.dtmDatePaid = (CASE WHEN (B.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE NULL END),
			tblAPBill.dblWithheld = B.dblWithheld,
			tblAPBill.dblDiscount = (CASE WHEN B.dblAmountDue = 0 THEN B.dblDiscount ELSE 0 END),
			tblAPBill.dblInterest = (CASE WHEN B.dblAmountDue = 0 THEN B.dblInterest ELSE 0 END),
			tblAPBill.dblPayment = (C.dblPayment + B.dblPayment)
	FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
						ON B.intBillId = C.intBillId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)

END