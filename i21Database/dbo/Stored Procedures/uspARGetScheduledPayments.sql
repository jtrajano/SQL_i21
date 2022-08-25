CREATE PROCEDURE uspARGetScheduledPayments
AS
BEGIN TRY
	BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL DROP TABLE #PAYMENTS
	IF OBJECT_ID('tempdb..#PAYMENTSTOPROCESS') IS NOT NULL DROP TABLE #PAYMENTSTOPROCESS
	IF OBJECT_ID('tempdb..#OPENINVOICES') IS NOT NULL DROP TABLE #OPENINVOICES
	IF OBJECT_ID('tempdb..#CUSTOMERSAUTOPAY') IS NOT NULL DROP TABLE #CUSTOMERSAUTOPAY

	CREATE TABLE #PAYMENTS (
		  intPaymentId			INT PRIMARY KEY
		, intEntityCardInfoId	INT NULL
		, intEntityCustomerId	INT NULL
		, intBankAccountId		INT NULL	
		, intEntityUserId		INT NULL
		, intCompanyLocationId	INT NULL
		, intDayOfMonth			INT NULL
		, dtmDatePaid			DATETIME
		, dtmScheduledPayment	DATETIME
		, dblAmountPaid			NUMERIC(18, 6) NULL
		, strRecordNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL	
	)

	CREATE TABLE #CUSTOMERSAUTOPAY (
		  intEntityCustomerId	INT PRIMARY KEY
		, intEntityCardInfoId	INT NULL
		, intBankAccountId		INT NULL
		, strCreditCardNumber	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
	)

	CREATE TABLE #PAYMENTSTOPROCESS (
		  intPaymentId			INT PRIMARY KEY
		, intEntityCardInfoId	INT
		, intEntityCustomerId	INT
		, intBankAccountId		INT NULL
		, intDayOfMonth			INT NULL
		, intEntityUserId		INT NULL
		, intCompanyLocationId	INT
		, dtmDatePaid			DATETIME
		, dtmScheduledPayment	DATETIME
		, dblAmountPaid			NUMERIC(18, 6) NULL
		, strRecordNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
		, strCustomerNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, strInvoices			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		, ysnValidated			BIT NULL DEFAULT(0)
		, ysnValid				BIT NULL DEFAULT(0)
		, strError				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		, strVersion			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strUserName			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	)
	
	DECLARE @EntriesForPayment		PaymentIntegrationStagingTable
	DECLARE @dtmCurrentDate			DATETIME = CAST(GETDATE() AS DATE)
	DECLARE @intCompanyLocationId	INT = NULL
		  , @intBankAccountId		INT = NULL
		  , @intUserId				INT = NULL
		  , @intACHPaymentMethodId	INT = NULL
		  , @strErrorMessage		NVARCHAR(MAX) = NULL
		  , @intLogId				INT = NULL
		  , @strVersion 			NVARCHAR(100)

	SELECT TOP 1 @intCompanyLocationId  = CP.intPaymentsLocationId
			   , @intBankAccountId		= BA.intBankAccountId
	FROM tblSMCompanyPreference CP
	INNER JOIN tblSMCompanyLocation CL ON CP.intPaymentsLocationId = CL.intCompanyLocationId
	LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
	WHERE CL.ysnLocationActive = 1
	ORDER BY intCompanyPreferenceId DESC

	SELECT TOP 1 @intUserId = intEntityId
	FROM tblEMEntityCredential
	WHERE strUserName LIKE '%irely%'
	ORDER BY intEntityCredentialId ASC
	
	SELECT TOP 1 @strVersion = strVersionNo
	FROM tblSMBuildNumber
	ORDER BY intVersionID DESC

	SELECT TOP 1 @intACHPaymentMethodId = intPaymentMethodID
	FROM tblSMPaymentMethod
	WHERE strPaymentMethod = 'ACH'
	ORDER BY intPaymentMethodID ASC

	IF @intCompanyLocationId IS NULL
		BEGIN
			RAISERROR('Company Configuration > System Manager > Payments Location is required.', 16, 1)	
			RETURN
		END	

	--GET ACH CUSTOMERS
	INSERT INTO #CUSTOMERSAUTOPAY (
		  intEntityCustomerId
		, intBankAccountId
	)
	SELECT intEntityCustomerId	= SPM.intEntityId
		 , intBankAccountId		= MIN(SPM.intBankAccountId)
	FROM tblARScheduledPaymentMethod SPM 
	WHERE SPM.ysnAutoPay = 1
	  AND DAY(@dtmCurrentDate) = SPM.intDayOfMonth
	  AND SPM.intBankAccountId IS NOT NULL
	GROUP BY SPM.intEntityId

	--GET CC CUSTOMERS IF THERES NO ACH YET
	INSERT INTO #CUSTOMERSAUTOPAY (
		  intEntityCustomerId
		, intEntityCardInfoId
		, strCreditCardNumber
	)
	SELECT intEntityCustomerId	= ECI.intEntityId
		 , intEntityCardInfoId	= MIN(ECI.intEntityCardInfoId)
		 , strCreditCardNumber	= MIN(ECI.strCreditCardNumber)
	FROM tblARScheduledPaymentMethod SPM 
	INNER JOIN tblEMEntityCardInformation ECI ON SPM.intEntityCardInfoId = ECI.intEntityCardInfoId
	LEFT JOIN #CUSTOMERSAUTOPAY C ON SPM.intEntityId = C.intEntityCustomerId
	WHERE ECI.ysnActive = 1
	  AND SPM.ysnAutoPay = 1
	  AND ECI.dtmTokenExpired > GETDATE()
	  AND DAY(@dtmCurrentDate) = SPM.intDayOfMonth
	  AND SPM.intBankAccountId IS NULL
	  AND C.intEntityCustomerId IS NULL
	GROUP BY ECI.intEntityId

	INSERT INTO #PAYMENTS (
		  intPaymentId
		, intEntityCardInfoId
		, intEntityCustomerId
		, intBankAccountId
		, intEntityUserId
		, intCompanyLocationId
		, dtmDatePaid
		, dtmScheduledPayment
		, dblAmountPaid
		, strRecordNumber
		, intDayOfMonth
	)
	--GET CC SCHEDULED PAYMENTS
	SELECT intPaymentId			= P.intPaymentId
		, intEntityCardInfoId	= P.intEntityCardInfoId
		, intEntityCustomerId	= P.intEntityCustomerId
		, intBankAccountId		= NULL
		, intEntityUserId		= P.intEntityId
		, intCompanyLocationId	= P.intLocationId
		, dtmDatePaid			= P.dtmDatePaid
		, dtmScheduledPayment	= CAST(P.dtmScheduledPayment AS DATE)
		, dblAmountPaid			= P.dblAmountPaid
		, strRecordNumber		= P.strRecordNumber
		, intDayOfMonth			= SPM.intDayOfMonth
	FROM tblARPayment P
	INNER JOIN tblARScheduledPaymentMethod SPM ON P.intEntityCardInfoId = SPM.intEntityCardInfoId  AND SPM.ysnAutoPay = 1 
	WHERE P.ysnPosted = 0
	  AND P.ysnScheduledPayment = 1
	  AND P.intEntityCardInfoId IS NOT NULL
	  AND P.dtmScheduledPayment IS NOT NULL
	  AND P.intPaymentMethodId = 11
	  AND P.ysnProcessCreditCard = 0  
	  AND DAY(@dtmCurrentDate) = SPM.intDayOfMonth
	  AND CAST(P.dtmScheduledPayment AS DATE) <= @dtmCurrentDate

	UNION ALL

	SELECT intPaymentId			= P.intPaymentId
		, intEntityCardInfoId	= NULL
		, intEntityCustomerId	= P.intEntityCustomerId
		, intBankAccountId		= P.intBankAccountId
		, intEntityUserId		= P.intEntityId
		, intCompanyLocationId	= P.intLocationId
		, dtmDatePaid			= P.dtmDatePaid
		, dtmScheduledPayment	= CAST(P.dtmScheduledPayment AS DATE)
		, dblAmountPaid			= P.dblAmountPaid
		, strRecordNumber		= P.strRecordNumber
		, intDayOfMonth			= SPM.intDayOfMonth
	FROM tblARPayment P
	INNER JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	INNER JOIN tblARScheduledPaymentMethod SPM ON P.intBankAccountId = SPM.intBankAccountId AND SPM.ysnAutoPay = 1
	WHERE P.ysnPosted = 0
	  AND P.ysnScheduledPayment = 1    
	  AND P.dtmScheduledPayment IS NOT NULL
	  AND PM.strPaymentMethod = 'ACH'
	  AND DAY(@dtmCurrentDate) = SPM.intDayOfMonth
	  AND CAST(P.dtmScheduledPayment AS DATE) <= @dtmCurrentDate	

	INSERT INTO #PAYMENTSTOPROCESS (
		  intPaymentId
		, intEntityCardInfoId
		, intEntityCustomerId
		, intBankAccountId
		, intDayOfMonth
		, intEntityUserId
		, intCompanyLocationId
		, dtmDatePaid
		, dtmScheduledPayment
		, dblAmountPaid
		, strRecordNumber
		, strCustomerNumber
		, strInvoices
		, strVersion
		, strUserName
	)
	SELECT intPaymentId			= P.intPaymentId
		 , intEntityCardInfoId	= P.intEntityCardInfoId
		 , intEntityCustomerId	= P.intEntityCustomerId		 
		 , intBankAccountId		= P.intBankAccountId
		 , intDayOfMonth		= P.intDayOfMonth
		 , intEntityUserId      = P.intEntityUserId
		 , intCompanyLocationId	= P.intCompanyLocationId
		 , dtmDatePaid			= P.dtmDatePaid
		 , dtmScheduledPayment	= P.dtmScheduledPayment
		 , dblAmountPaid		= P.dblAmountPaid
		 , strRecordNumber		= P.strRecordNumber
		 , strCustomerNumber	= C.strCustomerNumber
		 , strInvoices			= INVOICE.strInvoiceNumbers
		 , strVersion			= @strVersion
		 , strUserName			= EC.strUserName	
	FROM #PAYMENTS P
	INNER JOIN tblARCustomer C ON P.intEntityCustomerId = C.intEntityId
	INNER JOIN tblEMEntityCredential EC ON P.intEntityUserId = EC.intEntityId
	CROSS APPLY (
		SELECT strInvoiceNumbers = LEFT(strTransactionNumber, LEN(strTransactionNumber) - 1) COLLATE Latin1_General_CI_AS
		FROM (
			SELECT CAST(PD.strTransactionNumber AS VARCHAR(200))  + ', '
			FROM tblARPaymentDetail PD WITH(NOLOCK)			
			WHERE PD.intPaymentId = P.intPaymentId
				AND PD.dblPayment != 0
			FOR XML PATH ('')
		) INV (strTransactionNumber)
	) INVOICE

	--GET OPEN DUE INVOICES
	SELECT intInvoiceId						= P.intInvoiceId
		, strTransactionType				= P.strTransactionType
		, strInvoiceNumber					= P.strInvoiceNumber
		, intEntityCustomerId				= P.intEntityCustomerId
		, intCurrencyId						= P.intCurrencyId
		, intAccountId						= P.intAccountId
		, strTransactionNumber				= P.strTransactionNumber
		, intTermId							= P.intTermId
		, dblInvoiceTotal					= P.dblInvoiceTotal
		, dblBaseInvoiceTotal				= P.dblBaseInvoiceTotal
		, dblAmountDue						= P.dblAmountDue
		, dblDiscountAvailable				= P.dblDiscountAvailable
		, dblInterest						= P.dblInterest
		, strInvoiceReportNumber			= P.strInvoiceReportNumber
		, intCurrencyExchangeRateId			= P.intCurrencyExchangeRateId
		, intCurrencyExchangeRateTypeId		= P.intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate			= P.dblCurrencyExchangeRate
		, dblTotalPayment					= CAST(0 AS NUMERIC(18, 6))
		, strCreditCardNumber				= ECI.strCreditCardNumber
		, intEntityCardInfoId				= ECI.intEntityCardInfoId
		, intBankAccountId					= ECI.intBankAccountId
	INTO #OPENINVOICES
	FROM #CUSTOMERSAUTOPAY ECI
	INNER JOIN vyuARInvoicesForPayment P ON ECI.intEntityCustomerId = P.intEntityCustomerId
	INNER JOIN tblARCustomer C ON ECI.intEntityCustomerId = C.intEntityId
	WHERE P.ysnExcludeForPayment = 0
	  AND P.dtmDueDate < @dtmCurrentDate
	  AND P.ysnPosted = 1
	  AND P.ysnForgiven = 0
	  AND P.ysnPaid = 0
	  AND P.dblAmountDue <> 0
	  AND P.strTransactionType NOT IN ('EFT Budget', 'Cash Refund', 'Vendor Prepayment', 'Claim')
	  AND P.strTransactionType IN ('Invoice', 'Debit Memo')
	  AND C.dblARBalance > 0
	  	  
	--REMOVE EXISTING PAYMENTS FROM SCHEDULED
	IF EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSTOPROCESS) AND EXISTS (SELECT TOP 1 NULL FROM #OPENINVOICES)
		BEGIN
			UPDATE OI
			SET dblAmountDue = OI.dblAmountDue - PPD.dblPayment
			FROM #PAYMENTSTOPROCESS PP
			INNER JOIN tblARPaymentDetail PPD ON PP.intPaymentId = PPD.intPaymentId
			INNER JOIN #OPENINVOICES OI ON PPD.intInvoiceId = OI.intInvoiceId AND PP.intEntityCustomerId = OI.intEntityCustomerId
			
			DELETE 
			FROM #OPENINVOICES
			WHERE dblAmountDue <= 0
		END

	UPDATE I
	SET dblTotalPayment = OI.dblTotalPayment
	FROM #OPENINVOICES I
	INNER JOIN (
		SELECT intEntityCustomerId 
			 , dblTotalPayment = SUM(dblAmountDue)
		FROM #OPENINVOICES
		GROUP BY intEntityCustomerId
	) OI ON I.intEntityCustomerId = OI.intEntityCustomerId

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
	SELECT intId						= INVOICE.intInvoiceId
		, strSourceTransaction			= INVOICE.strTransactionType
		, intSourceId					= INVOICE.intInvoiceId
		, strSourceId					= INVOICE.strInvoiceNumber
		, intPaymentId					= NULL
		, intEntityCustomerId			= INVOICE.intEntityCustomerId
		, intCompanyLocationId			= @intCompanyLocationId
		, intCurrencyId					= INVOICE.intCurrencyId
		, dtmDatePaid					= @dtmCurrentDate
		, intPaymentMethodId			= CASE WHEN INVOICE.intEntityCardInfoId IS NULL THEN @intACHPaymentMethodId ELSE 11 END
		, strPaymentMethod				= CASE WHEN INVOICE.intEntityCardInfoId IS NULL THEN 'ACH' ELSE INVOICE.strCreditCardNumber END
		, strPaymentInfo				= NULL
		, strNotes						= NULL
		, intAccountId					= INVOICE.intAccountId
		, intBankAccountId				= CASE WHEN INVOICE.intEntityCardInfoId IS NULL THEN INVOICE.intBankAccountId ELSE @intBankAccountId END
		, dblAmountPaid					= INVOICE.dblTotalPayment
		, ysnPost						= CASE WHEN INVOICE.intEntityCardInfoId IS NULL THEN 1 ELSE 0 END
		, intEntityId					= @intUserId
		, intEntityCardInfoId			= INVOICE.intEntityCardInfoId
		, intInvoiceId					= INVOICE.intInvoiceId
		, strTransactionType			= INVOICE.strTransactionType
		, strTransactionNumber			= INVOICE.strTransactionNumber
		, intTermId						= INVOICE.intTermId
		, intInvoiceAccountId			= INVOICE.intAccountId
		, dblInvoiceTotal				= INVOICE.dblInvoiceTotal
		, dblBaseInvoiceTotal			= INVOICE.dblBaseInvoiceTotal
		, ysnApplyTermDiscount			= 0
		, dblDiscount					= 0
		, dblDiscountAvailable			= INVOICE.dblDiscountAvailable
		, dblWriteOffAmount				= 0
		, dblBaseWriteOffAmount			= 0
		, dblInterest					= INVOICE.dblInterest
		, dblPayment					= INVOICE.dblAmountDue
		, dblCreditCardFee				= 0
		, dblAmountDue					= 0
		, dblBaseAmountDue				= 0
		, strInvoiceReportNumber		= INVOICE.strInvoiceReportNumber
		, intCurrencyExchangeRateTypeId	= INVOICE.intCurrencyExchangeRateTypeId
		, intCurrencyExchangeRateId		= INVOICE.intCurrencyExchangeRateId
		, dblCurrencyExchangeRate		= INVOICE.dblCurrencyExchangeRate
		, ysnAllowOverpayment			= 0
		, ysnFromAP						= 0
		, ysnScheduledPayment			= 1
		, dtmScheduledPayment			= @dtmCurrentDate
	FROM #OPENINVOICES INVOICE

	--POST PAYMENTS FOR SCHEDULED ACH
	IF EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSTOPROCESS WHERE intEntityCardInfoId IS NULL)
		BEGIN
			DECLARE @strPaymentIds NVARCHAR(MAX) = NULL

			SELECT @strPaymentIds = LEFT(intPaymentId, LEN(intPaymentId) - 1)
			FROM (
				SELECT DISTINCT CAST(intPaymentId AS VARCHAR(200))  + ', '
				FROM #PAYMENTSTOPROCESS
				WHERE intEntityCardInfoId IS NULL
				FOR XML PATH ('')
			) C (intPaymentId) 

			EXEC dbo.uspARPostPayment @post = 1, @raiseError = 0, @param = @strPaymentIds, @userId = @intUserId

			DELETE FROM #PAYMENTSTOPROCESS WHERE intBankAccountId IS NOT NULL AND intEntityCardInfoId IS NULL
		END

	--CREATE PAYMENTS FOR DUE INVOICES
	IF EXISTS (SELECT TOP 1 NULL FROM #OPENINVOICES)
		BEGIN
			EXEC uspARProcessPayments @PaymentEntries	= @EntriesForPayment
									, @UserId			= @intUserId
									, @GroupingOption	= 1
									, @RaiseError		= 0
									, @ErrorMessage		= @strErrorMessage OUTPUT
									, @LogId			= @intLogId OUTPUT

			INSERT INTO #PAYMENTSTOPROCESS (
				  intPaymentId
				, intEntityCardInfoId
				, intEntityCustomerId
				, intBankAccountId
				, intDayOfMonth
				, intEntityUserId
				, intCompanyLocationId
				, dtmDatePaid
				, dtmScheduledPayment
				, dblAmountPaid
				, strRecordNumber
				, strCustomerNumber
				, strInvoices
				, strVersion
				, strUserName
			)
			SELECT intPaymentId			= P.intPaymentId
				 , intEntityCardInfoId	= P.intEntityCardInfoId
				 , intEntityCustomerId	= P.intEntityCustomerId		 
				 , intBankAccountId		= P.intBankAccountId
				 , intDayOfMonth		= CI.intDayOfMonth
				 , intEntityUserId      = P.intEntityId
				 , intCompanyLocationId	= P.intLocationId
				 , dtmDatePaid			= P.dtmDatePaid
				 , dtmScheduledPayment	= P.dtmScheduledPayment
				 , dblAmountPaid		= P.dblAmountPaid
				 , strRecordNumber		= P.strRecordNumber
				 , strCustomerNumber	= C.strCustomerNumber
				 , strInvoices			= INVOICE.strInvoiceNumbers
				 , strVersion			= @strVersion
				 , strUserName			= EC.strUserName	
			FROM tblARPaymentIntegrationLogDetail LD
			INNER JOIN tblARPayment P ON LD.intPaymentId = P.intPaymentId
			INNER JOIN tblARCustomer C ON P.intEntityCustomerId = C.intEntityId
			INNER JOIN tblEMEntityCardInformation CI ON P.intEntityCardInfoId = CI.intEntityCardInfoId
			INNER JOIN tblEMEntityCredential EC ON P.intEntityId = EC.intEntityId
			CROSS APPLY (
				SELECT strInvoiceNumbers = LEFT(strTransactionNumber, LEN(strTransactionNumber) - 1) COLLATE Latin1_General_CI_AS
				FROM (
					SELECT CAST(PD.strTransactionNumber AS VARCHAR(200))  + ', '
					FROM tblARPaymentDetail PD WITH(NOLOCK)			
					WHERE PD.intPaymentId = P.intPaymentId
					  AND PD.dblPayment != 0
					FOR XML PATH ('')
				) INV (strTransactionNumber)
			) INVOICE 
			WHERE LD.intIntegrationLogId = @intLogId
			  AND LD.ysnHeader = 1
			  AND LD.ysnSuccess = 1
		END	
	
	--CALL PAYMENT POSTING VALIDATION
	WHILE EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSTOPROCESS WHERE ysnValidated = 0)
		BEGIN
			DECLARE @intPaymentId		INT = NULL
				  , @dtmPostDate		DATETIME = NULL
				  , @strError			NVARCHAR(500) = NULL
			
			SET @intBankAccountId = NULL
			
			SELECT TOP 1 @intPaymentId	 	= intPaymentId
				       , @intBankAccountId	= intBankAccountId
					   , @dtmPostDate		= dtmDatePaid
			FROM #PAYMENTSTOPROCESS 
			WHERE ysnValidated = 0
			
			EXEC uspARValidatePaymentPosting @PaymentId     = @intPaymentId
										   , @Post          = 1
										   , @UserId        = 1
										   , @BankAccountId = @intBankAccountId
										   , @BatchId       = NULL
										   , @PostDate      = @dtmPostDate
										   , @Error         = @strError OUT

			UPDATE #PAYMENTSTOPROCESS 
			SET ysnValidated	= 1
			  , ysnValid		= CASE WHEN ISNULL(@strError, '') <> '' THEN 0 ELSE 1 END
			  , strError		= NULLIF(@strError, '')
			WHERE intPaymentId = @intPaymentId
		END

	--LOG VALIDATION ERROR IN RCV-NOTES
	UPDATE P
	SET strNotes = PP.strError
	FROM tblARPayment P
	INNER JOIN #PAYMENTSTOPROCESS  PP ON P.intPaymentId = PP.intPaymentId
	WHERE PP.ysnValidated = 1 
	  AND PP.ysnValid = 0
	  AND P.ysnPosted = 0

	SELECT * FROM #PAYMENTSTOPROCESS WHERE ysnValid = 1 AND intEntityCardInfoId IS NOT NULL
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH

