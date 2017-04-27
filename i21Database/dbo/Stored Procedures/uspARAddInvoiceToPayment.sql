CREATE PROCEDURE [dbo].[uspARAddInvoiceToPayment]
	 @PaymentId						INT
	,@InvoiceId						INT
	,@Payment						NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount				BIT				= 1
	,@Discount						NUMERIC(18,6)	= 0.000000	
	,@Interest						NUMERIC(18,6)	= 0.000000
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRateId		INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)	= 1.000000
	,@AllowOverpayment				BIT				= 0
	,@RaiseError					BIT				= 0
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@NewPaymentDetailId			INT				= NULL			OUTPUT 	
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@BasePayment NUMERIC(18, 6)
		,@BaseDiscount NUMERIC(18, 6)
		,@BaseInterest NUMERIC(18, 6)
		,@DateOnly DATETIME			

SET @ZeroDecimal = 0.000000	
SELECT @DateOnly = CAST(GETDATE() AS DATE)

IF ISNULL(@CurrencyExchangeRate,0) = 0
	SET @CurrencyExchangeRate = 1.000000

SET @Payment		= [dbo].fnRoundBanker(@Payment, [dbo].[fnARGetDefaultDecimal]())
SET @BasePayment	= [dbo].fnRoundBanker(@Payment * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
SET @Discount		= [dbo].fnRoundBanker(@Discount, [dbo].[fnARGetDefaultDecimal]())
SET @BaseDiscount	= [dbo].fnRoundBanker(@Discount * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
SET @Interest		= [dbo].fnRoundBanker(@Interest, [dbo].[fnARGetDefaultDecimal]())
SET @BaseInterest	= [dbo].fnRoundBanker(@Interest * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())

IF NOT EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The payment Id provided does not exists!', 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The invoice Id provided does not exists!', 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND (([ysnPosted] = 1 AND [strTransactionType] <> 'Customer Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Customer Prepayment')))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The invoice provided is not yet posted!', 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash')
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Invoice of type Cash cannot be added!', 16, 1);
		RETURN 0;
	END
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Invoice of type Cash Refund cannot be added!', 16, 1);
		RETURN 0;
	END

DECLARE @InvoiceTotal		NUMERIC(18, 6)
	,@BaseInvoiceTotal		NUMERIC(18, 6)
	,@InvoiceAmountDue		NUMERIC(18, 6)
	,@BaseInvoiceAmountDue	NUMERIC(18, 6)
	,@TermDiscount			NUMERIC(18, 6)
	,@BaseTermDiscount		NUMERIC(18, 6)
	,@InvoiceNumber			NVARCHAR(50)
	,@TransactionType		NVARCHAR(25)
	,@AmountPaid			NUMERIC(18, 6)
	,@PaymentTotal			NUMERIC(18, 6)
	,@BasePaymentTotal		NUMERIC(18, 6)
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
	 @InvoiceTotal			= [dblInvoiceTotal] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
	,@BaseInvoiceTotal		= [dblBaseInvoiceTotal] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
	,@InvoiceAmountDue		= [dblAmountDue] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
	,@BaseInvoiceAmountDue	= [dblBaseAmountDue] * (CASE WHEN [strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
	,@TermDiscount			= [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,@BaseTermDiscount		= [dbo].fnRoundBanker([dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
	,@InvoiceNumber			= [strInvoiceNumber]
	,@TransactionType		= [strTransactionType]
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
			RAISERROR('Payment on %s is over the transaction''s amount due.', 16, 1, @InvoiceNumber);
		RETURN 0;
	END

SET @PaymentTotal = [dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
SET @BasePaymentTotal = [dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(dblBasePayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())

DECLARE @ErrorMsg NVARCHAR(100)
SET @ErrorMsg = CONVERT(NVARCHAR(100),CAST(ISNULL(@Payment,@ZeroDecimal) AS MONEY),2) 

IF (@PaymentTotal + @Payment) > (@AmountPaid + @Payment) AND @TransactionType <> 'Customer Prepayment'
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Payment of %s for invoice will cause an under payment.', 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF ISNULL(@AllowOverpayment,0) = 0 AND (@PaymentTotal + @Payment) > (@AmountPaid + @Payment)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Payment of %s for invoice will cause an overpayment.', 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF @TransactionType IN ('Credit Memo','Overpayment') AND @Payment > 0
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Positive payment amount is not allowed for invoice of type %s.', 16, 1, @TransactionType);
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
		,[dblBaseInvoiceTotal]
		,[dblDiscount]
		,[dblBaseDiscount]
		,[dblDiscountAvailable]
		,[dblInterest]
		,[dblBaseInterest]
		,[dblAmountDue]
		,[dblBaseAmountDue]
		,[dblPayment]		
		,[dblBasePayment]		
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
		,[dblBaseInvoiceTotal]		= @BaseInvoiceTotal 
		,[dblDiscount]				= (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END)
		,[dblBaseDiscount]			= (CASE WHEN @ApplyTermDiscount = 1 THEN @BaseTermDiscount ELSE @BaseDiscount END)
		,[dblDiscountAvailable]		= @TermDiscount
		,[dblInterest]				= @Interest
		,[dblBavseInterest]			= @BaseInterest
		,[dblAmountDue]				= (@InvoiceAmountDue + @Interest) - (@Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
		,[dblBaseAmountDue]			= (@BaseInvoiceAmountDue + @BaseInterest) - (@BasePayment + (CASE WHEN @ApplyTermDiscount = 1 THEN @BaseTermDiscount ELSE @BaseDiscount END))
		,[dblPayment]				= @Payment		
		,[dblBasePayment]			= @BasePayment		
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
		,P.[dblBaseAmountPaid]	= (@BasePaymentTotal + @BasePayment)
		,P.[dblUnappliedAmount]	= (@PaymentTotal + @Payment) - (PD.dblPayment)
		,P.[dblBaseUnappliedAmount]	= (@BasePaymentTotal + @BasePayment) - (PD.dblBasePayment)
	FROM tblARPayment P
	INNER JOIN 
		(SELECT
			 intPaymentId
			,SUM(dblPayment) AS dblPayment
			,SUM(dblBasePayment) AS dblBasePayment
		FROM
			tblARPaymentDetail GROUP BY intPaymentId
		) PD
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