﻿/*
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

DECLARE @amountDue DECIMAL(18,2);

IF @post = 0
BEGIN
	UPDATE A
		SET A.ysnPaid = 0
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET tblAPBill.dblAmountDue = C.dblAmountDue + 
									(
										ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment)
									+ 	ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount)
									), 
			tblAPBill.ysnPaid = 0,
			tblAPBill.dblPayment = C.dblPayment - 
									(
										ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment)
									+ 	ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount)
									),
			tblAPBill.dtmDatePaid = NULL,
			tblAPBill.dblDiscount = ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount),
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
		WHERE 
			B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
		AND B.intBillId = C.intBillId
		GROUP BY B.intBillId
	) payDetails
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblAmountDue) dblAmountDue,
			SUM(B.dblDiscount) dblDiscount,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE 
			B.intPaymentId = A.intPaymentId AND B.intPayScheduleId > 0
		AND B.intBillId = C.intBillId
		GROUP BY B.intBillId
	) paySchedDetails
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND A2.ysnOffset = 0 THEN 0 ELSE 1 END
END
ELSE IF @post = 1
BEGIN

	UPDATE A
		SET A.ysnPaid = 1
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET 
			@amountDue = C.dblAmountDue - (ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment) + ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount)),
			tblAPBill.dblAmountDue = @amountDue,
			tblAPBill.ysnPaid = (CASE WHEN @amountDue = 0 THEN 1 ELSE 0 END),
			tblAPBill.dtmDatePaid = (CASE WHEN @amountDue = 0 THEN A.dtmDatePaid ELSE NULL END),
			tblAPBill.dblWithheld = ISNULL(payDetails.dblWithheld,0),
			tblAPBill.dblDiscount = (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount) 
										ELSE 
											ISNULL
											(
												paySchedDetails.dblDiscount,
												CASE WHEN C.intTransactionType = 1 
													THEN dbo.fnGetDiscountBasedOnTerm(A.dtmDatePaid, C.dtmDate, C.intTermsId, @amountDue) 
												ELSE 0 END
											)
										END),
			tblAPBill.dblInterest = (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(payDetails.dblInterest,0) 
									ELSE 
										CASE WHEN C.intTransactionType = 1 
											THEN dbo.fnGetInterestBasedOnTerm(@amountDue, C.dtmDate, A.dtmDatePaid, C.intTermsId) 
										ELSE 0 END
									END),
			tblAPBill.dblPayment = (C.dblPayment + ISNULL(paySchedDetails.dblPayment, payDetails.dblPayment)) --Include the first payment (if there is) + the current amount paid
									+ ISNULL(paySchedDetails.dblDiscount, payDetails.dblDiscount) 
									- ISNULL(payDetails.dblInterest,0) 
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
		WHERE 
			B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
		AND B.intBillId = C.intBillId
		GROUP BY B.intBillId
	) payDetails
	OUTER APPLY (
		SELECT 
			SUM(B.dblPayment) dblPayment,
			SUM(B.dblAmountDue) dblAmountDue,
			SUM(B.dblDiscount) dblDiscount,
			B.intBillId 
		FROM tblAPPaymentDetail B 
		WHERE 
			B.intPaymentId = A.intPaymentId AND B.intPayScheduleId > 0
		AND B.intBillId = C.intBillId
		GROUP BY B.intBillId
	) paySchedDetails
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND A2.ysnOffset = 0 THEN 0 ELSE 1 END

END