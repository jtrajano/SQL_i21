﻿CREATE PROCEDURE uspSMCreateInvoicePayment
	 @strInvoiceNumber 		AS NVARCHAR(MAX)	= NULL
	,@dblPayment 			AS NUMERIC(18,6) 
	,@strInvoiceAndPayment 	AS NVARCHAR(MAX)	= NULL
	,@strCreditCardNumber 	AS NVARCHAR(50)		= NULL
	,@intUserId 			AS INT
	,@strAction 			AS NVARCHAR(50)
	,@intEntityCustomerId	AS INT 				= NULL
	,@intEntityCardInfoId 	AS INT 				= NULL
	,@intPaymentId 			AS INT 				= NULL
	,@strPaymentMethod 		AS NVARCHAR(50)		= NULL
	,@ysnScheduledPayment	AS BIT 				= 0
	,@dtmScheduledPayment	AS DATETIME 		= NULL
	,@intBankAccountId  	AS INT     			= NULL
	,@strPaymentIdNew 		AS NVARCHAR(50) 	= NULL OUTPUT
	,@intPaymentIdNew 		AS INT 				= NULL OUTPUT
	,@ErrorMessage 			AS NVARCHAR(250)	= NULL OUTPUT
AS

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @EntriesForPayment		AS PaymentIntegrationStagingTable
DECLARE @LogId INT

--================================================================
--   Add
--================================================================
IF @strAction = 'Add'
BEGIN
	DECLARE @intPaymentMethodId		INT = NULL
		  , @intUndepositedFundId 	INT	= NULL
		  , @intCompanyLocationId	INT = NULL
		  , @intEFTARFileFormatId	INT = NULL
		  , @strLocationName		NVARCHAR(100) = NULL
		  , @strBankName 			NVARCHAR(100) = NULL
		  , @strAccountNo 			NVARCHAR(500) = NULL
	      , @dblTotalPayment		NUMERIC(18, 6) = 0

	--GET DEFAULT VALUES
	SELECT TOP 1 @intCompanyLocationId	= CL.intCompanyLocationId
			   , @intUndepositedFundId	= CL.intUndepositedFundsId
			   , @intBankAccountId		= CASE WHEN @strPaymentMethod <> 'ACH' THEN BA.intBankAccountId ELSE @intBankAccountId END
			   , @strLocationName		= CL.strLocationName
	FROM tblSMCompanyLocation CL
	LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
	WHERE CL.ysnLocationActive = 1

	SELECT TOP 1 @intPaymentMethodId = intPaymentMethodID
	FROM tblSMPaymentMethod
	WHERE strPaymentMethod = @strPaymentMethod

	IF ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 AND ((@ysnScheduledPayment = 1 AND @intBankAccountId IS NOT NULL) OR ISNULL(@ysnScheduledPayment, 0) = 0)
		BEGIN
			SET @intCompanyLocationId	= NULL
			SET @intUndepositedFundId	= NULL

			SELECT TOP 1 @intCompanyLocationId	= CL.intCompanyLocationId
					   , @intUndepositedFundId	= CL.intUndepositedFundsId
					   , @strLocationName		= CL.strLocationName
			FROM tblSMCompanyLocation CL
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			WHERE CL.ysnLocationActive = 1
			  AND ISNULL(BA.intEFTARFileFormatId, 0) <> 0

			SELECT TOP 1 @strBankName    		= B.strBankName
					   , @strAccountNo   		= dbo.fnAESDecryptASym(BA.strBankAccountNo)
					   , @intEFTARFileFormatId  = BA.intEFTARFileFormatId
			FROM tblCMBank B 
			INNER JOIN tblCMBankAccount BA ON B.intBankId = BA.intBankId
			WHERE BA.intBankAccountId = @intBankAccountId

			IF @strPaymentMethod = 'ACH' AND ISNULL(@intEFTARFileFormatId, 0) = 0
				BEGIN
					SET @ErrorMessage = 'Bank ' + @strBankName + ' with Bank Account No. ' + @strAccountNo + ' requires ACH/NACHA AR setup for ACH payment method!'
					RAISERROR(@ErrorMessage, 16, 1);
					GOTO Exit_Routine
				END
		END
	ELSE
		BEGIN
			DECLARE @strCreditCardConvenienceFee NVARCHAR(100) = NULL
				   ,@intPaymentsLocationId INT = NULL

			SELECT @intPaymentsLocationId = intPaymentsLocationId,
				   @strCreditCardConvenienceFee = strCreditCardConvenienceFee
			FROM tblSMCompanyPreference

			IF @ysnScheduledPayment = 1 AND @strCreditCardNumber IS NULL
				SELECT @strCreditCardNumber = strCreditCardNumber FROM tblEMEntityCardInformation WHERE intEntityCardInfoId = @intEntityCardInfoId

			IF @intPaymentsLocationId IS NOT NULL
			BEGIN
				SET @intCompanyLocationId = @intPaymentsLocationId
			END

			IF ISNULL(@intPaymentsLocationId, 0) = 0 AND ISNULL(@strCreditCardConvenienceFee, '') != 'None'
				BEGIN
					SET @ErrorMessage = 'Payments Location is required when processing Credit Card!'
					RAISERROR(@ErrorMessage, 16, 1);
					GOTO Exit_Routine
				END
		END

	IF ISNULL(@intCompanyLocationId, 0) = 0
		BEGIN
			SET @ErrorMessage = 'Company Location is required when creating payment!'
			RAISERROR(@ErrorMessage, 16, 1);
			GOTO Exit_Routine
		END
		
	--FOR PAYMENTS WITH INVOICES
	IF ISNULL(@strInvoiceNumber, '') <> ''
		BEGIN
			--CREATE TEMP TABLES
			IF(OBJECT_ID('tempdb..#RAWVALUE') IS NOT NULL)
			BEGIN
				DROP TABLE #RAWVALUE
			END

			IF(OBJECT_ID('tempdb..#INVOICEANDPAYMENT') IS NOT NULL)
			BEGIN
				DROP TABLE #INVOICEANDPAYMENT
			END

			--STORE INVOICE NUMBERS WITH CORRESPONDING AMOUNT
			SELECT strRawValue = strValues 
			INTO #RAWVALUE  
			FROM dbo.fnARGetRowsFromDelimitedValues(@strInvoiceAndPayment)

			SELECT strInvoiceNumber	= INVOICENUM.POS COLLATE Latin1_General_CI_AS
				, dblPayment		= CONVERT(NUMERIC(18,6), SUBSTRING(strRawValue, PAYMENT.POS + 1, DISCOUNT.POS - PAYMENT.POS - 1))
				, dblDiscount		= CONVERT(NUMERIC(18,6), SUBSTRING(strRawValue, DISCOUNT.POS + 1, INTEREST.POS - DISCOUNT.POS -1))
				, dblInterest		= CONVERT(NUMERIC(18,6), SUBSTRING(strRawValue, INTEREST.POS + 1, CREDITCARDFEE.POS - INTEREST.POS -1))
				, dblCreditCardFee	= CONVERT(NUMERIC(18,6), SUBSTRING(strRawValue, CREDITCARDFEE.POS + 1, 100))
			INTO #INVOICEANDPAYMENT
			FROM #RAWVALUE
			CROSS APPLY (SELECT LEFT(strRawValue, CHARINDEX('|', strRawValue) - 1)) AS INVOICENUM(POS)
			CROSS APPLY (SELECT (CHARINDEX('|', strRawValue))) AS PAYMENT(POS)
			CROSS APPLY (SELECT (CHARINDEX('|', strRawValue, PAYMENT.POS+1))) AS DISCOUNT(POS)
			CROSS APPLY (SELECT (CHARINDEX('|', strRawValue, DISCOUNT.POS+1))) AS INTEREST(POS)
			CROSS APPLY (SELECT (CHARINDEX('|', strRawValue, INTEREST.POS+1))) AS CREDITCARDFEE(POS)

			SELECT @dblTotalPayment = SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblCreditCardFee, 0))
			FROM #INVOICEANDPAYMENT
			
			INSERT INTO @EntriesForPayment (
				intId
				, strSourceTransaction
				, intSourceId
				, strSourceId
				, intPaymentId
				, intEntityCustomerId
				, intCompanyLocationId
				, intCurrencyId
				, dtmDatePaid
				, intPaymentMethodId
				, strPaymentMethod
				, strPaymentInfo
				, strNotes
				, intAccountId
				, intBankAccountId
				, dblAmountPaid
				, ysnPost
				, intEntityId
				, intEntityCardInfoId
				, intInvoiceId
				, strTransactionType
				, strTransactionNumber
				, intTermId
				, intInvoiceAccountId
				, dblInvoiceTotal
				, dblBaseInvoiceTotal
				, ysnApplyTermDiscount
				, dblDiscount
				, dblDiscountAvailable
				, dblWriteOffAmount
				, dblBaseWriteOffAmount
				, dblInterest
				, dblPayment
				, dblCreditCardFee
				, dblAmountDue
				, dblBaseAmountDue
				, strInvoiceReportNumber
				, intCurrencyExchangeRateTypeId
				, intCurrencyExchangeRateId
				, dblCurrencyExchangeRate
				, ysnAllowOverpayment
				, ysnFromAP
				, ysnScheduledPayment
				, dtmScheduledPayment
			)
			SELECT 
				intId							= INVOICE.intInvoiceId
				, strSourceTransaction			= INVOICE.strTransactionType
				, intSourceId					= INVOICE.intInvoiceId
				, strSourceId					= INVOICE.strInvoiceNumber
				, intPaymentId					= INVOICE.intPaymentId
				, intEntityCustomerId			= INVOICE.intEntityCustomerId
				, intCompanyLocationId			= @intCompanyLocationId
				, intCurrencyId					= INVOICE.intCurrencyId
				, dtmDatePaid					= CASE WHEN @ysnScheduledPayment = 1 THEN @dtmScheduledPayment ELSE GETDATE() END
				, intPaymentMethodId			= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN @intPaymentMethodId ELSE 11 END
				, strPaymentMethod				= ISNULL(@strCreditCardNumber, @strPaymentMethod)
				, strPaymentInfo				= NULL
				, strNotes						= NULL
				, intAccountId					= INVOICE.intAccountId
				, intBankAccountId				= CASE WHEN (ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0) OR ISNULL(@ysnScheduledPayment, 0) = 0 THEN @intBankAccountId ELSE NULL END
				, dblAmountPaid					= ISNULL(@dblTotalPayment, 0)
				, ysnPost						= CASE WHEN (ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 AND @strPaymentMethod <> 'ACH') OR ISNULL(@ysnScheduledPayment, 0) = 0 THEN 1 ELSE 0 END
				, intEntityId					= @intUserId
				, intEntityCardInfoId			= NULLIF(@intEntityCardInfoId, 0)
				, intInvoiceId					= INVOICE.intInvoiceId
				, strTransactionType			= INVOICE.strTransactionType
				, strTransactionNumber			= INVOICE.strTransactionNumber
				, intTermId						= INVOICE.intTermId
				, intInvoiceAccountId			= INVOICE.intAccountId
				, dblInvoiceTotal				= INVOICE.dblInvoiceTotal
				, dblBaseInvoiceTotal			= INVOICE.dblBaseInvoiceTotal
				, ysnApplyTermDiscount			= 0
				, dblDiscount					= PAYMENTS.dblDiscount
				, dblDiscountAvailable			= INVOICE.dblDiscountAvailable
				, dblWriteOffAmount				= 0
				, dblBaseWriteOffAmount			= 0
				, dblInterest					= PAYMENTS.dblInterest
				, dblPayment					= PAYMENTS.dblPayment
				, dblCreditCardFee				= PAYMENTS.dblCreditCardFee
				, dblAmountDue					= (INVOICE.dblAmountDue + PAYMENTS.dblInterest) - PAYMENTS.dblPayment - PAYMENTS.dblDiscount
				, dblBaseAmountDue				= (INVOICE.dblBaseAmountDue + PAYMENTS.dblInterest) - PAYMENTS.dblPayment - PAYMENTS.dblDiscount
				, strInvoiceReportNumber		= INVOICE.strInvoiceReportNumber
				, intCurrencyExchangeRateTypeId	= INVOICE.intCurrencyExchangeRateTypeId
				, intCurrencyExchangeRateId		= INVOICE.intCurrencyExchangeRateId
				, dblCurrencyExchangeRate		= INVOICE.dblCurrencyExchangeRate
				, ysnAllowOverpayment			= 0
				, ysnFromAP						= 0
				, ysnScheduledPayment			= ISNULL(@ysnScheduledPayment, 0)
				, dtmScheduledPayment			= CASE WHEN @ysnScheduledPayment = 1 THEN @dtmScheduledPayment ELSE NULL END
			FROM vyuARInvoicesForPayment INVOICE
			INNER JOIN #INVOICEANDPAYMENT PAYMENTS ON INVOICE.strInvoiceNumber = PAYMENTS.strInvoiceNumber
			WHERE INVOICE.strInvoiceNumber IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strInvoiceNumber))
		END
	--FOR PREPAYMENTS
	ELSE
		BEGIN
			--VALIDATIONS			
			IF ISNULL(@intEntityCustomerId, 0) = 0
				BEGIN
					SET @ErrorMessage = 'Customer is required when creating prepayment!'
					RAISERROR(@ErrorMessage, 16, 1);
					GOTO Exit_Routine
				END

			INSERT INTO @EntriesForPayment (
				  intId
				, strSourceTransaction
				, intSourceId
				, strSourceId
				, intPaymentId
				, intEntityCustomerId
				, intCompanyLocationId
				, intCurrencyId
				, dtmDatePaid
				, intPaymentMethodId
				, strPaymentMethod
				, strPaymentInfo
				, strNotes
				, intAccountId
				, intBankAccountId
				, dblAmountPaid
				, ysnPost
				, intEntityId
			)
			SELECT intId						= 1
				, strSourceTransaction			= 'Direct'
				, intSourceId					= NULL
				, strSourceId					= C.strCustomerNumber
				, intPaymentId					= NULL
				, intEntityCustomerId			= C.intEntityCustomerId
				, intCompanyLocationId			= @intCompanyLocationId
				, intCurrencyId					= C.intCurrencyId
				, dtmDatePaid					= GETDATE()
				, intPaymentMethodId			= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN @intPaymentMethodId ELSE 11 END
				, strPaymentMethod				= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN @strPaymentMethod ELSE @strCreditCardNumber END
				, strPaymentInfo				= NULL
				, strNotes						= 'Prepayment from Portal.'
				, intAccountId					= @intUndepositedFundId
				, intBankAccountId				= @intBankAccountId
				, dblAmountPaid					= @dblPayment
				, ysnPost						= CASE WHEN ISNULL(@intPaymentMethodId, 0) <> 0 THEN 1 ELSE 0 END
				, intEntityId					= @intUserId
			FROM vyuARCustomerSearch C			
			WHERE intEntityId = @intEntityCustomerId
		END

	EXEC [dbo].[uspARProcessPayments]
			 @PaymentEntries	= @EntriesForPayment
			,@UserId			= 1
			,@GroupingOption	= 3
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@LogId				= @LogId OUTPUT

	SELECT TOP 1 @intPaymentIdNew = ISNULL(intPaymentId,0) FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1 AND ysnInsert = 1
	SELECT @strPaymentIdNew = strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentIdNew

	DECLARE @output INT
	EXEC dbo.uspSMInsertTransaction
		@screenNamespace = 'AccountsReceivable.view.ReceivePaymentsDetail',
		@strTransactionNo = @intPaymentIdNew,
		@intEntityId = @intUserId,
		@intKeyValue = @intPaymentIdNew,
		@output = @output

	EXEC dbo.uspSMAuditLog 
		 @keyValue			= @intPaymentIdNew
		,@screenName		= 'AccountsReceivable.view.ReceivePaymentsDetail'
		,@entityId			= @intUserId	
		,@actionType		= 'Created'
		,@changeDescription	= ''			
		,@fromValue			= ''			
		,@toValue			= ''

	-- Start: New way of audit logging
	BEGIN TRY
		DECLARE @auditLogsParam SingleAuditLogParam

		INSERT INTO @auditLogsParam ([Id], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
		SELECT 1, 'Created', '', NULL, NULL, NULL, NULL, NULL, NULL

		EXEC uspSMSingleAuditLog 'AccountsReceivable.view.ReceivePaymentsDetail', @intPaymentIdNew, @intUserId, @auditLogsParam
	END TRY
	BEGIN CATCH
	END CATCH
	-- End: New way of audit logging

	GOTO Exit_Routine
END
--================================================================
--   POST
--================================================================
IF @strAction = 'Post'
BEGIN
	UPDATE tblARPayment 
	SET ysnProcessCreditCard = 1
	  , intCurrentStatus = 5
	WHERE intPaymentId = @intPaymentId

	BEGIN TRY
		EXEC [dbo].[uspARPostPayment] @post			= 1
									, @recap		= 0
									, @param		= @intPaymentId
									, @userId		= @intUserId
									, @raiseError	= 1
	END TRY
	BEGIN CATCH
		DECLARE @strErrorMsg NVARCHAR(250) = ERROR_MESSAGE()

		UPDATE tblARPayment 
		SET intEntityCardInfoId		= @intEntityCardInfoId
		  , ysnProcessCreditCard	= 0 
		  , intCurrentStatus		= 5
		  , strCreditCardNote		= @strErrorMsg
		  , strCreditCardStatus		= 'Failed'
		WHERE intPaymentId = @intPaymentId

	END CATCH

	SET @intPaymentIdNew = @intPaymentId
	SELECT @strPaymentIdNew = strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentId
	
	UPDATE tblARPayment 
	SET intEntityCardInfoId = @intEntityCardInfoId
	  , intCurrentStatus = 5
	WHERE intPaymentId = @intPaymentId

	GOTO Exit_Routine
END

--================================================================
--   DELETE
--================================================================
IF @strAction = 'Delete'
BEGIN
	DELETE FROM tblARPayment WHERE intPaymentId = @intPaymentId AND ysnPosted = 0
	SET @intPaymentIdNew = @intPaymentId

	GOTO Exit_Routine
END

Exit_Routine: