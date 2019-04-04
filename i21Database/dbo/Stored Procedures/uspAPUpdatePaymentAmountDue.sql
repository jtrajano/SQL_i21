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

IF @post = 0
BEGIN
	UPDATE tblAPPaymentDetail
	SET tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 
												THEN CAST((B.dblDiscount + B.dblPayment - B.dblInterest) AS DECIMAL(18,2))
											ELSE (B.dblAmountDue + B.dblPayment) END)
	FROM tblAPPayment A
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND B.ysnOffset = 0 THEN 0 ELSE 1 END --DO NOTHING IF PREPAID/BASIS IS NOT AN OFFSET
END
ELSE IF @post = 1
BEGIN
	UPDATE B
		SET B.dblAmountDue = CASE WHEN CAST((B.dblPayment + B.dblDiscount - B.dblInterest) AS DECIMAL(18,2)) = CAST(B.dblAmountDue AS DECIMAL(18,2))
									THEN 0 ELSE CAST((B.dblAmountDue) - (B.dblPayment) AS DECIMAL(18,2)) END
		--B.dblDiscount = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
		--					THEN B.dblDiscount ELSE 0 END,
		--B.dblInterest = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
		--					THEN B.dblInterest ELSE 0 END
	FROM tblAPPayment A
		LEFT JOIN tblAPPaymentDetail B
			ON A.intPaymentId = B.intPaymentId
		LEFT JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = CASE WHEN C.intTransactionType IN (2, 13) AND B.ysnOffset = 0 THEN 0 ELSE 1 END
END