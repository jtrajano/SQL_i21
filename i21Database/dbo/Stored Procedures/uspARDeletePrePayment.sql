CREATE PROCEDURE [dbo].[uspARDeletePrePayment]
	 @PaymentId		as int
	,@BatchId		as nvarchar(20)	= NULL
	,@UserId		as int			= 1
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


WHILE EXISTS(
			SELECT TOP 1 I.intInvoiceId 
			FROM tblARInvoice I
			INNER JOIN tblARPayment P
					ON I.intPaymentId = P.intPaymentId
			WHERE I.strTransactionType = 'Customer Prepayment'
			  AND P.intPaymentId = @PaymentId
			)
	BEGIN
		DECLARE @invoiceId int

		SELECT TOP 1 @invoiceId = I.intInvoiceId 
		FROM tblARInvoice I
		INNER JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId
		WHERE I.strTransactionType = 'Customer Prepayment'
		  AND P.intPaymentId = @PaymentId

		DELETE FROM tblARPrepaidAndCredit
		WHERE intPrepaymentId = @invoiceId
		AND ysnApplied = 0

		DELETE FROM tblARPaymentDetail
		WHERE intInvoiceId = @invoiceId

		DELETE FROM tblARInvoiceDetail 
		WHERE intInvoiceId = @invoiceId

		UPDATE tblARInvoice 
		SET ysnPosted = 0
		WHERE intInvoiceId = @invoiceId

		DELETE FROM tblARInvoice 
		WHERE intInvoiceId = @invoiceId

		UPDATE tblARPayment 
		SET ysnInvoicePrepayment = 0 
		WHERE intPaymentId = @PaymentId
	END

RETURN 1

END