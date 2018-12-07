CREATE PROCEDURE [dbo].[uspARPOSCreateNegativeCashReceipts]
	 @intInvoiceId			INT
	, @intUserId			INT
	, @intCompanyLocationId INT
	, @intPaymentMethodID	INT			  = NULL
	, @intNewTransactionId	INT			  = NULL OUTPUT
	, @strErrorMessage		NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN

	DECLARE @EntriesForPayment		PaymentIntegrationStagingTable
	DECLARE	@tblTaxEntries			LineItemTaxDetailStagingTable

	DECLARE 
		--payment headers
			 @strReceivePaymentType	NVARCHAR(20) = 'Cash Receipts'
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
				,strPaymentInfo	
				,intBankAccountId
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
				,strNotes
			)
			SELECT intId						= POSPAYMENT.intPOSPaymentId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= GETDATE()
				,intPaymentMethodId				= PM.intPaymentMethodID
				,strPaymentMethod				= PM.strPaymentMethod
				,strPaymentInfo					= CASE WHEN POSPAYMENT.strPaymentMethod IN ('Check' ,'Debit Card', 'Manual Credit Card') THEN strReferenceNo ELSE NULL END
				,intBankAccountId				= BA.intBankAccountId
				,dblAmountPaid					= ABS(ISNULL(POSPAYMENT.dblAmount,0)) * -1
				,intEntityId					= @intUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal * -1
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal * -1
				,dblPayment						= ABS(ISNULL(POSPAYMENT.dblAmount,0)) * -1
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,intCurrencyExchangeRateTypeId	= IFP.intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId		= IFP.intCurrencyExchangeRateId
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
				,1
				,strNotes						= @strNotes
			FROM #POSRETURNPAYMENTS POSPAYMENT
			INNER JOIN tblARPOS POS ON POSPAYMENT.intPOSId = POS.intPOSId
			INNER JOIN vyuARInvoicesForPayment IFP ON POS.intInvoiceId = IFP.intInvoiceId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 intPaymentMethodID
						   , strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE ((POSPAYMENT.strPaymentMethod = 'Debit Card' AND strPaymentMethod = 'Debit Card') OR (POSPAYMENT.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENT.strPaymentMethod))
			) PM
			WHERE IFP.ysnExcludeForPayment = 0
			AND IFP.ysnPosted = 1
			AND IFP.ysnPaid = 0
			AND IFP.intInvoiceId = @intInvoiceId

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
END
ELSE
BEGIN
	SET @strErrorMessage = 'Error processing  return of ' + @strInvoiceNumber
	RAISERROR(@strErrorMessage, 16, 1) 
	RETURN 0;
END