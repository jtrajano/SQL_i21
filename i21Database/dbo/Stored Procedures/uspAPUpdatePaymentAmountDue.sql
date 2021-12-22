﻿/*
	This stored procedure is used to update the payment detail whenever the payment has been posted/unposted
*/
CREATE PROCEDURE [dbo].[uspAPUpdatePaymentAmountDue]
	@paymentIds AS Id READONLY,
	@post BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @isPosted BIT = @post;
DECLARE @discount DECIMAL(18,2) = 0;
DECLARE @interest DECIMAL(18,2) = 0;

IF @post = 0
BEGIN
	--IN 19.2 CONSIDER THAT THE PAYMENT DETAIL RECORD, THE DM AND PREPAID OFFSET IS NEGATIVE
	UPDATE tblAPPaymentDetail
	SET --compute discount/interest if there is any
		@discount = CASE WHEN C.intTransactionType = 1 
						THEN 
							CASE WHEN B.intPayScheduleId IS NULL
							THEN
							dbo.fnGetDiscountBasedOnTerm(A.dtmDatePaid, C.dtmBillDate, C.intTermsId, 
								(
									--GET THE AMOUNT DUE ON VOUCHER FOR ACCURACY OF VALUE
									(C.dblAmountDue * (CASE WHEN B.ysnOffset = 1 THEN -1 ELSE 1 END)) 
									+ B.dblPayment + B.dblDiscount - B.dblInterest)
								)
							ELSE B.dblDiscount
							END
					ELSE 0 END,
		@interest = CASE WHEN C.intTransactionType = 1
						THEN dbo.fnGetInterestBasedOnTerm(
									((C.dblAmountDue * (CASE WHEN B.ysnOffset = 1 THEN -1 ELSE 1 END)) + B.dblPayment + B.dblDiscount - B.dblInterest)
									,C.dtmBillDate, A.dtmDatePaid, NULL, C.intTermsId)
					ELSE 0 END,
		tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 
												THEN CAST((B.dblDiscount + B.dblPayment - B.dblInterest) AS DECIMAL(18,2))
											ELSE (B.dblAmountDue + B.dblPayment - B.dblInterest) END)
		--WE CANNOT DETERMINE IF DISCOUNT WILL BE REVERTED IF IT IS OVERRIDE AND PARTIAL
		--WE WILL RETAIN THE VALUE OF tblAPPaymentDetail.dblDiscount TO AVOID CONFUSION ON WHAT IT SHOULD BE THE VALUE AFTER UNPOSTING
		--We originally need this logic to recalculate the interest or discount on unpost to correctly show the computation base on terms.
		--tblAPPaymentDetail.dblDiscount = CASE WHEN C.ysnDiscountOverride = 1 THEN C.dblDiscount ELSE @discount END,
		--SAME WITH INTEREST
		--tblAPPaymentDetail.dblInterest = @interest
	FROM tblAPPayment A
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND B.ysnOffset = 0 THEN 0 ELSE 1 END --DO NOTHING IF PREPAID/BASIS IS NOT AN OFFSET
	AND B.dblPayment != 0
END
ELSE IF @post = 1
BEGIN
	UPDATE B
		SET 
			B.dblAmountDue = CASE WHEN CAST((B.dblPayment + B.dblDiscount - B.dblInterest) AS DECIMAL(18,2)) = CAST(B.dblAmountDue AS DECIMAL(18,2))
								THEN 0 ELSE 
											CAST((B.dblAmountDue) - (B.dblPayment)  
													+  (B.dblInterest) --Interest should be part of the amount due computation if not fully paid.
													AS DECIMAL(18,2)) END
			--Do not update the discount/interest, we are using these fields to update the bill
			--We are not honoring the discount if not fully paid and not override discount
			-- B.dblDiscount = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
			-- 					THEN B.dblDiscount ELSE 0 END,
			-- B.dblInterest = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
			-- 					THEN B.dblInterest ELSE 0 END
	FROM tblAPPayment A
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND B.ysnOffset = 0 THEN 0 ELSE 1 END
	AND B.dblPayment != 0
END