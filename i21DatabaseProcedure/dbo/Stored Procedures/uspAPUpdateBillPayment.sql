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
	UPDATE A
		SET A.ysnPaid = 0
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = C.dblAmountDue + ISNULL(paySchedDetails.dblAmountDue, payDetails.dblAmountDue), --(CASE WHEN C.intTransactionType !=1 THEN B.dblAmountDue * -1 ELSE B.dblAmountDue END),
			tblAPBill.ysnPaid = 0,
			tblAPBill.dblPayment = (C.dblPayment - ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment)),
			tblAPBill.dtmDatePaid = NULL,
			tblAPBill.dblDiscount = C.dblDiscount - ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount),
			tblAPBill.dblWithheld = 0
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail A2 
		ON A.intPaymentId = A2.intPaymentId
	INNER JOIN tblAPBill C
		ON A2.intBillId = C.intBillId
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblDiscount) dblDiscount,
			MIN(B.dblAmountDue) dblAmountDue,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
		GROUP BY B.intBillId
	) payDetails
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblAmountDue) dblAmountDue,
			SUM(B.dblDiscount) dblDiscount,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE B.intPaymentId = A.intPaymentId AND B.intPayScheduleId > 0
		GROUP BY B.intBillId
	) paySchedDetails
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
END
ELSE IF @post = 1
BEGIN

	UPDATE A
		SET A.ysnPaid = 1
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = C.dblAmountDue - (ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment) + ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount)),
			tblAPBill.ysnPaid = (CASE WHEN (C.dblAmountDue - 
											(ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment) + ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount))
											) = 0 THEN 1 ELSE 0 END),
			tblAPBill.dtmDatePaid = (CASE WHEN (C.dblAmountDue - ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment)) = 0 THEN A.dtmDatePaid ELSE NULL END),
			tblAPBill.dblWithheld = ISNULL(payDetails.dblWithheld,0),
			tblAPBill.dblDiscount = (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount) ELSE 0 END),
			tblAPBill.dblInterest = (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(payDetails.dblInterest,0) ELSE 0 END),
			tblAPBill.dblPayment = (C.dblPayment + ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment))
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
	INNER JOIN tblAPBill C
		ON A2.intBillId = C.intBillId
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblDiscount) dblDiscount,
			SUM(B.dblInterest) dblInterest,
			SUM(B.dblWithheld) dblWithheld,
			MIN(B.dblAmountDue) dblAmountDue,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
		GROUP BY B.intBillId
	) payDetails
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblAmountDue) dblAmountDue,
			SUM(B.dblDiscount) dblDiscount,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE B.intPaymentId = A.intPaymentId AND B.intPayScheduleId > 0
		GROUP BY B.intBillId
	) paySchedDetails
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)

END