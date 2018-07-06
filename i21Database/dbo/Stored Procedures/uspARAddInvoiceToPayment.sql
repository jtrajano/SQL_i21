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
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON


DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@BasePayment NUMERIC(18, 6)
		,@BaseDiscount NUMERIC(18, 6)
		,@BaseInterest NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@InitTranCount INT
		,@Savepoint NVARCHAR(32)
		,@ExchangeRate NUMERIC(18,6)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInvoiceToPayment' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
		

SET @ZeroDecimal = 0.000000	
SELECT @DateOnly = CAST(GETDATE() AS DATE)

SELECT @ExchangeRate = [dblExchangeRate] FROM tblARPayment WHERE [intPaymentId] = @PaymentId
IF ISNULL(@ExchangeRate,0) = 0
	SET @ExchangeRate = 1.000000 

IF ISNULL(@CurrencyExchangeRate,0) = 0
	SET @CurrencyExchangeRate = 1.000000 

SET @Payment		= [dbo].fnRoundBanker(@Payment, [dbo].[fnARGetDefaultDecimal]())
SET @BasePayment	= [dbo].fnRoundBanker([dbo].fnRoundBanker(@Payment, [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())
SET @Discount		= [dbo].fnRoundBanker(@Discount, [dbo].[fnARGetDefaultDecimal]())
SET @BaseDiscount	= [dbo].fnRoundBanker([dbo].fnRoundBanker(@Discount, [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())
SET @Interest		= [dbo].fnRoundBanker(@Interest, [dbo].[fnARGetDefaultDecimal]())
SET @BaseInterest	= [dbo].fnRoundBanker([dbo].fnRoundBanker(@Interest, [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())

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
	
IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1) -- (([ysnPosted] = 1 AND [strTransactionType] <> 'Customer Prepayment') OR ([ysnPosted] = 0 AND [strTransactionType] = 'Customer Prepayment')))
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
/* START AR-7078*/	
--IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [ysnPosted] = 1 AND [strTransactionType] = 'Cash Refund')
--	BEGIN		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR('Invoice of type Cash Refund cannot be added!', 16, 1);
--		RETURN 0;
--	END
/*END AR-7078*/
DECLARE @InvoiceTotal		NUMERIC(18, 6)
	,@BaseInvoiceTotal		NUMERIC(18, 6)
	,@InvoiceAmountDue		NUMERIC(18, 6)
	,@BaseInvoiceAmountDue	NUMERIC(18, 6)
	,@TermDiscount			NUMERIC(18, 6)
	,@BaseTermDiscount		NUMERIC(18, 6)
	,@AvailableDiscount		NUMERIC(18, 6)
	,@BaseAvailableDiscount	NUMERIC(18, 6)
	,@InvoiceNumber			NVARCHAR(50)
	,@TransactionType		NVARCHAR(25)
	,@AmountPaid			NUMERIC(18, 6)
	,@PaymentTotal			NUMERIC(18, 6)
	,@BasePaymentTotal		NUMERIC(18, 6)
	,@PaymentDate			DATETIME
	,@dtmDiscountDate		DATETIME
	,@InvoiceReportNumber	NVARCHAR(MAX)
 
SELECT
	 @PaymentDate	= [dtmDatePaid]
	,@AmountPaid	= [dblAmountPaid]
FROM
	tblARPayment
WHERE
	[intPaymentId] = @PaymentId

SELECT
	 @InvoiceTotal			= [dblInvoiceTotal] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@BaseInvoiceTotal		= [dblBaseInvoiceTotal] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@InvoiceAmountDue		= [dblAmountDue] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@BaseInvoiceAmountDue	= [dblBaseAmountDue] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@TermDiscount			= [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@BaseTermDiscount		= [dbo].fnRoundBanker(ISNULL(dbo.[fnGetDiscountBasedOnTerm](@PaymentDate, [dtmDate], [intTermId], [dblBaseInvoiceTotal]), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@AvailableDiscount		= [dblDiscountAvailable] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@BaseAvailableDiscount	= [dblBaseDiscountAvailable] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
	,@InvoiceNumber			= [strInvoiceNumber]
	,@TransactionType		= [strTransactionType]
	,@dtmDiscountDate		= [dtmDiscountDate]
FROM [vyuARInvoicesForPaymentIntegration] I
WHERE
	[intInvoiceId] = @InvoiceId

SELECT 	
	@InvoiceReportNumber	= [strInvoiceReportNumber]
FROM 
	tblCFTransaction
WHERE 
	intInvoiceId = @InvoiceId

IF (ABS(@InvoiceAmountDue) + @Interest) < (ABS(@Payment) + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Payment on %s is over the transaction''s amount due.', 16, 1, @InvoiceNumber);
		RETURN 0;
	END

SET @PaymentTotal = [dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(dblPayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
SET @BasePaymentTotal = [dbo].fnRoundBanker(ISNULL((SELECT SUM(ISNULL(dblBasePayment, @ZeroDecimal)) FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())

DECLARE @ErrorMsg NVARCHAR(100)
SET @ErrorMsg = CONVERT(NVARCHAR(100),CAST(ISNULL(@Payment,@ZeroDecimal) AS MONEY),2) 

IF (CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId) THEN @PaymentTotal ELSE @AmountPaid END + @Payment) > (@AmountPaid + @Payment) AND (@TransactionType <> 'Customer Prepayment' OR @TransactionType <> 'Cash Refund' )
	BEGIN	
		IF ISNULL(@RaiseError,0) = 1
		
			RAISERROR('Payment of %s for invoice will cause an under payment.', 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF ISNULL(@AllowOverpayment,0) = 0 AND (CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId) THEN @PaymentTotal ELSE @AmountPaid END  + @Payment) > (@AmountPaid + @Payment)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Payment of %s for invoice will cause an overpayment.', 16, 1, @ErrorMsg);
		RETURN 0;
	END

IF dbo.fnARGetInvoiceAmountMultiplier(@TransactionType) = -1 AND @Payment > 0
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Positive payment amount is not allowed for invoice of type %s.', 16, 1, @TransactionType);
		RETURN 0;
	END

IF dbo.fnARGetInvoiceAmountMultiplier(@TransactionType) = -1 
	BEGIN
		SET @Discount		= @ZeroDecimal 
		SET @Interest		= @ZeroDecimal
		SET @TermDiscount	= @ZeroDecimal
	END
		
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

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
		,[dblBaseDiscountAvailable]
		,[dblInterest]
		,[dblBaseInterest]
		,[dblAmountDue]
		,[dblBaseAmountDue]
		,[dblPayment]		
		,[dblBasePayment]		
		,[strInvoiceReportNumber]
		,[intConcurrencyId]
		,[dtmDiscountDate]
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
		,[dblDiscountAvailable]		= ARI.[dblDiscountAvailable] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
		,[dblBaseDiscountAvailable]	= ARI.[dblBaseDiscountAvailable] * dbo.fnARGetInvoiceAmountMultiplier([strTransactionType])
		,[dblInterest]				= @Interest
		,[dblBaseInterest]			= @BaseInterest
		,[dblAmountDue]				= (@InvoiceAmountDue + @Interest) - @Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END)
		,[dblBaseAmountDue]			= [dbo].fnRoundBanker([dbo].fnRoundBanker((@InvoiceAmountDue + @Interest) - @Payment + (CASE WHEN @ApplyTermDiscount = 1 THEN @TermDiscount ELSE @Discount END), [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())		
		,[dblPayment]				= @Payment		
		,[dblBasePayment]			= @BasePayment		
		,[strInvoiceReportNumber]	= @InvoiceReportNumber
		,[intConcurrencyId]			= 0
		,[dtmDiscountDate]			= @dtmDiscountDate
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
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

SET @NewPaymentDetailId = @NewId

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END

SET @ErrorMessage = NULL;
RETURN 1;
	
END