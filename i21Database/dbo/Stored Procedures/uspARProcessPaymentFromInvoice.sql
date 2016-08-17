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
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

BEGIN TRANSACTION
	
IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] = @PaymentId) AND EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId)
BEGIN
	IF EXISTS(SELECT NULL FROM tblARPayment WHERE [intPaymentId] = @PaymentId AND [ysnPosted] = 1)
		BEGIN
			IF @@ERROR <> 0	GOTO _RollBackTransaction			
			RAISERROR(120045, 16, 1)
			GOTO _ExitTransaction
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
		IF @@ERROR <> 0	GOTO _RollBackTransaction
		SET @ErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
	END CATCH
	
	BEGIN TRY
		DELETE FROM tblARPaymentDetail WHERE [intPaymentId] = @PaymentId
	END TRY
	BEGIN CATCH
		IF @@ERROR <> 0	GOTO _RollBackTransaction
		SET @ErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
	END CATCH


	BEGIN TRY
		DELETE FROM tblARPayment WHERE [intPaymentId] = @PaymentId
	END TRY
	BEGIN CATCH
		IF @@ERROR <> 0	GOTO _RollBackTransaction
		SET @ErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
	END CATCH
		
	
	SET @PaymentId = NULL	
	RETURN 1;
END		


IF EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId AND [intPaymentId] IS NOT NULL)
BEGIN
	IF @@ERROR <> 0	GOTO _RollBackTransaction	
	RAISERROR(120046, 16, 1)
	GOTO _ExitTransaction
END


DECLARE
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
	,@AllowPrepayment	BIT				= 0
	,@AllowOverpayment	BIT				= 0
	,@Payment			NUMERIC(18,6)	= 0.000000
	,@ApplyTermDiscount	BIT				= 1
	,@Discount			NUMERIC(18,6)	= 0.000000	
	,@Interest			NUMERIC(18,6)	= 0.000000	

BEGIN TRY
	SELECT TOP 1
		 @EntityCustomerId	= ARI.[intEntityCustomerId]
		,@CompanyLocationId	= ARI.[intCompanyLocationId]
		,@CurrencyId		= ARI.[intCurrencyId]
		,@DatePaid			= ARI.[dtmPostDate]
		,@AccountId			= NULL
		,@BankAccountId		= NULL
		,@AmountPaid		= ARI.[dblAmountDue] * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Overpayment','Customer Prepayment') THEN -1 ELSE 1 END)
		,@PaymentMethodId	= ISNULL(ARI.[intPaymentMethodId], (SELECT TOP 1 [intPaymentMethodID] FROM tblSMPaymentMethod ORDER BY [ysnActive] DESC, [strPaymentMethod]))
		,@PaymentInfo		= ''
		,@ApplytoBudget		= 0
		,@ApplyOnAccount	= 0
		,@Notes				= ''
		,@AllowPrepayment	= 0
		,@AllowOverpayment	= 0
		,@Payment			= ARI.[dblAmountDue] * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo','Overpayment','Customer Prepayment') THEN -1 ELSE 1 END)
		,@ApplyTermDiscount	= @ZeroDecimal
		,@Discount			= @ZeroDecimal
		,@Interest			= @ZeroDecimal
	FROM
		tblARInvoice ARI
	WHERE 
		ARI.[intInvoiceId] = @InvoiceId
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
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

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF @@ERROR <> 0	GOTO _RollBackTransaction
				SET @ErrorMessage = ERROR_MESSAGE()  
				RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
			END
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
END CATCH


UPDATE tblARInvoice
SET
	[ysnPosted]		= 1
	,[intPaymentId]	= @NewId
WHERE
	[intInvoiceId] = @InvoiceId 
		  
SET @PaymentId = @NewId		                 

IF @@ERROR = 0 GOTO _CommitTransaction
RETURN @NewId
GOTO _ExitTransaction

_RollBackTransaction:
ROLLBACK TRANSACTION
GOTO _ExitTransaction

_CommitTransaction: 
COMMIT TRANSACTION

_ExitTransaction:

END