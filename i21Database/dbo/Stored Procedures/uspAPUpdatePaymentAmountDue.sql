CREATE PROCEDURE [dbo].[uspAPUpdatePaymentAmountDue]
	@paymentId AS Id READONLY,
	@post BIT = NULL
AS

DECLARE @isPosted BIT = @post;

UPDATE tblAPPaymentDetail
SET tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 
											THEN (B.dblDiscount + B.dblPayment - B.dblInterest) 
										ELSE (B.dblAmountDue + B.dblPayment) END)


UPDATE B
	SET B.dblAmountDue = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
							THEN 0 ELSE (B.dblAmountDue) - (B.dblPayment) END,
	B.dblDiscount = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
						THEN B.dblDiscount ELSE 0 END,
	B.dblInterest = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
						THEN B.dblInterest ELSE 0 END
FROM tblAPPayment A
	LEFT JOIN tblAPPaymentDetail B
		ON A.intPaymentId = B.intPaymentId
WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)