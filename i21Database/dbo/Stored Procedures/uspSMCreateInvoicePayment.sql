CREATE PROCEDURE uspSMCreateInvoicePayment
	 @strInvoiceNumber 		AS NVARCHAR(MAX)	= NULL
	,@dblPayment 			AS NUMERIC(18,6) 
	,@strInvoiceAndPayment 	AS NVARCHAR(MAX)	= NULL
	,@strCreditCardNumber 	AS NVARCHAR(50)		= NULL
	,@intUserId 			AS INT
	,@strAction 			AS NVARCHAR(50)
	,@intEntityCustomerId	AS INT 				= NULL
	,@intEntityCardInfoId 	AS INT 				= NULL
	,@intPaymentId 			AS INT 				= NULL
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
	
	SELECT TOP 1 @intPaymentMethodId = intPaymentMethodID
	FROM tblSMPaymentMethod
	WHERE strPaymentMethod = 'ACH'

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

			SELECT strInvoiceNumber	= A.InvoiceNumber
				, dblPayment		= CONVERT(NUMERIC(18,6),Split.a.value('.', 'VARCHAR(100)'))
			INTO #INVOICEANDPAYMENT
			FROM (
				SELECT InvoiceNumber	= LEFT(strRawValue, CHARINDEX('|', strRawValue) - 1)
					, String			= CAST('<M>' + REPLACE(SUBSTRING(strRawValue, CHARINDEX('|', strRawValue) + 1, len(strRawValue) - CHARINDEX('|', strRawValue)), ',', '</M><M>') + '</M>' AS XML)
				FROM #RAWVALUE
			) AS A
			CROSS APPLY String.nodes('/M') AS Split(a);

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
				, dblAmountDue
				, dblBaseAmountDue
				, strInvoiceReportNumber
				, intCurrencyExchangeRateTypeId
				, intCurrencyExchangeRateId
				, dblCurrencyExchangeRate
				, ysnAllowOverpayment
				, ysnFromAP
			)
			SELECT 
				intId							= INVOICE.intInvoiceId
				, strSourceTransaction			= INVOICE.strTransactionType
				, intSourceId					= INVOICE.intInvoiceId
				, strSourceId					= INVOICE.strInvoiceNumber
				, intPaymentId					= INVOICE.intPaymentId
				, intEntityCustomerId			= INVOICE.intEntityCustomerId
				, intCompanyLocationId			= INVOICE.intCompanyLocationId
				, intCurrencyId					= INVOICE.intCurrencyId
				, dtmDatePaid					= GETDATE()
				, intPaymentMethodId			= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN @intPaymentMethodId ELSE 11 END
				, strPaymentMethod				= ISNULL(@strCreditCardNumber, 'ACH')
				, strPaymentInfo				= NULL
				, strNotes						= NULL
				, intAccountId					= INVOICE.intAccountId
				, intBankAccountId				= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN BA.intBankAccountId ELSE NULL END
				, dblAmountPaid					= ISNULL(PAYMENTS.dblPayment, 0)
				, ysnPost						= NULL
				, intEntityId					= @intUserId
				, intInvoiceId					= INVOICE.intInvoiceId
				, strTransactionType			= INVOICE.strTransactionType
				, strTransactionNumber			= INVOICE.strTransactionNumber
				, intTermId						= INVOICE.intTermId
				, intInvoiceAccountId			= INVOICE.intAccountId
				, dblInvoiceTotal				= INVOICE.dblInvoiceTotal
				, dblBaseInvoiceTotal			= INVOICE.dblBaseInvoiceTotal
				, ysnApplyTermDiscount			= 0
				, dblDiscount					= INVOICE.dblDiscount
				, dblDiscountAvailable			= INVOICE.dblDiscountAvailable
				, dblWriteOffAmount				= 0
				, dblBaseWriteOffAmount			= 0
				, dblInterest					= INVOICE.dblInterest
				, dblPayment					= ISNULL(PAYMENTS.dblPayment, 0)
				, dblAmountDue					= INVOICE.dblAmountDue - ISNULL(PAYMENTS.dblPayment, 0)
				, dblBaseAmountDue				= INVOICE.dblBaseAmountDue - ISNULL(PAYMENTS.dblPayment, 0)
				, strInvoiceReportNumber		= INVOICE.strInvoiceReportNumber
				, intCurrencyExchangeRateTypeId	= INVOICE.intCurrencyExchangeRateTypeId
				, intCurrencyExchangeRateId		= INVOICE.intCurrencyExchangeRateId
				, dblCurrencyExchangeRate		= INVOICE.dblCurrencyExchangeRate
				, ysnAllowOverpayment			= 0
				, ysnFromAP						= 0
			FROM vyuARInvoicesForPayment INVOICE
			INNER JOIN tblSMCompanyLocation CL ON INVOICE.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 dblPayment 
				FROM #INVOICEANDPAYMENT 
				WHERE strInvoiceNumber COLLATE Latin1_General_CI_AS = INVOICE.strInvoiceNumber
			) PAYMENTS
			WHERE strInvoiceNumber IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strInvoiceNumber))
		END
	--FOR PREPAYMENTS
	ELSE
		BEGIN
			DECLARE @intUndepositedFundId 	INT	= NULL
				  , @intCompanyLocationId	INT = NULL
				  , @intBankAccountId		INT = NULL

			--VALIDATIONS			
			IF ISNULL(@intEntityCustomerId, 0) = 0
				BEGIN
					SET @ErrorMessage = 'Customer is required when creating prepayment!'
					RAISERROR(@ErrorMessage, 16, 1);
					GOTO Exit_Routine
				END

			SELECT TOP 1 @intCompanyLocationId = CL.intCompanyLocationId
					   , @intUndepositedFundId = CL.intUndepositedFundsId
					   , @intBankAccountId	   = BA.intBankAccountId
			FROM vyuARCustomerSearch C
			INNER JOIN tblSMCompanyLocation CL ON C.intWarehouseId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			WHERE C.intEntityId = @intEntityCustomerId

			IF ISNULL(@intCompanyLocationId, 0) = 0
				BEGIN
					SET @ErrorMessage = 'Customer''s Warehouse is required when creating prepayment!'
					RAISERROR(@ErrorMessage, 16, 1);
					GOTO Exit_Routine
				END

			IF ISNULL(@intBankAccountId, 0) = 0 AND ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0
				BEGIN
					SET @ErrorMessage = 'Bank Account is required for payment with ACH payment method!'
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
				, strPaymentMethod				= CASE WHEN ISNULL(@strCreditCardNumber, '') = '' AND ISNULL(@intEntityCardInfoId, 0) = 0 THEN 'ACH' ELSE @strCreditCardNumber END
				, strPaymentInfo				= NULL
				, strNotes						= 'Prepayment from Portal.'
				, intAccountId					= @intUndepositedFundId
				, intBankAccountId				= @intBankAccountId
				, dblAmountPaid					= @dblPayment
				, ysnPost						= 0
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

	SELECT @intPaymentIdNew = ISNULL(intPaymentId,0) FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1
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

	GOTO Exit_Routine
END
--================================================================
--   POST
--================================================================
IF @strAction = 'Post'
BEGIN
	EXEC [dbo].[uspARPostPayment]
			@batchId = NULL,
			@post = 1,
			@recap = 0,
			@param = @intPaymentId,
			@userId = @intUserId,
			@beginDate = NULL,
			@endDate = NULL,
			@beginTransaction = NULL,
			@endTransaction = NULL,
			@exclude = NULL,
			@raiseError = 1,
			@bankAccountId = NULL

	SET @intPaymentIdNew = @intPaymentId
	SELECT @strPaymentIdNew = strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentId
	--Set the Card Info Id and Process Credit Card
	UPDATE tblARPayment 
	SET intEntityCardInfoId = @intEntityCardInfoId
	  , ysnProcessCreditCard = 1 
	  , intCurrentStatus = 5
	WHERE intPaymentId = @intPaymentId

	GOTO Exit_Routine
END

--================================================================
--   DELETE
--================================================================
IF @strAction = 'Delete'
BEGIN
	DELETE FROM tblARPayment WHERE intPaymentId = @intPaymentId
	SET @intPaymentIdNew = @intPaymentId

	GOTO Exit_Routine
END

Exit_Routine: