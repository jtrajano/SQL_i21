﻿CREATE PROCEDURE [dbo].[uspARProcessPaymentFromInvoice]
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
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal DECIMAL(18,6)
		,@InitTranCount	INT
		,@Savepoint		NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInventoryItemToInvoices' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

SET @ZeroDecimal = 0.000000

	
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
	
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] = @PaymentId) AND EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId)
BEGIN
	IF EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId AND [ysnPosted] = 1)
	BEGIN
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
			
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
	
	BEGIN TRY
		DELETE FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId
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


	BEGIN TRY
		DELETE FROM tblARPayment WHERE [intPaymentId] = @PaymentId
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
		
	
	SET @PaymentId = NULL	
	RETURN 1;
END		


IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] IS NOT NULL)
BEGIN
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END
		
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
	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'PREPAY')
		BEGIN
			INSERT INTO tblSMPaymentMethod (
				strPaymentMethod
				, intNumber
				, ysnActive
				, intSort
				, intConcurrencyId
			)
			SELECT strPaymentMethod = 'Prepay'
				, intNumber		 	= 1
				, ysnActive			= 1
				, intSort			= 0
				, intConcurrencyId	= 1
		END
	
	SET @PaymentMethodId = (SELECT TOP 1 [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethod] = 'Prepay')
	
	IF EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE intPaymentMethodID = @PaymentMethodId AND ysnActive = 0)
		BEGIN
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR('Payment Method: Prepay is not active!', 16, 1);
			RETURN 0;
		END

	SELECT TOP 1
		 @EntityCustomerId	= ARI.[intEntityCustomerId]
		,@CompanyLocationId	= ARI.[intCompanyLocationId]
		,@CurrencyId		= ARI.[intCurrencyId]
		,@DatePaid			= ARI.[dtmPostDate]
		,@AccountId			= NULL
		,@BankAccountId		= CASE WHEN ARI.[strTransactionType] = 'Customer Prepayment' THEN 
									(SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId IN (SELECT TOP 1 intCashAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = ARI.intCompanyLocationId))
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

	IF EXISTS(SELECT TOP 1 1 FROM tblARCustomerBudget WHERE intEntityCustomerId = @EntityCustomerId)
	BEGIN
		SET @ApplytoBudget = 1
	END

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


DECLARE @NewId INT
	,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	
	UPDATE tblARInvoice
		SET
			[ysnPosted]		= 1
	WHERE
		[intInvoiceId] = @InvoiceId 

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
				BEGIN
					IF @InitTranCount = 0
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					ELSE
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @Savepoint
				END

				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
		
		UPDATE tblARInvoice
		SET
			[intPaymentId]	= @NewId
		WHERE
			[intInvoiceId] = @InvoiceId 
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


		  
SET @PaymentId = @NewId		                 
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
RETURN @NewId

END