CREATE PROCEDURE [dbo].[uspARAutoApplyPrepaids]
	@tblInvoiceIds	Id	READONLY
AS

DECLARE @tblPayments			Id
DECLARE @ysnAutoApplyPrepaids	BIT = 0
	  , @intPaymentMethodId		INT = NULL
	  , @intDefaultCurrencyId	INT = NULL
	  , @strPaymentMethod		NVARCHAR(50)

DECLARE @tblPrepaids TABLE (
	intInvoiceId	INT
  , dblAmountDue	NUMERIC(18, 6)
  , dtmPostDate		DATETIME
)

DECLARE @tblPrepaidsWithContract TABLE (
	intInvoiceId	INT
  , dblAmountDue	NUMERIC(18, 6)
  , dtmPostDate		DATETIME
)

DECLARE @tblInvoices TABLE (
	intInvoiceId				INT
  , intEntityCustomerId			INT
  , intCurrencyId				INT
  , intCompanyLocationId		INT
  , intEntityUserId				INT
  , dblInvoiceTotal				NUMERIC(18, 6)
  , dblDiscountAvailable		NUMERIC(18, 6)
  ,	dtmPostDate					DATETIME
)

SET @intPaymentMethodId = (SELECT TOP 1 intPaymentMethodID FROM dbo.tblSMPaymentMethod WHERE strPaymentMethod = 'Manual Credit Card')
SET @strPaymentMethod = (SELECT TOP 1 strPaymentMethod FROM dbo.tblSMPaymentMethod WHERE strPaymentMethod = 'Manual Credit Card')
SET @ysnAutoApplyPrepaids = ISNULL((SELECT TOP 1 ysnAutoApplyPrepaids FROM dbo.tblARCompanyPreference WITH (NOLOCK)), 0)
SET @intDefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0)

