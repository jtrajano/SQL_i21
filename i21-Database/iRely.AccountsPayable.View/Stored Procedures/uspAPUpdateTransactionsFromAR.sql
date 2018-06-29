CREATE PROCEDURE [dbo].[uspAPUpdateTransactionsFromAR]
	@voucherIds AS Id READONLY,
	@post BIT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF 

IF @post = 0
BEGIN
	UPDATE voucher
		SET 
		voucher.ysnPosted = 0,
		voucher.dblAmountDue = voucher.dblAmountDue + invoicePaymentDetail.dblPayment,
		voucher.dblPayment = voucher.dblPayment - invoicePaymentDetail.dblPayment,
		voucher.ysnPaid = 0,
		voucher.dblDiscount = 0,
		voucher.dblInterest = 0
	FROM tblAPBill voucher
	INNER JOIN @voucherIds voucherIds ON voucher.intBillId = voucherIds.intId
	INNER JOIN tblARPaymentDetail invoicePaymentDetail ON invoicePaymentDetail.intBillId = voucherIds.intId
END
ELSE
BEGIN
	UPDATE voucher
		SET 
		voucher.ysnPosted = 1,
		voucher.dblAmountDue = voucher.dblAmountDue - invoicePaymentDetail.dblPayment,
		voucher.dblPayment = voucher.dblPayment + invoicePaymentDetail.dblPayment,
		voucher.ysnPaid = (CASE WHEN voucher.dblAmountDue - invoicePaymentDetail.dblPayment = 0 THEN 1 ELSE 0 END),
		voucher.dblDiscount = invoicePaymentDetail.dblDiscount,
		voucher.dblInterest = invoicePaymentDetail.dblInterest
	FROM tblAPBill voucher
	INNER JOIN @voucherIds voucherIds ON voucher.intBillId = voucherIds.intId
	INNER JOIN tblARPaymentDetail invoicePaymentDetail ON invoicePaymentDetail.intBillId = voucherIds.intId
END