CREATE PROCEDURE [dbo].[uspARAddInvoiceToPayment]
	 @PaymentId				INT
	,@InvoiceId				INT
	,@Payment				NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount		BIT				= 1
	,@Discount				NUMERIC(18,6)	= 0.000000	
	,@Interest				NUMERIC(18,6)	= 0.000000
	,@AllowOverpayment		BIT				= 0
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

SET @Payment = ROUND(@Payment, [dbo].[fnARGetDefaultDecimal]())
SET @Discount = ROUND(@Discount, [dbo].[fnARGetDefaultDecimal]())
SET @Interest = ROUND(@Interest, [dbo].[fnARGetDefaultDecimal]())


IF NOT EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId)
	BEGIN
		SET @ErrorMessage = 'The payment Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId)
	BEGIN
		SET @ErrorMessage = 'The invoice Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND (([ysnPosted] = 1 AND [strTransactionType] <> 'Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Prepayment')))
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

DECLARE @InvoiceTotal	NUMERIC(18, 6)
	,@InvoiceAmountDue	NUMERIC(18, 6)
	,@TermDiscount		NUMERIC(18, 6)
	,@InvoiceNumber		NVARCHAR(50)
	,@TransactionType	NVARCHAR(25)
	,@AmountPaid		NUMERIC(18, 6)
	,@PaymentTotal		NUMERIC(18, 6)
	,@PaymentDate		DATETIME


SELECT
	 @PaymentDate	= [dtmDatePaid]
	,@AmountPaid	= [dblAmountPaid]
FROM
	tblARPayment
WHERE
	[intPaymentId] = @PaymentId


SELECT
	 @InvoiceTotal		= [dblInvoiceTotal] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,@InvoiceAmountDue	= [dblAmountDue] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment','Prepayment') THEN -1 ELSE 1 END)
	,@TermDiscount		= ROUND(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,@InvoiceNumber		= [strInvoiceNumber]
	,@TransactionType	= [strTransactionType]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId


IF (@InvoiceAmountDue + @Interest) < (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
	BEGIN
		SET @ErrorMessage = 'Payment on ' + @InvoiceNumber + ' is over the transaction''s amount due.'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

SET @PaymentTotal = ROUND(ISNULL((SELECT SUM(ISNULL(dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())


IF (@PaymentTotal + @Payment) > @AmountPaid
	BEGIN
		SET @ErrorMessage = 'Payment of ' + CONVERT(NVARCHAR(100),CAST(ISNULL(@Payment, @ZeroDecimal) AS MONEY),2)  + ' for invoice will cause an under payment.'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END


IF ISNULL(@AllowOverpayment,0) = 0 AND (@PaymentTotal + @Payment) < @AmountPaid
	BEGIN
		SET @ErrorMessage = 'Payment of ' + CONVERT(NVARCHAR(100),CAST(ISNULL(@Payment, @ZeroDecimal) AS MONEY),2)  + ' for invoice will cause an overpayment.'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

IF @TransactionType IN ('Credit Memo','Overpayment','Prepayment') AND @Payment > 0
	BEGIN
		SET @ErrorMessage = 'Positive payment amount is not allowed for invoice of type ' + @TransactionType + '.'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

IF @TransactionType IN ('Credit Memo','Overpayment','Prepayment')
	BEGIN
		SET @Discount = @ZeroDecimal 
		SET @Interest = @ZeroDecimal
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
		,[dblInvoiceTotal]			= @InvoiceTotal 
		,[dblDiscount]				= (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END)
		,[dblDiscountAvailable]		= @TermDiscount
		,[dblInterest]				= @Interest
		,[dblAmountDue]				= (@InvoiceAmountDue + @Interest) - (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
		,[dblPayment]				= @Payment
		,[intConcurrencyId]			= 0
	FROM	
		tblARInvoice ARI	
	WHERE
		ARI.[intInvoiceId] = @InvoiceId
	
	SET @NewId = SCOPE_IDENTITY()


	UPDATE tblARPayment
	SET
		[dblUnappliedAmount] = @AmountPaid - (@PaymentTotal + @Payment)
	WHERE
		[intPaymentId] = @PaymentId
	
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