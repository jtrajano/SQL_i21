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
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120010, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120011, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND (([ysnPosted] = 1 AND [strTransactionType] <> 'Customer Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Customer Prepayment')))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120012, 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash')
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120013, 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120014, 16, 1);
		RETURN 0;
	END

DECLARE @InvoiceTotal		NUMERIC(18, 6)
	,@InvoiceAmountDue		NUMERIC(18, 6)
	,@TermDiscount			NUMERIC(18, 6)
	,@InvoiceNumber			NVARCHAR(50)
	,@TransactionType		NVARCHAR(25)
	,@AmountPaid			NUMERIC(18, 6)
	,@PaymentTotal			NUMERIC(18, 6)
	,@PaymentDate			DATETIME
	,@InvoiceReportNumber	NVARCHAR(MAX)
 
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

SELECT 	
	@InvoiceReportNumber	= [strInvoiceReportNumber]
FROM 
	tblCFTransaction
WHERE 
	intInvoiceId = @InvoiceId

IF (@InvoiceAmountDue + @Interest) < (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120058, 16, 1, @InvoiceNumber);
		RETURN 0;
	END

SET @PaymentTotal = ROUND(ISNULL((SELECT SUM(ISNULL(dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())

DECLARE @ErrorMsg NVARCHAR(100)
SET @ErrorMsg = CONVERT(NVARCHAR(100),CAST(ISNULL(@Payment,@ZeroDecimal) AS MONEY),2) 

IF (@PaymentTotal + @Payment) > (@AmountPaid + @Payment) AND @TransactionType <> 'Customer Prepayment'
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120059, 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF ISNULL(@AllowOverpayment,0) = 0 AND (@PaymentTotal + @Payment) > (@AmountPaid + @Payment)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120060, 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF @TransactionType IN ('Credit Memo','Overpayment','Customer Prepayment') AND @Payment > 0
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120061, 16, 1, @TransactionType);
		RETURN 0;
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
		,[intBillId]
		,[strTransactionNumber] 
		,[intTermId]
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblDiscountAvailable]
		,[dblInterest]
		,[dblAmountDue]
		,[dblPayment]		
		,[strInvoiceReportNumber]
		,[intConcurrencyId]

		)
	SELECT
		 [intPaymentId]				= @PaymentId
		,[intInvoiceId]				= ARI.[intInvoiceId] 
		,[intBillId]				= NULL
		,[strTransactionNumber]		= @InvoiceNumber
		,[intTermId]				= ARI.[intTermId] 
		,[intAccountId]				= ARI.[intAccountId] 
		,[dblInvoiceTotal]			= @InvoiceTotal 
		,[dblDiscount]				= (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END)
		,[dblDiscountAvailable]		= @TermDiscount
		,[dblInterest]				= @Interest
		,[dblAmountDue]				= (@InvoiceAmountDue + @Interest) - (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
		,[dblPayment]				= @Payment		
		,[strInvoiceReportNumber]	= @InvoiceReportNumber
		,[intConcurrencyId]			= 0
	FROM	
		tblARInvoice ARI	
	WHERE
		ARI.[intInvoiceId] = @InvoiceId
	
	SET @NewId = SCOPE_IDENTITY()
	
	UPDATE P
	SET
		 P.[dblAmountPaid]		= (@PaymentTotal + @Payment)
		,P.[dblUnappliedAmount]	= (@AmountPaid + @Payment) - (PD.dblPayment + @Payment)
	FROM tblARPayment P
	INNER JOIN (SELECT intPaymentId, SUM(dblPayment) AS dblPayment FROM tblARPaymentDetail GROUP BY intPaymentId) PD
		ON P.[intPaymentId] = PD.[intPaymentId]
	WHERE
		P.[intPaymentId] = @PaymentId

	
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