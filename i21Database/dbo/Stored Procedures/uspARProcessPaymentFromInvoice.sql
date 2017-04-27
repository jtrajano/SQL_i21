CREATE PROCEDURE [dbo].[uspARProcessPaymentFromInvoice]
	 @InvoiceId		INT
	,@EntityId		INT			
	,@RaiseError	BIT				= 0				
	,@PaymentId		INT				= NULL	OUTPUT
	,@ErrorMessage	NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] = @PaymentId) AND EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId)
BEGIN
	IF EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId AND [ysnPosted] = 1)
		BEGIN
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Cannot delete posted payment!', 16, 1);
		RETURN 0;
	END
	
	BEGIN TRY
		UPDATE
			tblARInvoice
		SET
			[intPaymentId]	= NULL
			,[ysnPosted]	= 0
		WHERE
			[intInvoiceId] = @InvoiceId
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH
	
	BEGIN TRY
		DELETE FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH


	BEGIN TRY
		DELETE FROM tblARPayment WHERE [intPaymentId] = @PaymentId
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH
		
	
	SET @PaymentId = NULL	
	RETURN 1;
END		


IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] IS NOT NULL)
BEGIN
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION	
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR('Payment has already been created for this Invoice!', 16, 1);
	RETURN 0;
END


DECLARE
	 @EntityCustomerId	INT
	,@CompanyLocationId	INT
	,@CurrencyId		INT				= NULL
	,@DatePaid			DATETIME
	,@AccountId			INT				= NULL
	,@BankAccountId		INT				= NULL
	,@AmountPaid		NUMERIC(18,6)	= 0.000000
	,@PaymentMethodId	INT				= NULL
	,@PaymentInfo		NVARCHAR(50)	= NULL
	,@ApplytoBudget		BIT				= 0
	,@ApplyOnAccount	BIT				= 0
	,@Notes				NVARCHAR(250)	= ''
	,@AllowPrepayment	BIT				= 0
	,@AllowOverpayment	BIT				= 0
	,@Payment			NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount	BIT				= 1
	,@Discount			NUMERIC(18,6)	= 0.000000	
	,@Interest			NUMERIC(18,6)	= 0.000000	

BEGIN TRY
	SET @PaymentMethodId = (SELECT TOP 1 [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethod] = 'Prepay' AND [ysnActive] = 1)

	SELECT TOP 1
		 @EntityCustomerId	= ARI.[intEntityCustomerId]
		,@CompanyLocationId	= ARI.[intCompanyLocationId]
		,@CurrencyId		= ARI.[intCurrencyId]
		,@DatePaid			= ARI.[dtmPostDate]
		,@AccountId			= NULL
		,@BankAccountId		= CASE WHEN ARI.[strTransactionType] = 'Customer Prepayment' THEN 
									(SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId IN (SELECT TOP 1 intDepositAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = ARI.intCompanyLocationId))
								ELSE NULL END
		,@AmountPaid		= ARI.[dblAmountDue] * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
		,@PaymentMethodId	=  ISNULL(@PaymentMethodId, ARI.[intPaymentMethodId])
		,@PaymentInfo		= ''
		,@ApplytoBudget		= 0
		,@ApplyOnAccount	= 0
		,@Notes				= ''
		,@AllowPrepayment	= 0
		,@AllowOverpayment	= 0
		,@Payment			= ARI.[dblAmountDue] * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Overpayment') THEN -1 ELSE 1 END)
		,@ApplyTermDiscount	= @ZeroDecimal
		,@Discount			= @ZeroDecimal
		,@Interest			= @ZeroDecimal
	FROM
		tblARInvoice ARI
	WHERE 
		ARI.[intInvoiceId] = @InvoiceId
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


DECLARE @NewId INT
	,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	EXEC [dbo].[uspARCreateCustomerPayment]
		 @EntityCustomerId	= @EntityCustomerId
		,@CompanyLocationId	= @CompanyLocationId
		,@CurrencyId		= @CurrencyId
		,@DatePaid			= @DatePaid
		,@AccountId			= @AccountId
		,@BankAccountId		= @BankAccountId
		,@AmountPaid		= @AmountPaid
		,@PaymentMethodId	= @PaymentMethodId
		,@PaymentInfo		= @PaymentInfo
		,@ApplytoBudget		= @ApplytoBudget
		,@ApplyOnAccount	= @ApplyOnAccount
		,@Notes				= @Notes
		,@EntityId			= @EntityId
		,@AllowPrepayment	= @AllowPrepayment
		,@AllowOverpayment	= @EntityCustomerId
		,@RaiseError		= @RaiseError
		,@ErrorMessage		= @AddDetailError	OUTPUT
		,@NewPaymentId		= @NewId			OUTPUT
		,@InvoiceId			= @InvoiceId
		,@Payment			= @Payment
		,@ApplyTermDiscount	= @ApplyTermDiscount
		,@Discount			= @Discount
		,@Interest			= @Interest
		,@InvoicePrepayment	= 1

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


UPDATE tblARInvoice
SET
	[ysnPosted]		= 1
	,[intPaymentId]	= @NewId
WHERE
	[intInvoiceId] = @InvoiceId 
		  
SET @PaymentId = @NewId		                 

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
	SET @ErrorMessage = NULL;
RETURN @NewId

END