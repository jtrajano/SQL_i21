CREATE PROCEDURE [dbo].[uspAPUpdatePaymentAmountDue]
	@paymentId AS Id READONLY,
	@post BIT = NULL
AS

DECLARE @isPosted BIT = @post;

UPDATE tblAPPaymentDetail
		SET tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 
													THEN (B.dblDiscount + B.dblPayment - B.dblInterest) 
												ELSE (B.dblAmountDue + B.dblPayment) END)
