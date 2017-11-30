CREATE PROCEDURE [dbo].[uspARApplyCreditsToOpenInvoices]
	  @strCustomers					NVARCHAR(MAX) = NULL
	, @strApplyToBudgetCustomer	    NVARCHAR(100) = 'Yes'
	, @dtmThruDate					DATETIME
	, @ysnApplyPrepaids				BIT = 0
	, @ysnOmitACHPayments			BIT = 1
AS

DECLARE @tblCustomerWithCredits TABLE (intEntityCustomerId	INT
									  , strCustomerName		NVARCHAR(100)
									  , dblARBalance		NUMERIC(18, 6))

DECLARE @tblCredits TABLE (intInvoiceId			INT
						 , intEntityCustomerId	INT
						 , intTermId			INT
						 , intAccountId			INT
						 , strTransactionNumber	NVARCHAR(50)
						 , strTransactionType	NVARCHAR(50)
						 , strCustomerName		NVARCHAR(100)
						 , dblInvoiceTotal		NUMERIC(18, 6)
						 , dblPayment			NUMERIC(18, 6)
						 , dblAmountDue			NUMERIC(18, 6)
						 , ysnPaid				BIT)

DECLARE @tblOpenInvoices TABLE (intInvoiceId			INT
						 , intEntityCustomerId	INT
						 , intTermId			INT
						 , intAccountId			INT
						 , strTransactionNumber	NVARCHAR(50)
						 , strTransactionType	NVARCHAR(50)
						 , strCustomerName		NVARCHAR(100)
						 , dblInvoiceTotal		NUMERIC(18, 6)
						 , dblPayment			NUMERIC(18, 6)
						 , dblAmountDue			NUMERIC(18, 6)
						 , ysnPaid				BIT)

DECLARE @intCompanyLocationId	INT = NULL
      , @intCurrencyId			INT = NULL
	  , @intPaymentMethodId		INT = NULL
	  , @intUndepositedFundsId  INT = NULL
	  , @intEntityId			INT = NULL
	  , @strCompanyLocation     NVARCHAR(50)
	  , @strPaymentMethod		NVARCHAR(50) = 'Debit memos and Payments'

SET @intCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @intPaymentMethodId = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = @strPaymentMethod)

SELECT TOP 1 @intEntityId = intEntityId
		   , @intCompanyLocationId = intCompanyLocationId 
FROM tblSMUserSecurity 
WHERE strUserName = 'irelyadmin'

SELECT TOP 1 @intUndepositedFundsId = intUndepositedFundsId
		   , @strCompanyLocation = 'Undeposited Fund Account is required for : ' + strLocationName 
FROM tblSMCompanyLocation 
WHERE intCompanyLocationId = @intCompanyLocationId

IF ISNULL(@intCurrencyId, 0) = 0
	BEGIN
		RAISERROR('Default Functional Currency setup in Company Preference is required.', 16, 1)
		RETURN 0
	END

IF ISNULL(@intCompanyLocationId, 0) = 0
	BEGIN
		RAISERROR('Default Company Location setup for User: irelyadmin is required.', 16, 1)
		RETURN 0
	END

IF ISNULL(@intPaymentMethodId, 0) = 0
	BEGIN
		RAISERROR('Create Payment Method for ''Debit memos and Payments''.', 16, 1)
		RETURN 0
	END

IF ISNULL(@intUndepositedFundsId, 0) = 0
	BEGIN
		RAISERROR(@strCompanyLocation, 16, 1)
		RETURN 0
	END

INSERT INTO @tblCredits
SELECT intInvoiceId
	 , intEntityCustomerId
	 , intTermId
	 , intAccountId
	 , strTransactionNumber
	 , strTransactionType	 
	 , strCustomerName
	 , dblInvoiceTotal
	 , dblPayment
	 , dblAmountDue
	 , ysnPaid 
FROM vyuARInvoicesForPayment
WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
  AND ysnPaid = 0
  AND dblAmountDue > 0
  AND ysnExcludeForPayment = 0
  
IF NOT EXISTS(SELECT TOP 1 NULL FROM @tblCredits)
	BEGIN
		RAISERROR('There are no Credits to apply.', 16, 1)
		RETURN 0
	END

INSERT INTO @tblOpenInvoices
SELECT intInvoiceId
	 , intEntityCustomerId
	 , intTermId
	 , intAccountId
	 , strTransactionNumber
	 , strTransactionType	 
	 , strCustomerName
	 , dblInvoiceTotal
	 , dblPayment
	 , dblAmountDue
	 , ysnPaid	 
FROM vyuARInvoicesForPayment	
WHERE strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
  AND ysnPaid = 0
  AND ysnExcludeForPayment = 0

IF NOT EXISTS(SELECT TOP 1 NULL FROM @tblOpenInvoices)
	BEGIN
		RAISERROR('There are no Open Invoices to apply the credits.', 16, 1)
		RETURN 0
	END

INSERT INTO @tblCustomerWithCredits
SELECT DISTINCT P.intEntityCustomerId
			  , P.strCustomerName 
			  , C.dblARBalance
FROM @tblCredits P
	INNER JOIN (SELECT intEntityId, dblARBalance FROM tblARCustomer) C ON P.intEntityCustomerId = C.intEntityId
WHERE P.intEntityCustomerId IN (SELECT DISTINCT intEntityCustomerId FROM @tblOpenInvoices)

