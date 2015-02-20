CREATE PROCEDURE [dbo].[uspARDeleteOverPayment]
	 @PaymentId		as int
	,@UnPost		as bit			= 1
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
			SELECT TOP 1
				I.intInvoiceId 
			FROM
				tblARInvoice I
			INNER JOIN
				tblARPayment P
					ON I.strComments = P.strRecordNumber				
			WHERE
				I.strTransactionType = 'Overpayment'
				AND P.intPaymentId = @PaymentId
			)
	BEGIN

		DECLARE @invoiceId int

		SELECT TOP 1
			@invoiceId = I.intInvoiceId 
		FROM
			tblARInvoice I
		INNER JOIN
			tblARPayment P
				ON I.strComments = P.strRecordNumber				
		WHERE
			I.strTransactionType = 'Overpayment'
			AND P.intPaymentId = @PaymentId

		IF @UnPost = 1
			BEGIN
				DECLARE	@successfulCount int,
						@invalidCount int,
						@success bit

				EXEC	[dbo].[uspARPostInvoice]
						@batchId = @BatchId,
						@post = 0,
						@recap = 0,
						@param = @invoiceId,
						@userId = @UserId,
						@beginDate = NULL,
						@endDate = NULL,
						@beginTransaction = NULL,
						@endTransaction = NULL,
						@exclude = NULL,
						@successfulCount = @successfulCount OUTPUT,
						@invalidCount = @invalidCount OUTPUT,
						@success = @success OUTPUT,
						@batchIdUsed = NULL,
						@recapId = NULL,
						@transType = N'Overpayment'
			END 

		DELETE FROM tblARInvoiceDetail 
		WHERE intInvoiceId = @invoiceId

		DELETE FROM tblARInvoice 
		WHERE intInvoiceId = @invoiceId

	END
		                     
RETURN 1

END