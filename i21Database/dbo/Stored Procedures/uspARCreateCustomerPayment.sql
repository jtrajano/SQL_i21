CREATE PROCEDURE [dbo].[uspARCreateCustomerPayment]
	 @EntityCustomerId	INT
	,@CompanyLocationId	INT
	,@CurrencyId		INT				= NULL
	,@DatePaid			DATETIME
	,@AccountId			INT				= NULL
	,@BankAccountId		INT				= NULL
	,@AmountPaid		NUMERIC(18,6)	= 0.000000
	,@PaymentMethodId	INT
	,@PaymentInfo		NVARCHAR(50)	= NULL
	,@ApplytoBudget		BIT				= 0
	,@ApplyOnAccount	BIT				= 0
	,@Notes				NVARCHAR(250)	= ''
	,@EntityId			INT
	,@AllowPrepayment	BIT				= 0
	,@AllowOverpayment	BIT				= 0
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL			OUTPUT
	,@NewPaymentId		INT				= NULL			OUTPUT 		
	,@InvoiceId			INT				= NULL
	,@Payment			NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount	BIT				= 1
	,@Discount			NUMERIC(18,6)	= 0.000000	
	,@Interest			NUMERIC(18,6)	= 0.000000			
	,@InvoicePrepayment	BIT				= 0
	,@WriteOffAccountId	INT				= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@DefaultCurrency INT
		,@ARAccountId INT
		,@TransactionType NVARCHAR(50)
		

SET @ZeroDecimal = 0.000000	
SET @DefaultCurrency = ISNULL((SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)
SELECT @DateOnly = CAST(GETDATE() AS DATE)
SELECT @TransactionType = strTransactionType FROM tblARInvoice WHERE intInvoiceId = @InvoiceId

	
IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @EntityCustomerId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120025, 16, 1);
		RETURN 0;
	END

IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @EntityCustomerId AND ysnActive = 1)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120026, 16, 1);
		RETURN 0;
	END	

IF NOT EXISTS(SELECT NULL FROM tblSMPaymentMethod WHERE [intPaymentMethodID] = @PaymentMethodId)
	BEGIN		
		IF ISNULL(120032,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);		
		RETURN 0;
	END


IF NOT EXISTS(SELECT NULL FROM tblSMPaymentMethod WHERE [intPaymentMethodID] = @PaymentMethodId AND [ysnActive] = 1)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120070, 16, 1);		
		RETURN 0;
	END	
		
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120027, 16, 1);		
		RETURN 0;
	END	

IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId AND [ysnLocationActive] = 1)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120028, 16, 1);		
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblEMEntity WHERE [intEntityId] = @EntityId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120029, 16, 1);		
		RETURN 0;
	END


IF @AllowPrepayment = 0 AND @InvoiceId IS NULL AND @AmountPaid > @ZeroDecimal
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120035, 16, 1);		
		RETURN 0;
	END	

IF @AllowOverpayment = 0 AND @ApplyTermDiscount = 0 AND @InvoiceId IS NOT NULL AND @AmountPaid > (@Payment + @Discount - @Interest)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120071, 16, 1);		
		RETURN 0;
	END


SET @AmountPaid = ROUND(@AmountPaid, [dbo].[fnARGetDefaultDecimal]())

	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @NewId INT
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	INSERT INTO [tblARPayment]
		([intEntityCustomerId]
		,[intCurrencyId]
		,[dtmDatePaid]
		,[intAccountId]
		,[intBankAccountId]
		,[intPaymentMethodId]
		,[intLocationId]
		,[dblAmountPaid]
		,[dblUnappliedAmount]
		,[dblOverpayment]
		,[dblBalance]
		,[strPaymentInfo]
		,[strNotes]
		,[ysnApplytoBudget]
		,[ysnApplyOnAccount]
		,[intEntityId]
		,[ysnInvoicePrepayment]
		,[strPaymentMethod]
		,[intWriteOffAccountId]
		,[intConcurrencyId])
	SELECT
		 [intEntityCustomerId]			= ARC.[intEntityId]
		,[intCurrencyId]				= ISNULL(@CurrencyId, ISNULL(ARC.[intCurrencyId], @DefaultCurrency))	
		,[dtmDatePaid]					= @DatePaid
		,[intAccountId]					= @AccountId
		,[intBankAccountId]				= @BankAccountId
		,[intPaymentMethodId]			= @PaymentMethodId
		,[intLocationId]				= @CompanyLocationId
		,[dblAmountPaid]				= @AmountPaid
		,[dblUnappliedAmount]			= @AmountPaid
		,[dblOverpayment]				= @ZeroDecimal
		,[dblBalance]					= @ZeroDecimal
		,[strPaymentInfo]				= @PaymentInfo
		,[strNotes]						= @Notes
		,[ysnApplytoBudget]				= @ApplytoBudget
		,[ysnApplyOnAccount]			= @ApplyOnAccount
		,[intEntityId]					= @EntityId
		,[ysnInvoicePrepayment]			= @InvoicePrepayment
		,[strPaymentMethod]				= (SELECT [strPaymentMethod] FROM tblSMPaymentMethod WHERE [intPaymentMethodID] = @PaymentMethodId)
		,[intWriteOffAccountId]			= @WriteOffAccountId
		,[intConcurrencyId]				= 0		
	FROM	
		tblARCustomer ARC	
	WHERE ARC.[intEntityId] = @EntityCustomerId
	
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


IF @InvoiceId IS NOT NULL
BEGIN

	SET @Payment = ROUND(@Payment, [dbo].[fnARGetDefaultDecimal]())
	SET @Discount = ROUND(@Discount, [dbo].[fnARGetDefaultDecimal]())
	SET @Interest = ROUND(@Interest, [dbo].[fnARGetDefaultDecimal]())

	BEGIN TRY
		EXEC [dbo].[uspARAddInvoiceToPayment]		
			 @PaymentId				= @NewId
			,@InvoiceId				= @InvoiceId
			,@Payment				= @Payment
			,@ApplyTermDiscount		= @ApplyTermDiscount
			,@Discount				= @Discount	
			,@Interest				= @Interest
			,@AllowOverpayment		= @AllowOverpayment
			,@RaiseError			= @RaiseError
			,@ErrorMessage			= @AddDetailError	OUTPUT
			,@NewPaymentDetailId	= @NewDetailId		OUTPUT
			

			IF LEN(ISNULL(@AddDetailError,'')) > 0
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
				END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH
END	

SET @NewPaymentId = @NewId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END