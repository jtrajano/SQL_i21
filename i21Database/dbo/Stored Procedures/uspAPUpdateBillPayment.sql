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

DECLARE @amountDue DECIMAL(18,2);
DECLARE @discountAmt DECIMAL(18,6);

IF @post = 0
BEGIN
	UPDATE A
		SET A.ysnPaid = 0
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds)

	UPDATE tblAPBill
		SET 
			@amountDue 	= C.dblAmountDue + 
									(
										ISNULL(paySchedDetails.dblPayment, ABS(payDetails.dblPayment))
									+ 	ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
									- 	ABS(ISNULL(payDetails.dblInterest, 0))
									),
			@discountAmt = C.dblDiscount - ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount)),
			tblAPBill.dblAmountDue = @amountDue, 
			tblAPBill.ysnPaid = 0,
			tblAPBill.dblPayment = C.dblPayment - 
									(
										ISNULL(paySchedDetails.dblPayment, ABS(payDetails.dblPayment))
									+ 	ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
									- 	ABS(ISNULL(payDetails.dblInterest, 0))
									),
			tblAPBill.dtmDatePaid = NULL,
			tblAPBill.dblDiscount = CASE 
										WHEN @discountAmt = 0 --if discount will be back to 0
										THEN A2.dblDiscount --return the value of discount, this will be display on 'Terms Discount'
									ELSE @discountAmt END,
			tblAPBill.dblInterest = C.dblInterest - ABS(ISNULL(payDetails.dblInterest,0)),
			tblAPBill.dtmInterestDate = ISNULL(latestPay.dtmDatePaid, NULL),
			tblAPBill.dblWithheld = 0
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail A2 
		ON A.intPaymentId = A2.intPaymentId
	INNER JOIN tblAPBill C
		ON A2.intBillId = C.intBillId
	OUTER APPLY
	(
		SELECT
		TOP 1
			pay.dtmDatePaid
		FROM tblAPPaymentDetail payDetail
		INNER JOIN tblAPPayment pay
			ON pay.intPaymentId = payDetail.intPaymentId
		WHERE 
			pay.intPaymentId != A.intPaymentId
		AND payDetail.intBillId = C.intBillId
		AND pay.ysnPosted = 1
		ORDER BY pay.dtmDatePaid DESC	
	) latestPay
	OUTER APPLY 
	(
		SELECT
			SUM(dblPayment) AS dblPayment,
			SUM(dblDiscount) AS dblDiscount,
			SUM(dblInterest) AS dblInterest,
			MIN(dblAmountDue) AS dblAmountDue
		FROM (
			SELECT 
				B.dblPayment,
				CASE WHEN B.dblPayment + B.dblDiscount = B.dblAmountDue THEN B.dblDiscount 
				WHEN C.ysnDiscountOverride = 1 THEN B.dblDiscount ELSE 0 END
				AS dblDiscount,
				CASE WHEN B.dblPayment - B.dblInterest = B.dblAmountDue THEN B.dblInterest 
				ELSE 0 END
				AS dblInterest,
				B.dblAmountDue dblAmountDue,
				B.intBillId 
			FROM tblAPPaymentDetail B 
			WHERE 
				B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
			AND B.intBillId = C.intBillId
		) tmpPayDetails
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
	AND A2.dblPayment != 0
END
ELSE IF @post = 1
BEGIN

	UPDATE A
		SET A.ysnPaid = 1
	FROM tblAPVoucherPaymentSchedule A
	INNER JOIN tblAPPaymentDetail C ON A.intId = C.intPayScheduleId
	WHERE C.intPaymentId IN (SELECT intId FROM @paymentIds) AND C.dblPayment <> 0

	UPDATE tblAPBill
		SET 
			@amountDue = C.dblAmountDue 
						- (
							ISNULL(paySchedDetails.dblPayment, ABS(payDetails.dblPayment))
						+ 	ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
						- 	ABS(ISNULL(payDetails.dblInterest, 0))
						),
			tblAPBill.dblAmountDue = @amountDue,
			tblAPBill.ysnPaid = (CASE WHEN @amountDue = 0 THEN 1 ELSE 0 END),
			tblAPBill.dtmDatePaid = (CASE WHEN @amountDue = 0 THEN A.dtmDatePaid ELSE NULL END),
			tblAPBill.dblWithheld = ABS(ISNULL(payDetails.dblWithheld,0)),
			tblAPBill.dblDiscount = (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
										ELSE 
											ISNULL
											(
												paySchedDetails.dblDiscount,
												CASE WHEN C.intTransactionType = 1 
													THEN 
														(CASE WHEN C.ysnDiscountOverride = 0 AND @amountDue = 0
															THEN dbo.fnGetDiscountBasedOnTerm(A.dtmDatePaid, C.dtmBillDate, C.intTermsId, @amountDue) 
															ELSE ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
														END)
												ELSE 0 END
											)
										END),
			tblAPBill.dblInterest = ABS(ISNULL(payDetails.dblInterest,0)), --WHEN POSTING PAYMENT, THE INTEREST SHOULD ALWAYS BE PART OF THE PAYMENT, PARTIAL OR FULL
									-- (CASE WHEN A2.dblAmountDue = 0 THEN ISNULL(payDetails.dblInterest,0) 
									-- ELSE 
									-- 	CASE WHEN C.intTransactionType = 1 
									-- 		THEN dbo.fnGetInterestBasedOnTerm(@amountDue, C.dtmDate, A.dtmDatePaid, C.intTermsId) 
									-- 	ELSE 0 END
									-- END),
			tblAPBill.dtmInterestDate = CASE WHEN ABS(ISNULL(payDetails.dblInterest,0)) > 0 THEN A.dtmDatePaid ELSE NULL END,
			tblAPBill.dblPayment = (C.dblPayment + ISNULL(paySchedDetails.dblPayment, ABS(payDetails.dblPayment))) --Include the first payment (if there is) + the current amount paid
									+ ISNULL(paySchedDetails.dblDiscount, ABS(payDetails.dblDiscount))
									- ABS(ISNULL(payDetails.dblInterest,0))
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail A2 ON A.intPaymentId = A2.intPaymentId
	INNER JOIN tblAPBill C
		ON A2.intBillId = C.intBillId
	OUTER APPLY (
		--SELECT 
		--	SUM(B.dblPayment) dblPayment,
		--	SUM(B.dblDiscount) dblDiscount,
		--	SUM(B.dblInterest) dblInterest,
		--	SUM(B.dblWithheld) dblWithheld,
		--	MIN(B.dblAmountDue) dblAmountDue,
		--	B.intBillId 
		--FROM tblAPPaymentDetail B 
		--WHERE 
		--	B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
		--AND B.intBillId = C.intBillId
		--AND B.dblPayment != 0
		--GROUP BY B.intBillId
		SELECT
			intBillId,
			SUM(dblPayment) AS dblPayment,
			SUM(dblDiscount) AS dblDiscount,
			SUM(dblInterest) AS dblInterest,
			SUM(dblWithheld) AS dblWithheld,
			MIN(dblAmountDue) AS dblAmountDue
		FROM (
			SELECT 
				B.dblPayment,
				--if voucher amount due the same as the payment detail payment, use discount
				CASE WHEN B.dblPayment + B.dblDiscount - B.dblInterest = C.dblAmountDue THEN B.dblDiscount 
				WHEN C.ysnDiscountOverride = 1 THEN B.dblDiscount ELSE 0 END
				AS dblDiscount,
				CASE WHEN B.dblPayment + B.dblDiscount - B.dblInterest = C.dblAmountDue THEN B.dblInterest 
				ELSE 0 END
				AS dblInterest,
				B.dblAmountDue,
				B.dblWithheld,
				B.intBillId 
			FROM tblAPPaymentDetail B 
			WHERE 
				B.intPaymentId = A.intPaymentId AND B.intPayScheduleId IS NULL
			AND B.intBillId = C.intBillId
			AND B.dblPayment != 0
		) tmpPayDetails
		GROUP BY intBillId
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
		AND B.dblPayment != 0
		GROUP BY B.intBillId
	) paySchedDetails
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND A2.ysnOffset = 0 THEN 0 ELSE 1 END
	AND A2.dblPayment != 0

END