WHILE EXISTS (SELECT NULL FROM @tblCustomerWithCredits)
	BEGIN
		DECLARE @intEntityCustomerId INT			= NULL
			  , @dblARBalance		 NUMERIC(18, 6)	= 0
			  , @dblCreditsTotalDue	 NUMERIC(18, 6)	= 0
			  , @dblInvoiceTotalDue  NUMERIC(18, 6)	= 0
			  , @dblTotalDueCounter  NUMERIC(18, 6)	= 0
			  , @dblDifference		 NUMERIC(18,6)  = 0
			  , @intPaymentId		 INT			= NULL
			  , @intCurrentInvoiceId INT			= NULL

		SELECT TOP 1 @intEntityCustomerId = intEntityCustomerId
				   , @dblARBalance		  = dblARBalance 
		FROM @tblCustomerWithCredits

		INSERT INTO tblARPayment (
			   intEntityCustomerId
		     , intCurrencyId
			 , dtmDatePaid
			 , intAccountId
			 , intBankAccountId
			 , intPaymentMethodId
			 , intLocationId
			 , dblAmountPaid
			 , dblBaseAmountPaid
			 , dblUnappliedAmount
			 , dblBaseUnappliedAmount
			 , dblOverpayment
			 , dblBaseOverpayment
			 , dblBalance
			 , strPaymentInfo
			 , strNotes
			 , ysnApplytoBudget
			 , ysnApplyOnAccount
			 , ysnPosted
			 , ysnInvoicePrepayment
			 , ysnImportedFromOrigin
			 , ysnImportedAsPosted
			 , intEntityId
			 , intWriteOffAccountId
			 , strPaymentMethod
			 , dblTotalAR
			 , intConcurrencyId
		)
		SELECT intEntityCustomerId		= @intEntityCustomerId
		     , intCurrencyId			= @intCurrencyId
			 , dtmDatePaid				= DATEADD(DD, 0, DATEDIFF(DD, 0, GETDATE()))
			 , intAccountId				= @intUndepositedFundsId
			 , intBankAccountId			= NULL
			 , intPaymentMethodId		= @intPaymentMethodId
			 , intLocationId			= @intCompanyLocationId
			 , dblAmountPaid			= 0.00
			 , dblBaseAmountPaid		= 0.00
			 , dblUnappliedAmount		= 0.00
			 , dblBaseUnappliedAmount	= 0.00
			 , dblOverpayment			= 0.00
			 , dblBaseOverpayment		= 0.00
			 , dblBalance				= 0.00
			 , strPaymentInfo			= NULL
			 , strNotes					= 'Applied Credits'
			 , ysnApplytoBudget			= 0
			 , ysnApplyOnAccount		= 0
			 , ysnPosted				= 0
			 , ysnInvoicePrepayment		= 0
			 , ysnImportedFromOrigin	= 0
			 , ysnImportedAsPosted		= 0
			 , intEntityId				= @intEntityId
			 , intWriteOffAccountId		= NULL
			 , strPaymentMethod			= @strPaymentMethod
			 , dblARBalance				= @dblARBalance
			 , intConcurrencyId			= 1

		SET @intPaymentId = SCOPE_IDENTITY()
		
		SELECT @dblCreditsTotalDue = SUM(dblAmountDue) FROM @tblCredits WHERE intEntityCustomerId = @intEntityCustomerId
		SELECT @dblInvoiceTotalDue = SUM(dblAmountDue) FROM @tblOpenInvoices WHERE intEntityCustomerId = @intEntityCustomerId

		IF ISNULL(@dblInvoiceTotalDue, 0) > ISNULL(@dblCreditsTotalDue, 0)
			BEGIN
				--INSERT ALL CREDITS
				INSERT INTO tblARPaymentDetail (
					   intPaymentId
					 , intInvoiceId
					 , intBillId
					 , strTransactionNumber
					 , intTermId
					 , intAccountId
					 , dblInvoiceTotal
					 , dblBaseInvoiceTotal
					 , dblDiscount
					 , dblBaseDiscount
					 , dblDiscountAvailable
					 , dblBaseDiscountAvailable
					 , dblInterest
					 , dblBaseInterest
					 , dblAmountDue
					 , dblBaseAmountDue
					 , dblPayment
					 , dblBasePayment
					 , strInvoiceReportNumber
					 , intCurrencyExchangeRateTypeId
					 , intCurrencyExchangeRateId
					 , dblCurrencyExchangeRate
					 , intConcurrencyId
				)
				SELECT intPaymentId						= @intPaymentId
					 , intInvoiceId						= intInvoiceId
					 , intBillId						= NULL
					 , strTransactionNumber				= strTransactionNumber
					 , intTermId						= intTermId
					 , intAccountId						= intAccountId
					 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
					 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
					 , dblDiscount						= 0
					 , dblBaseDiscount					= 0
					 , dblDiscountAvailable				= 0
					 , dblBaseDiscountAvailable			= 0
					 , dblInterest						= 0
					 , dblBaseInterest					= 0
					 , dblAmountDue						= 0
					 , dblBaseAmountDue					= 0
					 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
					 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
					 , strInvoiceReportNumber			= NULL
					 , intCurrencyExchangeRateTypeId	= NULL
					 , intCurrencyExchangeRateId		= NULL
					 , dblCurrencyExchangeRate			= 1
					 , intConcurrencyId					= 1
				FROM @tblCredits
				WHERE intEntityCustomerId = @intEntityCustomerId

				WHILE EXISTS (SELECT NULL FROM @tblOpenInvoices WHERE intEntityCustomerId = @intEntityCustomerId)
					BEGIN
						SELECT TOP 1 @intCurrentInvoiceId = intInvoiceId
								   , @dblTotalDueCounter  = ISNULL(@dblTotalDueCounter, 0) + ISNULL(dblAmountDue, 0)
						FROM @tblOpenInvoices 
						WHERE intEntityCustomerId = @intEntityCustomerId 

						IF ISNULL(@dblCreditsTotalDue, 0) > ISNULL(@dblTotalDueCounter, 0)
							BEGIN
								INSERT INTO tblARPaymentDetail (
									   intPaymentId
									 , intInvoiceId
									 , intBillId
									 , strTransactionNumber
									 , intTermId
									 , intAccountId
									 , dblInvoiceTotal
									 , dblBaseInvoiceTotal
									 , dblDiscount
									 , dblBaseDiscount
									 , dblDiscountAvailable
									 , dblBaseDiscountAvailable
									 , dblInterest
									 , dblBaseInterest
									 , dblAmountDue
									 , dblBaseAmountDue
									 , dblPayment
									 , dblBasePayment
									 , strInvoiceReportNumber
									 , intCurrencyExchangeRateTypeId
									 , intCurrencyExchangeRateId
									 , dblCurrencyExchangeRate
									 , intConcurrencyId
								)
								SELECT intPaymentId						= @intPaymentId
									 , intInvoiceId						= intInvoiceId
									 , intBillId						= NULL
									 , strTransactionNumber				= strTransactionNumber
									 , intTermId						= intTermId
									 , intAccountId						= intAccountId
									 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblDiscount						= 0
									 , dblBaseDiscount					= 0
									 , dblDiscountAvailable				= 0
									 , dblBaseDiscountAvailable			= 0
									 , dblInterest						= 0
									 , dblBaseInterest					= 0
									 , dblAmountDue						= 0
									 , dblBaseAmountDue					= 0
									 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
									 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
									 , strInvoiceReportNumber			= NULL
									 , intCurrencyExchangeRateTypeId	= NULL
									 , intCurrencyExchangeRateId		= NULL
									 , dblCurrencyExchangeRate			= 1
									 , intConcurrencyId					= 1
								FROM @tblOpenInvoices
								WHERE intEntityCustomerId = @intEntityCustomerId
								  AND intInvoiceId = @intCurrentInvoiceId
							END
						ELSE
							BEGIN
								SET @dblDifference = ISNULL(@dblTotalDueCounter, 0) - ISNULL(@dblCreditsTotalDue, 0)

								INSERT INTO tblARPaymentDetail (
									   intPaymentId
									 , intInvoiceId
									 , intBillId
									 , strTransactionNumber
									 , intTermId
									 , intAccountId
									 , dblInvoiceTotal
									 , dblBaseInvoiceTotal
									 , dblDiscount
									 , dblBaseDiscount
									 , dblDiscountAvailable
									 , dblBaseDiscountAvailable
									 , dblInterest
									 , dblBaseInterest
									 , dblAmountDue
									 , dblBaseAmountDue
									 , dblPayment
									 , dblBasePayment
									 , strInvoiceReportNumber
									 , intCurrencyExchangeRateTypeId
									 , intCurrencyExchangeRateId
									 , dblCurrencyExchangeRate
									 , intConcurrencyId
								)
								SELECT intPaymentId						= @intPaymentId
									 , intInvoiceId						= intInvoiceId
									 , intBillId						= NULL
									 , strTransactionNumber				= strTransactionNumber
									 , intTermId						= intTermId
									 , intAccountId						= intAccountId
									 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblDiscount						= 0
									 , dblBaseDiscount					= 0
									 , dblDiscountAvailable				= 0
									 , dblBaseDiscountAvailable			= 0
									 , dblInterest						= 0
									 , dblBaseInterest					= 0
									 , dblAmountDue						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN @dblDifference * -1 ELSE @dblDifference END
									 , dblBaseAmountDue					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN @dblDifference * -1 ELSE @dblDifference END
									 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN (dblInvoiceTotal - @dblDifference) * -1 ELSE (dblInvoiceTotal - @dblDifference) END
									 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN (dblInvoiceTotal - @dblDifference) * -1 ELSE (dblInvoiceTotal - @dblDifference) END
									 , strInvoiceReportNumber			= NULL
									 , intCurrencyExchangeRateTypeId	= NULL
									 , intCurrencyExchangeRateId		= NULL
									 , dblCurrencyExchangeRate			= 1
									 , intConcurrencyId					= 1
								FROM @tblOpenInvoices
								WHERE intEntityCustomerId = @intEntityCustomerId
								  AND intInvoiceId = @intCurrentInvoiceId

								SET @dblDifference = 0
								DELETE FROM @tblOpenInvoices 
								WHERE intEntityCustomerId = @intEntityCustomerId
							END

						DELETE FROM @tblOpenInvoices 
						WHERE intEntityCustomerId = @intEntityCustomerId AND intInvoiceId = @intCurrentInvoiceId
					END
			END
		ELSE
			BEGIN
				--INSERT ALL OPEN INVOICES
				INSERT INTO tblARPaymentDetail (
					   intPaymentId
					 , intInvoiceId
					 , intBillId
					 , strTransactionNumber
					 , intTermId
					 , intAccountId
					 , dblInvoiceTotal
					 , dblBaseInvoiceTotal
					 , dblDiscount
					 , dblBaseDiscount
					 , dblDiscountAvailable
					 , dblBaseDiscountAvailable
					 , dblInterest
					 , dblBaseInterest
					 , dblAmountDue
					 , dblBaseAmountDue
					 , dblPayment
					 , dblBasePayment
					 , strInvoiceReportNumber
					 , intCurrencyExchangeRateTypeId
					 , intCurrencyExchangeRateId
					 , dblCurrencyExchangeRate
					 , intConcurrencyId
				)
				SELECT intPaymentId						= @intPaymentId
					 , intInvoiceId						= intInvoiceId
					 , intBillId						= NULL
					 , strTransactionNumber				= strTransactionNumber
					 , intTermId						= intTermId
					 , intAccountId						= intAccountId
					 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
					 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
					 , dblDiscount						= 0
					 , dblBaseDiscount					= 0
					 , dblDiscountAvailable				= 0
					 , dblBaseDiscountAvailable			= 0
					 , dblInterest						= 0
					 , dblBaseInterest					= 0
					 , dblAmountDue						= 0
					 , dblBaseAmountDue					= 0
					 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
					 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
					 , strInvoiceReportNumber			= NULL
					 , intCurrencyExchangeRateTypeId	= NULL
					 , intCurrencyExchangeRateId		= NULL
					 , dblCurrencyExchangeRate			= 1
					 , intConcurrencyId					= 1
				FROM @tblOpenInvoices
				WHERE intEntityCustomerId = @intEntityCustomerId

				WHILE EXISTS (SELECT NULL FROM @tblCredits WHERE intEntityCustomerId = @intEntityCustomerId)
					BEGIN
						SELECT TOP 1 @intCurrentInvoiceId = intInvoiceId
								   , @dblTotalDueCounter  = ISNULL(@dblTotalDueCounter, 0) + ISNULL(dblAmountDue, 0)
						FROM @tblCredits 
						WHERE intEntityCustomerId = @intEntityCustomerId 

						IF ISNULL(@dblInvoiceTotalDue, 0) > ISNULL(@dblTotalDueCounter, 0)
							BEGIN
								INSERT INTO tblARPaymentDetail (
									   intPaymentId
									 , intInvoiceId
									 , intBillId
									 , strTransactionNumber
									 , intTermId
									 , intAccountId
									 , dblInvoiceTotal
									 , dblBaseInvoiceTotal
									 , dblDiscount
									 , dblBaseDiscount
									 , dblDiscountAvailable
									 , dblBaseDiscountAvailable
									 , dblInterest
									 , dblBaseInterest
									 , dblAmountDue
									 , dblBaseAmountDue
									 , dblPayment
									 , dblBasePayment
									 , strInvoiceReportNumber
									 , intCurrencyExchangeRateTypeId
									 , intCurrencyExchangeRateId
									 , dblCurrencyExchangeRate
									 , intConcurrencyId
								)
								SELECT intPaymentId						= @intPaymentId
									 , intInvoiceId						= intInvoiceId
									 , intBillId						= NULL
									 , strTransactionNumber				= strTransactionNumber
									 , intTermId						= intTermId
									 , intAccountId						= intAccountId
									 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblDiscount						= 0
									 , dblBaseDiscount					= 0
									 , dblDiscountAvailable				= 0
									 , dblBaseDiscountAvailable			= 0
									 , dblInterest						= 0
									 , dblBaseInterest					= 0
									 , dblAmountDue						= 0
									 , dblBaseAmountDue					= 0
									 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
									 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblAmountDue * -1 ELSE dblAmountDue END
									 , strInvoiceReportNumber			= NULL
									 , intCurrencyExchangeRateTypeId	= NULL
									 , intCurrencyExchangeRateId		= NULL
									 , dblCurrencyExchangeRate			= 1
									 , intConcurrencyId					= 1
								FROM @tblCredits
								WHERE intEntityCustomerId = @intEntityCustomerId
								  AND intInvoiceId = @intCurrentInvoiceId
							END
						ELSE
							BEGIN
								SET @dblDifference = ISNULL(@dblTotalDueCounter, 0) - ISNULL(@dblInvoiceTotalDue, 0)

								INSERT INTO tblARPaymentDetail (
									   intPaymentId
									 , intInvoiceId
									 , intBillId
									 , strTransactionNumber
									 , intTermId
									 , intAccountId
									 , dblInvoiceTotal
									 , dblBaseInvoiceTotal
									 , dblDiscount
									 , dblBaseDiscount
									 , dblDiscountAvailable
									 , dblBaseDiscountAvailable
									 , dblInterest
									 , dblBaseInterest
									 , dblAmountDue
									 , dblBaseAmountDue
									 , dblPayment
									 , dblBasePayment
									 , strInvoiceReportNumber
									 , intCurrencyExchangeRateTypeId
									 , intCurrencyExchangeRateId
									 , dblCurrencyExchangeRate
									 , intConcurrencyId
								)
								SELECT intPaymentId						= @intPaymentId
									 , intInvoiceId						= intInvoiceId
									 , intBillId						= NULL
									 , strTransactionNumber				= strTransactionNumber
									 , intTermId						= intTermId
									 , intAccountId						= intAccountId
									 , dblInvoiceTotal					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblBaseInvoiceTotal				= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
									 , dblDiscount						= 0
									 , dblBaseDiscount					= 0
									 , dblDiscountAvailable				= 0
									 , dblBaseDiscountAvailable			= 0
									 , dblInterest						= 0
									 , dblBaseInterest					= 0
									 , dblAmountDue						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN @dblDifference * -1 ELSE @dblDifference END
									 , dblBaseAmountDue					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN @dblDifference * -1 ELSE @dblDifference END
									 , dblPayment						= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN (dblInvoiceTotal - @dblDifference) * -1 ELSE (dblInvoiceTotal - @dblDifference) END
									 , dblBasePayment					= CASE WHEN strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') THEN (dblInvoiceTotal - @dblDifference) * -1 ELSE (dblInvoiceTotal - @dblDifference) END
									 , strInvoiceReportNumber			= NULL
									 , intCurrencyExchangeRateTypeId	= NULL
									 , intCurrencyExchangeRateId		= NULL
									 , dblCurrencyExchangeRate			= 1
									 , intConcurrencyId					= 1
								FROM @tblCredits
								WHERE intEntityCustomerId = @intEntityCustomerId
								  AND intInvoiceId = @intCurrentInvoiceId

								SET @dblDifference = 0
								DELETE FROM @tblCredits 
								WHERE intEntityCustomerId = @intEntityCustomerId
							END

						DELETE FROM @tblCredits 
						WHERE intEntityCustomerId = @intEntityCustomerId AND intInvoiceId = @intCurrentInvoiceId
					END
			END

		DELETE FROM @tblCustomerWithCredits WHERE intEntityCustomerId = @intEntityCustomerId
		DELETE FROM @tblCredits WHERE intEntityCustomerId = @intEntityCustomerId
		DELETE FROM @tblOpenInvoices WHERE intEntityCustomerId = @intEntityCustomerId
		SET @dblARBalance = 0
		SET @dblCreditsTotalDue	= 0
		SET @dblInvoiceTotalDue = 0
		SET @dblTotalDueCounter = 0
		SET @dblDifference = 0
		SET @intPaymentId = 0		
	END	