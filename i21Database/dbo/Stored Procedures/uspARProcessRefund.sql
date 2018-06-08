CREATE PROCEDURE [dbo].[uspARProcessRefund]
	  @intInvoiceId			INT
	, @intUserId			INT
	, @intNewTransactionId	INT			  = NULL OUTPUT
	, @strErrorMessage		NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @tblInvoiceEntries		InvoiceIntegrationStagingTable
DECLARE	@tblTaxEntries			LineItemTaxDetailStagingTable
DECLARE @tblInvoicesCreated		Id
DECLARE @dblZeroDecimal			NUMERIC(18,6)	= 0
	  , @dblInvoiceTotal		NUMERIC(18,6)	= 0
	  , @dblAmountDue			NUMERIC(18,6)	= 0
	  , @dtmDateOnly			DATETIME		= CAST(GETDATE() AS DATE)
	  , @strTransactionType		NVARCHAR(100)	= NULL
	  , @strInvoiceNumber		NVARCHAR(100)	= NULL
	  , @strCreatedInvoices		NVARCHAR(100)	= NULL
	  , @ysnPosted				BIT				= 0
	  , @ysnRefundProcessed		BIT				= 0
	  , @ysnPaid				BIT				= 0
	  , @ysnSuccess				BIT				= 0
	  , @intAccountId			INT				= NULL
	  , @intCompanyLocationId	INT				= NULL
	  , @intInvoiceDetailId		INT				= NULL
	  , @intEntityCustomerId	INT				= NULL
	  , @intNewInvoiceId		INT				= NULL

SELECT @strTransactionType		= strTransactionType
	 , @strInvoiceNumber		= strInvoiceNumber
	 , @dblInvoiceTotal			= dblInvoiceTotal
	 , @dblAmountDue			= dblAmountDue
	 , @ysnPosted				= ysnPosted
	 , @ysnRefundProcessed		= ysnRefundProcessed
	 , @ysnPaid					= ysnPaid
	 , @intCompanyLocationId	= intCompanyLocationId
	 , @intInvoiceDetailId		= DETAIL.intInvoiceDetailId
	 , @intEntityCustomerId		= intEntityCustomerId
FROM dbo.tblARInvoice I WITH (NOLOCK)
OUTER APPLY (
	SELECT TOP 1 intInvoiceDetailId
	FROM tblARInvoiceDetail ID
	WHERE ID.intInvoiceId = I.intInvoiceId
) DETAIL
WHERE I.intInvoiceId = @intInvoiceId

--VALIDATIONS
IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'User Id is required when processing Refund.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@strTransactionType, '') <> 'Credit Memo' AND ISNULL(@strTransactionType, '') <> 'Customer Prepayment'
	BEGIN
		SET @strErrorMessage = ISNULL(@strTransactionType, '') + ' is not valid for processing Refund. Only Credit Memo or Customer Prepayment is allowed.'
		RAISERROR(@strErrorMessage, 16, 1)  
		RETURN 0;
	END

IF ISNULL(@ysnPosted, 0) = 0
	BEGIN
		SET @strErrorMessage = ISNULL(@strInvoiceNumber, '') + ' is not yet Posted.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@ysnRefundProcessed, 0) = 1
	BEGIN
		SET @strErrorMessage = 'This transaction was already Processed to Refund.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@ysnPaid, 0) = 1
	BEGIN
		SET @strErrorMessage = 'This transaction was already Paid.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF ISNULL(@intCompanyLocationId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'Company Location is required when Processing Refund.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

EXEC dbo.uspARGetDefaultAccount @strTransactionType		= 'Cash Refund'
							  , @intCompanyLocationId	= @intCompanyLocationId
							  , @intAccountId			= @intAccountId OUT

IF ISNULL(@intAccountId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'Default AP Account was not set in Company Location.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

IF NOT EXISTS (SELECT TOP 1 NULL FROM vyuEMEntityType WHERE Customer = 1 AND Vendor = 1 AND intEntityId = @intEntityCustomerId)
	BEGIN
		SET @strErrorMessage = 'Customer should be a vendor too.'
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END

--CREATE CASH REFUND
INSERT INTO @tblInvoiceEntries (
	 [strSourceTransaction]
	,[strTransactionType]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[intAccountId]
	,[dtmDate]
	,[dtmPostDate]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[ysnRecomputeTax]
)
SELECT
	 [strSourceTransaction]				= 'Direct'
	,[strTransactionType]				= 'Cash Refund'
	,[intSourceId]						= I.intInvoiceId
	,[strSourceId]						= I.strInvoiceNumber
	,[intEntityCustomerId]				= I.intEntityCustomerId
	,[intCompanyLocationId]				= I.intCompanyLocationId
	,[intCurrencyId]					= I.intCurrencyId
	,[intAccountId]						= @intAccountId	
	,[dtmDate]							= @dtmDateOnly
	,[dtmPostDate]						= @dtmDateOnly
	,[intEntityId]						= @intUserId
	,[ysnPost]							= 0
	,[intItemId]						= NULL
	,[ysnInventory]						= 0
	,[strItemDescription]				= 'Cash Refund from: ' + I.strInvoiceNumber
	,[intOrderUOMId]					= NULL
	,[dblQtyOrdered]					= NULL
	,[intItemUOMId]						= NULL
	,[dblQtyShipped]					= 1
	,[dblPrice]							= I.dblAmountDue
	,[ysnRefreshPrice]					= 0
	,[ysnRecomputeTax]					= 0
FROM dbo.tblARInvoice I
WHERE I.intInvoiceId = @intInvoiceId

EXEC dbo.[uspARProcessInvoices] @InvoiceEntries		= @tblInvoiceEntries
							  , @LineItemTaxEntries	= @tblTaxEntries
							  , @UserId				= @intUserId
							  , @GroupingOption		= 1	
							  , @RaiseError			= 0
							  , @ErrorMessage		= @strErrorMessage OUT
							  , @CreatedIvoices		= @strCreatedInvoices OUT

--INSERT CREDITMEMO/PREPAIDS TAB AND POST
IF ISNULL(@strCreatedInvoices, '') <> ''
	BEGIN
		INSERT INTO @tblInvoicesCreated
		SELECT intID FROM fnGetRowsFromDelimitedValues(@strCreatedInvoices)

		SELECT TOP 1 @intNewInvoiceId = intId FROM @tblInvoicesCreated
		--SET @intNewTransactionId = @intNewInvoiceId

		INSERT INTO tblARPrepaidAndCredit (
			 intInvoiceId
		   , intPrepaymentId
		   , intPrepaymentDetailId
		   , dblAppliedInvoiceDetailAmount
		   , dblBaseAppliedInvoiceDetailAmount
		   , ysnApplied
		   , intRowNumber
		)
		SELECT intInvoiceId						= @intNewInvoiceId
		   , intPrepaymentId					= @intInvoiceId
		   , intPrepaymentDetailId				= @intInvoiceDetailId
		   , dblAppliedInvoiceDetailAmount		= @dblAmountDue
		   , dblBaseAppliedInvoiceDetailAmount	= @dblAmountDue
		   , ysnApplied							= 1
		   , intRowNumber						= 1
	
		EXEC [dbo].[uspARPostInvoice] @post				= 1
									, @recap			= 0
									, @param			= @strCreatedInvoices
									, @userId			= @intUserId
									, @raiseError		= 1
									, @success			= @ysnSuccess OUT

		IF @ysnSuccess = 1
			BEGIN
				DECLARE @tblPaymentDetail		PaymentDetailStaging

				INSERT INTO @tblPaymentDetail (
					  intAccountId
					, intInvoiceId
					, dblDiscount
					, dblAmountDue
					, dblPayment
					, dblInterest
					, dblTotal
					, dblWithheld
				)
				SELECT intAccountId	= intAccountId
					, intInvoiceId	= intInvoiceId
					, dblDiscount	= 0.00000
					, dblAmountDue	= 0.00000
					, dblPayment	= dblInvoiceTotal
					, dblInterest	= 0.00000
					, dblTotal		= dblInvoiceTotal
					, dblWithheld	= 0.00000
				FROM tblARInvoice 
				WHERE intInvoiceId = @intNewInvoiceId

				EXEC [dbo].[uspAPCreatePaymentData] @userId				= @intUserId
												  , @notes				= 'Cash Refund'
												  , @payment			= 0.000000
												  , @datePaid			= @dtmDateOnly
												  , @paymentDetail		= @tblPaymentDetail
												  , @createdPaymentId	= @intNewTransactionId OUT
				
				IF ISNULL(@intNewTransactionId, 0) = 0
					BEGIN
						SET @strErrorMessage = 'Error in creating Pay Voucher Transaction.'
						RAISERROR(@strErrorMessage, 16, 1) 
						RETURN 0;
					END
			END
		
		--UPDATE YSNPROCESSED
		UPDATE tblARInvoice
		SET ysnRefundProcessed = 1
		WHERE intInvoiceId = @intInvoiceId
	END
ELSE IF ISNULL(@strErrorMessage, '') <> ''
	BEGIN
		RAISERROR(@strErrorMessage, 16, 1) 
		RETURN 0;
	END