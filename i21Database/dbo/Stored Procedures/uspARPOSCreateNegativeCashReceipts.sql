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
			

--select credit memo created
	SELECT
		 @intAccountId				= intAccountId
		,@intEntityCustomerId		= intEntityCustomerId
		,@intCurrencyId				= intCurrencyId
		,@strInvoiceNumber			= strTransactionNumber
		,@strTransactionType		= strTransactionType
		,@dblAmountPaid				= dblInvoiceTotal
		,@dblDiscount				= dblDiscount
		,@dblBaseDiscount			= dblBaseDiscount
		,@dblDiscountAvailable		= dblDiscountAvailable
		,@dblBaseDiscountAvailable	= dblBaseDiscountAvailable
		,@ysnPosted					= ysnPosted
		,@intTermId					= intTermId
		,@dblInvoiceTotal			= dblInvoiceTotal
	FROM vyuARInvoicesForPaymentIntegration
	WHERE intInvoiceId = @intInvoiceId

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

INSERT INTO @EntriesForPayment
(
	 intId
	,strReceivePaymentType
	,strSourceId
	,strSourceTransaction
	,intEntityCustomerId
	,intCompanyLocationId
	,intCurrencyId
	,dtmDatePaid
	,intPaymentMethodId
	,strPaymentMethod
	,dblAmountPaid
	,strNotes
	,intAccountId
	,ysnPost
	,dblDiscount
	,dblBaseDiscount
	,dblDiscountAvailable
	,dblBaseDiscountAvailable
	,intInvoiceId
	,intEntityId

	,intTermId
	,dblInvoiceTotal
	,dblBaseInvoiceTotal
	,dblPayment
)
VALUES
(
	@intInvoiceId				--intId
	,@strReceivePaymentType		--strReceivePaymentType
	,@strInvoiceNumber			--strSourceId
	,'Invoice'					--strSourceTransaction
	,@intEntityCustomerId		--intEntityCustomerId
	,@intCompanyLocationId		--intCompanyLocationId
	,@intCurrencyId				--intCurrencyId
	,GETDATE()					--dtmDatePaid
	,@intPaymentMethodId		--intPaymentMethodId
	,'Cash'						--strPaymentMethod
	,@dblAmountPaid * -1		--dblAmountPaid
	,@strNotes					--strNotes
	,@intAccountId				--intAccountId
	,1							--ysnPost
	,@dblDiscount				--dblDiscount
	,@dblBaseDiscount			--dblBaseDiscount
	,@dblDiscountAvailable		--dblDiscountAvailable
	,@dblBaseDiscountAvailable	--dblBaseDiscountAvailable
	,@intInvoiceId				--intInvoiceId
	,@intUserId					--intEntityId
	,@intTermId					--intTermId
	,@dblInvoiceTotal			--dblInvoiceTotal
	,@dblInvoiceTotal			--dblBaseInvoiceTotal
	,@dblAmountPaid * -1			--dblAmountId
)
DECLARE @COUNT INT
SELECT COUNT(*) 
IF((SELECT TOP 1 1 FROM @EntriesForPayment) = 1)
BEGIN
	EXEC uspARProcessPayments @PaymentEntries = @EntriesForPayment, @UserId = @intUserId,@GroupingOption =11, @RaiseError = 1, @ErrorMessage = @strErrorMessage OUT
END
ELSE
BEGIN
	SET @strErrorMessage = 'There is no Invoice to be returned'
	RAISERROR(@strErrorMessage, 16, 1) 
	RETURN 0;
END