IF @ysnAutoApplyPrepaids = 1 AND EXISTS (SELECT TOP 1 NULL FROM @tblInvoiceIds)
	BEGIN
		--GET POSTED INVOICES
		INSERT INTO @tblInvoices
		SELECT intInvoiceId
			 , intEntityCustomerId
			 , intCurrencyId
			 , intCompanyLocationId
			 , intEntityId
			 , dblInvoiceTotal
			 , dblDiscountAvailable
			 , dtmPostDate
		FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
		INNER JOIN @tblInvoiceIds IDS ON IDS.intId = INVOICE.intInvoiceId
		WHERE INVOICE.ysnPosted = 1
		  AND INVOICE.ysnCancelled = 0
		  AND INVOICE.ysnPaid = 0
		  AND INVOICE.strTransactionType IN ('Invoice', 'Debit Memo')
		
		WHILE EXISTS (SELECT TOP 1 NULL FROM @tblInvoices)
			BEGIN
				--CLEAR PREPAIDS TEMP TABLE
				DELETE FROM @tblPrepaids
				DELETE FROM @tblPrepaidsWithContract

				DECLARE @intInvoiceId			INT = NULL
					  , @intEntityCustomerId	INT = NULL
					  , @intCurrencyId			INT = NULL
					  , @intCompanyLocationId	INT = NULL
					  , @intEntityUserId		INT = NULL
					  , @intPaymentId			INT = NULL
					  , @dblInvoiceTotal		NUMERIC(18, 6) = 0
					  , @dblDiscountAvailable	NUMERIC(18, 6) = 0
					  , @dblAmountDue			NUMERIC(18, 6) = 0
					  , @dblPayment				NUMERIC(18, 6) = 0
					  , @dtmPostDate			DATETIME = NULL
					  , @ysnHasContract			BIT = 0

				SELECT TOP 1 @intInvoiceId			= intInvoiceId 
						   , @intEntityCustomerId	= intEntityCustomerId
						   , @intCurrencyId			= intCurrencyId
						   , @intCompanyLocationId	= intCompanyLocationId
						   , @intEntityUserId		= intEntityUserId						   
						   , @dblInvoiceTotal		= dblInvoiceTotal
						   , @dblAmountDue			= dblInvoiceTotal
						   , @dblDiscountAvailable	= dblDiscountAvailable
						   , @dtmPostDate			= dtmPostDate
				FROM @tblInvoices ORDER BY intInvoiceId

				IF EXISTS (SELECT TOP 1 NULL FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND ISNULL(intContractDetailId, 0) <> 0)
					BEGIN
						SET @ysnHasContract = 1
					END

				--GET AVAILABLE CREDITS OF CUSTOMER WITHOUT CONTRACTS
				INSERT INTO @tblPrepaids
				SELECT intInvoiceId
					 , dblAmountDue
					 , dtmPostDate
				FROM dbo.tblARInvoice CREDITS WITH (NOLOCK)
				OUTER APPLY (
					SELECT intContractCount = COUNT(*) 
					FROM dbo.tblARInvoiceDetail ID
					WHERE CREDITS.intInvoiceId = ID.intInvoiceId
					  AND ISNULL(ID.intContractDetailId, 0) <> 0
				) CD
				WHERE CREDITS.ysnPosted = 1
				  AND CREDITS.ysnCancelled = 0
				  AND CREDITS.ysnPaid = 0
				  AND CREDITS.dblAmountDue > 0
				  AND CREDITS.strTransactionType IN ('Customer Prepayment', 'Credit Memo', 'Overpayment')
				  AND CREDITS.intEntityCustomerId = @intEntityCustomerId
				  AND CREDITS.dtmPostDate <= @dtmPostDate
				  AND ISNULL(CD.intContractCount, 0) = 0
				ORDER BY CREDITS.dtmPostDate

				--GET AVAILABLE CREDITS OF CUSTOMER WITH CONTRACTS
				INSERT INTO @tblPrepaidsWithContract
				SELECT intInvoiceId
					 , dblAmountDue
					 , dtmPostDate
				FROM dbo.tblARInvoice CREDITS WITH (NOLOCK)
				CROSS APPLY (
					SELECT intContractCount = COUNT(*) 
					FROM dbo.tblARInvoiceDetail ID
					WHERE CREDITS.intInvoiceId = ID.intInvoiceId
					  AND ID.intContractDetailId IN (SELECT intContractDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
				) CD
				WHERE CREDITS.ysnPosted = 1
				  AND CREDITS.ysnCancelled = 0
				  AND CREDITS.ysnPaid = 0
				  AND CREDITS.dblAmountDue > 0
				  AND CREDITS.strTransactionType IN ('Customer Prepayment', 'Credit Memo', 'Overpayment')
				  AND CREDITS.intEntityCustomerId = @intEntityCustomerId
				  AND CREDITS.dtmPostDate <= @dtmPostDate
				  AND ISNULL(CD.intContractCount, 0) > 0
				ORDER BY CREDITS.dtmPostDate

				--INSERT PAYMENT HEADER
				IF (EXISTS (SELECT TOP 1 NULL FROM @tblPrepaids) OR EXISTS (SELECT TOP 1 NULL FROM @tblPrepaidsWithContract))
					BEGIN
						INSERT INTO [tblARPayment]
							([intEntityCustomerId]
							,[intCurrencyId]
							,[dtmDatePaid]
							,[intAccountId]
							,[intBankAccountId]
							,[intPaymentMethodId]
							,[intLocationId]
							,[dblAmountPaid]
							,[dblBaseAmountPaid]
							,[dblUnappliedAmount]
							,[dblBaseUnappliedAmount]
							,[dblOverpayment]
							,[dblBaseOverpayment]
							,[dblBalance]
							,[strRecordNumber]
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
							 [intEntityCustomerId]			= @intEntityCustomerId
							,[intCurrencyId]				= ISNULL(@intCurrencyId, @intDefaultCurrencyId)
							,[dtmDatePaid]					= @dtmPostDate
							,[intAccountId]					= NULL
							,[intBankAccountId]				= NULL
							,[intPaymentMethodId]			= @intPaymentMethodId
							,[intLocationId]				= @intCompanyLocationId
							,[dblAmountPaid]				= 0.000000
							,[dblBaseAmountPaid]			= 0.000000
							,[dblUnappliedAmount]			= 0.000000
							,[dblBaseUnappliedAmount]		= 0.000000
							,[dblOverpayment]				= 0.000000
							,[dblBaseOverpayment]			= 0.000000
							,[dblBalance]					= 0.000000
							,[strRecordNumber]				= NULL
							,[strPaymentInfo]				= NULL
							,[strNotes]						= 'Auto Apply Prepaids'
							,[ysnApplytoBudget]				= 0
							,[ysnApplyOnAccount]			= 0
							,[intEntityId]					= @intEntityUserId
							,[ysnInvoicePrepayment]			= 0
							,[strPaymentMethod]				= @strPaymentMethod
							,[intWriteOffAccountId]			= NULL
							,[intConcurrencyId]				= 0		
						FROM	
							tblARCustomer ARC	
						WHERE ARC.[intEntityId] = @intEntityCustomerId
	
						SET @intPaymentId = SCOPE_IDENTITY()
					END

				--INSERT PAYMENT DETAILS WITH CONTRACTS
				IF @ysnHasContract = 1 AND EXISTS (SELECT TOP 1 NULL FROM @tblPrepaidsWithContract) AND ISNULL(@intPaymentId, 0) <> 0
					BEGIN
						WHILE EXISTS (SELECT TOP 1 NULL FROM @tblPrepaidsWithContract)
							BEGIN
								DECLARE @intPrepaidContractInvoiceId	INT = NULL
									  , @dblCreditsContract				NUMERIC(18, 6) = 0
									  , @dblAmountToApplyContract		NUMERIC(18, 6) = 0

								SELECT TOP 1 @intPrepaidContractInvoiceId	= intInvoiceId
										   , @dblCreditsContract			= dblAmountDue 
								FROM @tblPrepaidsWithContract ORDER BY dtmPostDate

								IF (@dblAmountDue > @dblCreditsContract)
									SET @dblAmountToApplyContract = @dblCreditsContract
								ELSE IF (@dblAmountDue <= @dblCreditsContract)
									SET @dblAmountToApplyContract = @dblAmountDue

								--INSERT CREDITS IN PAYMENT DETAIL
								INSERT INTO tblARPaymentDetail
									([intPaymentId]
									,[intInvoiceId]
									,[strTransactionNumber]
									,[intTermId]
									,[intAccountId]
									,[dblInvoiceTotal]
									,[dblBaseInvoiceTotal]
									,[dblDiscount]
									,[dblBaseDiscount]
									,[dblDiscountAvailable]
									,[dblBaseDiscountAvailable]
									,[dblAmountDue]
									,[dblBaseAmountDue]
									,[dblPayment]
									,[dblBasePayment]
									,[dblCurrencyExchangeRate]
									,[intConcurrencyId])
								SELECT [intPaymentId]			= @intPaymentId
									,[intInvoiceId]				= intInvoiceId
									,[strTransactionNumber]		= strInvoiceNumber
									,[intTermId]				= intTermId
									,[intAccountId]				= intAccountId
									,[dblInvoiceTotal]			= dblInvoiceTotal * -1
									,[dblBaseInvoiceTotal]		= dblBaseInvoiceTotal * -1
									,[dblDiscount]				= 0.00
									,[dblBaseDiscount]			= 0.00
									,[dblDiscountAvailable]		= 0.00
									,[dblBaseDiscountAvailable] = 0.00
									,[dblAmountDue]				= (dblAmountDue - @dblAmountToApplyContract) * -1
									,[dblBaseAmountDue]			= (dblAmountDue - @dblAmountToApplyContract) * -1
									,[dblPayment]				= @dblAmountToApplyContract * -1
									,[dblBasePayment]			= @dblAmountToApplyContract * -1
									,[dblCurrencyExchangeRate]	= 1
									,[intConcurrencyId]			= 1
								FROM dbo.tblARInvoice
								WHERE intInvoiceId = @intPrepaidContractInvoiceId
								
								SET @dblAmountDue = @dblAmountDue - @dblAmountToApplyContract
								SET @dblPayment	= @dblPayment + @dblAmountToApplyContract

								DELETE FROM @tblPrepaidsWithContract WHERE intInvoiceId = @intPrepaidContractInvoiceId

								IF @dblAmountDue = 0
									BREAK
							END
					END

				--INSERT PAYMENT DETAILS WITHOUT CONTRACTS
				IF EXISTS (SELECT TOP 1 NULL FROM @tblPrepaids) AND @dblAmountDue > 0 AND ISNULL(@intPaymentId, 0) <> 0
					BEGIN						
						WHILE EXISTS (SELECT TOP 1 NULL FROM @tblPrepaids)
							BEGIN
								DECLARE @intPrepaidInvoiceId	INT = NULL
									  , @dblCredits				NUMERIC(18, 6) = 0
									  , @dblAmountToApply		NUMERIC(18, 6) = 0

								SELECT TOP 1 @intPrepaidInvoiceId	= intInvoiceId
											, @dblCredits			= dblAmountDue 
								FROM @tblPrepaids ORDER BY dtmPostDate

								IF (@dblAmountDue > @dblCredits)
									SET @dblAmountToApply = @dblCredits
								ELSE IF (@dblAmountDue <= @dblCredits)
									SET @dblAmountToApply = @dblAmountDue

								--INSERT CREDITS IN PAYMENT DETAIL
								INSERT INTO tblARPaymentDetail
									([intPaymentId]
									,[intInvoiceId]
									,[strTransactionNumber]
									,[intTermId]
									,[intAccountId]
									,[dblInvoiceTotal]
									,[dblBaseInvoiceTotal]
									,[dblDiscount]
									,[dblBaseDiscount]
									,[dblDiscountAvailable]
									,[dblBaseDiscountAvailable]
									,[dblAmountDue]
									,[dblBaseAmountDue]
									,[dblPayment]
									,[dblBasePayment]
									,[dblCurrencyExchangeRate]
									,[intConcurrencyId])
								SELECT [intPaymentId]			= @intPaymentId
									,[intInvoiceId]				= intInvoiceId
									,[strTransactionNumber]		= strInvoiceNumber
									,[intTermId]				= intTermId
									,[intAccountId]				= intAccountId
									,[dblInvoiceTotal]			= dblInvoiceTotal * -1
									,[dblBaseInvoiceTotal]		= dblBaseInvoiceTotal * -1
									,[dblDiscount]				= 0.00
									,[dblBaseDiscount]			= 0.00
									,[dblDiscountAvailable]		= 0.00
									,[dblBaseDiscountAvailable] = 0.00
									,[dblAmountDue]				= (dblAmountDue - @dblAmountToApply) * -1
									,[dblBaseAmountDue]			= (dblAmountDue - @dblAmountToApply) * -1
									,[dblPayment]				= @dblAmountToApply * -1
									,[dblBasePayment]			= @dblAmountToApply * -1
									,[dblCurrencyExchangeRate]	= 1
									,[intConcurrencyId]			= 1
								FROM dbo.tblARInvoice
								WHERE intInvoiceId = @intPrepaidInvoiceId
								
								SET @dblAmountDue = @dblAmountDue - @dblAmountToApply
								SET @dblPayment	= @dblPayment + @dblAmountToApply										

								DELETE FROM @tblPrepaids WHERE intInvoiceId = @intPrepaidInvoiceId

								IF @dblAmountDue = 0
									BREAK
							END						
					END

				--INSERT INVOICE IN PAYMENT DETAIL
				INSERT INTO tblARPaymentDetail
					([intPaymentId]
					,[intInvoiceId]
					,[strTransactionNumber]
					,[intTermId]
					,[intAccountId]
					,[dblInvoiceTotal]
					,[dblBaseInvoiceTotal]
					,[dblDiscount]
					,[dblBaseDiscount]
					,[dblDiscountAvailable]
					,[dblBaseDiscountAvailable]
					,[dblAmountDue]
					,[dblBaseAmountDue]
					,[dblPayment]
					,[dblBasePayment]
					,[dblCurrencyExchangeRate]
					,[intConcurrencyId])
				SELECT [intPaymentId]			= @intPaymentId
					,[intInvoiceId]				= intInvoiceId
					,[strTransactionNumber]		= strInvoiceNumber
					,[intTermId]				= intTermId
					,[intAccountId]				= intAccountId
					,[dblInvoiceTotal]			= dblInvoiceTotal
					,[dblBaseInvoiceTotal]		= dblBaseInvoiceTotal
					,[dblDiscount]				= 0.00
					,[dblBaseDiscount]			= 0.00
					,[dblDiscountAvailable]		= dblDiscountAvailable
					,[dblBaseDiscountAvailable] = dblBaseDiscountAvailable
					,[dblAmountDue]				= @dblAmountDue
					,[dblBaseAmountDue]			= @dblAmountDue
					,[dblPayment]				= @dblPayment
					,[dblBasePayment]			= @dblPayment
					,[dblCurrencyExchangeRate]	= 1
					,[intConcurrencyId]			= 1
				FROM dbo.tblARInvoice
				WHERE intInvoiceId = @intInvoiceId

				--INSERT PAYMENTS TO POST
				INSERT INTO @tblPayments
				SELECT @intPaymentId

				DELETE FROM @tblInvoices WHERE intInvoiceId = @intInvoiceId
			END
		
		--POST PAYMENTS GENERATED
		IF EXISTS (SELECT TOP 1 NULL FROM @tblPayments)
			BEGIN
				DECLARE @intPaymentIds NVARCHAR(MAX)

				SELECT @intPaymentIds = COALESCE(@intPaymentIds + ', ', '') + RTRIM(LTRIM(intId)) FROM @tblPayments

				EXEC dbo.uspARPostPayment @post = 1, @recap = 0, @param = @intPaymentIds
			END
	END