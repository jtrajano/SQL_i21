CREATE PROCEDURE [dbo].[uspARPOSCreateNegativeCashReceipts]
	 @intInvoiceId			INT
	, @intUserId			INT
	, @intCompanyLocationId INT
	, @intNewTransactionId	INT			  = NULL OUTPUT
	, @strErrorMessage		NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN

	DECLARE @EntriesForPayment		PaymentIntegrationStagingTable
	DECLARE	@tblTaxEntries			LineItemTaxDetailStagingTable

	DECLARE 
		--payment headers
			 @strReceivePaymentType	NVARCHAR(20) = 'Cash Receipts'
			,@intPaymentMethodId	INT = 10 --CASH
			,@dblAmountPaid			NUMERIC(18,6)
			,@strNotes				NVARCHAR(20) = 'POS Return'
			,@intEntityCustomerId	INT
			,@intCurrencyId			INT

			,@intAccountId			INT
			,@intBankAccountId		INT
			,@strInvoiceNumber		NVARCHAR(50)
			,@ysnPosted				BIT
			,@strTransactionType	NVARCHAR(50)
			,@strTransactionNumber	NVARCHAR(50)
			,@dblDiscount			NUMERIC(18,6)
			,@dblBaseDiscount		NUMERIC(18,6)
			,@dblDiscountAvailable	NUMERIC(18,6)
			,@dblBaseDiscountAvailable NUMERIC(18,6)
			,@intTermId				INT
			,@dblInvoiceTotal		NUMERIC(18,6)
			

			INSERT INTO @EntriesForPayment (
				 intId
				,strSourceTransaction
				,intSourceId
				,strSourceId
				,intEntityCustomerId
				,intCompanyLocationId
				,intCurrencyId
				,dtmDatePaid
				,intPaymentMethodId
				,strPaymentMethod
				,dblAmountPaid
				,intEntityId
				,intInvoiceId
				,strTransactionType
				,strTransactionNumber
				,intTermId
				,intInvoiceAccountId
				,dblInvoiceTotal
				,dblBaseInvoiceTotal
				,dblPayment
				,strInvoiceReportNumber
				,intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId
				,dblCurrencyExchangeRate
				,ysnPost
				,intBankAccountId
				,strNotes
			)
			SELECT intId						= IFP.intInvoiceId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= GETDATE()
				,intPaymentMethodId				= 10
				,strPaymentMethod				= 'Cash'
				,dblAmountPaid					= IFP.dblInvoiceTotal * -1
				,intEntityId					= @intUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal * -1
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal * -1
				,dblPayment						= IFP.dblInvoiceTotal * -1
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,intCurrencyExchangeRateTypeId	= IFP.intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId		= IFP.intCurrencyExchangeRateId
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
				,1
				,intBankAccountId				= BA.intBankAccountId
				,strNotes						= @strNotes
			FROM vyuARInvoicesForPaymentIntegration IFP
			INNER JOIN tblSMCompanyLocation CL ON IFP.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			WHERE IFP.intInvoiceId = @intInvoiceId

			SELECT
				@strTransactionType = strTransactionType
				,@ysnPosted			= ysnPost
				,@intAccountId		= intInvoiceAccountId
				,@intBankAccountId	= intBankAccountId
			FROM @EntriesForPayment

--VALIDATIONS
IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'User Id is required when creating cash receipts.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@strTransactionType, '') <> 'Credit Memo'
	BEGIN
		SET @strErrorMessage = 'Only credit memo is allowed to create negative cash receipts'
		RAISERROR(@strErrorMessage, 16, 1)  
		RETURN 0;
	END

IF ISNULL(@ysnPosted, 0) = 0
	BEGIN
		SET @strErrorMessage = ISNULL(@strInvoiceNumber, '') + ' is not yet Posted.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@intAccountId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'Default AP Account was not set in Company Location.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END
END


IF((SELECT TOP 1 1 FROM @EntriesForPayment) = 1)
BEGIN
	EXEC [dbo].[uspARProcessPayments] @PaymentEntries	= @EntriesForPayment
											, @UserId			= 1
											, @GroupingOption	= 5
											, @RaiseError		= 1
											, @ErrorMessage		= @strErrorMessage OUTPUT

	--Refresh tblCMUndepositedFunds
	--Insert negative cash receipt to tblCMUndepositedFund
	EXEC uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId = @intBankAccountId, @intUserId = @intUserId
END
ELSE
BEGIN
	SET @strErrorMessage = 'Error processing  return of ' + @strInvoiceNumber
	RAISERROR(@strErrorMessage, 16, 1) 
	RETURN 0;
END

