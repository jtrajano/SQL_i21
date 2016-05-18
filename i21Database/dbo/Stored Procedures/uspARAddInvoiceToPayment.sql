CREATE PROCEDURE [dbo].[uspARAddInvoiceToPayment]
	 @PaymentId				INT
	,@InvoiceId				INT
	,@Payment				NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount		BIT				= 1
	,@Discount				NUMERIC(18,6)	= 0.000000	
	,@Interest				NUMERIC(18,6)	= 0.000000
	,@RaiseError			BIT				= 0
	,@ErrorMessage			NVARCHAR(250)	= NULL			OUTPUT
	,@NewPaymentDetailId	INT				= NULL			OUTPUT 	
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME

		

SET @ZeroDecimal = 0.000000	
SELECT @DateOnly = CAST(GETDATE() AS DATE)

	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId)
	BEGIN
		SET @ErrorMessage = 'The invoice Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1)
	BEGIN
		SET @ErrorMessage = 'The invoice provided is not yet posted!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash')
	BEGIN
		SET @ErrorMessage = 'Invoice of type Cash cannot be added!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
	BEGIN
		SET @ErrorMessage = 'Invoice of type Cash Refund cannot be added!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END	


	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @NewId INT
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId]
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblDiscountAvailable]
		,[dblInterest]
		,[dblAmountDue]
		,[dblPayment]
		,[intConcurrencyId])
	SELECT
		 [intPaymentId]				= @PaymentId
		,[intInvoiceId]				= ARI.[intInvoiceId] 
		,[intTermId]				= ARI.[intTermId] 
		,[intAccountId]				= ARI.[intAccountId] 
		,[dblInvoiceTotal]			= ARI.[dblInvoiceTotal] 
		,[dblDiscount]				= @Discount
		,[dblDiscountAvailable]		= @Discount
		,[dblInterest]				= @Interest
		,[dblAmountDue]				= ARI.[dblAmountDue] 
		,[dblPayment]				= @Payment
		,[intConcurrencyId]			= 0
	FROM	
		tblARInvoice ARI	
	WHERE
		ARI.[intInvoiceId] = @InvoiceId
	
	SET @NewId = SCOPE_IDENTITY()
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


SET @NewPaymentDetailId = @NewId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END