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
	RAISERROR(120010, 16, 1);
	GOTO _ExitTransaction
END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId)
BEGIN		
	RAISERROR(120011, 16, 1);
	GOTO _ExitTransaction
END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND (([ysnPosted] = 1 AND [strTransactionType] <> 'Customer Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Prepayment')))
BEGIN
	RAISERROR(120012, 16, 1);
	GOTO _ExitTransaction
END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash')
BEGIN	
	RAISERROR(120013, 16, 1);
	GOTO _ExitTransaction
END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
BEGIN
	RAISERROR(120014, 16, 1);
	GOTO _ExitTransaction
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
	 @InvoiceTotal		= [dblInvoiceTotal] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment','Customer Prepayment') THEN -1 ELSE 1 END)
	,@InvoiceAmountDue	= [dblAmountDue] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment','Customer Prepayment') THEN -1 ELSE 1 END)
	,@TermDiscount		= ROUND(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,@InvoiceNumber		= [strInvoiceNumber]
	,@TransactionType	= [strTransactionType]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId


IF (@InvoiceAmountDue + @Interest) < (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
BEGIN
	RAISERROR(120058, 16, 1, @InvoiceNumber);
	GOTO _ExitTransaction
END
	
SET @PaymentTotal = ROUND(ISNULL((SELECT SUM(ISNULL(dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())


IF (@PaymentTotal + @Payment) > @AmountPaid
BEGIN	
	RAISERROR(120059, 16, 1, @Payment);
	GOTO _ExitTransaction
END


IF ISNULL(@AllowOverpayment,0) = 0 AND (@PaymentTotal + @Payment) < @AmountPaid
BEGIN	
	RAISERROR(120060, 16, 1, @Payment);
	GOTO _ExitTransaction
END

IF @TransactionType IN ('Credit Memo','Overpayment','Customer Prepayment') AND @Payment > 0
BEGIN			
	RAISERROR(120061, 16, 1, @TransactionType);
	GOTO _ExitTransaction
END

IF @TransactionType IN ('Credit Memo','Overpayment','Customer Prepayment')
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
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
END CATCH


SET @NewPaymentDetailId = @NewId

IF @@ERROR = 0 GOTO _CommitTransaction

_RollBackTransaction:
ROLLBACK TRANSACTION
GOTO _ExitTransaction

_CommitTransaction: 
COMMIT TRANSACTION
GOTO _ExitTransaction

_ExitTransaction: 
	
END