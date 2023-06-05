CREATE FUNCTION [dbo].[fnARCustomerAgingDetail]
(
	 @dtmDateFrom				DATETIME = NULL
	,@dtmDateTo					DATETIME = NULL
    ,@strSourceTransaction		NVARCHAR(100) = NULL	
	,@strCustomerIds			NVARCHAR(MAX) = NULL
	,@strSalespersonIds			NVARCHAR(MAX) = NULL
	,@strCompanyLocationIds		NVARCHAR(MAX) = NULL
	,@strCompanyNameIds			NVARCHAR(MAX) = NULL
	,@strAccountStatusIds		NVARCHAR(MAX) = NULL	
	,@intEntityUserId			INT = NULL
	,@ysnPaidInvoice			BIT = NULL
	,@ysnInclude120Days			BIT = 0
	,@ysnExcludeAccountStatus	BIT = 0
	,@intGracePeriod			INT = 0
	,@ysnOverrideCashFlow  		BIT = 0
)
RETURNS @returntable TABLE (
	 [strCustomerName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,[strCustomerNumber]		NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL
	,[strCustomerInfo]			NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
    ,[strInvoiceNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL 
    ,[strRecordNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL 
	,[intInvoiceId]				INT NULL
	,[intPaymentId]				INT NULL
	,[strBOLNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
	,[intEntityCustomerId]		INT NULL
	,[intEntityUserId]			INT NULL
	,[dblCreditLimit]			NUMERIC(18, 6) NULL
	,[dblTotalAR]				NUMERIC(18, 6) NULL
	,[dblTotalCustomerAR]       NUMERIC(18, 6) NULL
	,[dblFuture]				NUMERIC(18, 6) NULL
	,[dbl0Days]					NUMERIC(18, 6) NULL
	,[dbl10Days]				NUMERIC(18, 6) NULL
	,[dbl30Days]				NUMERIC(18, 6) NULL
	,[dbl60Days]				NUMERIC(18, 6) NULL
	,[dbl90Days]				NUMERIC(18, 6) NULL
	,[dbl120Days]				NUMERIC(18, 6) NULL
	,[dbl121Days]				NUMERIC(18, 6) NULL
	,[dblTotalDue]				NUMERIC(18, 6) NULL 
	,[dblAmountPaid]			NUMERIC(18, 6) NULL 
	,[dblInvoiceTotal]			NUMERIC(18, 6) NULL
	,[dblCredits]				NUMERIC(18, 6) NULL 
	,[dblPrepayments]			NUMERIC(18, 6) NULL
	,[dblPrepaids]				NUMERIC(18, 6) NULL
	,[dtmDate]					DATETIME NULL
	,[dtmDueDate]				DATETIME NULL 
	,[dtmAsOfDate]				DATETIME NULL 
	,[strSalespersonName]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,[intCompanyLocationId]		INT NULL
	,[strSourceTransaction]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strType]					NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	,[strTransactionType]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	,[strCompanyName]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strCompanyAddress]        NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,[strAgingType]				NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyId]			INT NULL
	,[strCurrency]              NVARCHAR(40)
	,[dblHistoricRate]			NUMERIC(18, 6) NULL
	,[dblHistoricAmount]		NUMERIC(18, 6) NULL
	,[dblEndOfMonthRate]		NUMERIC(18, 6) NULL
	,[dblEndOfMonthAmount]		NUMERIC(18, 6) NULL
	,[intAccountId]			    INT NULL
)
AS
BEGIN
	DECLARE @tempReturntable TABLE (
		 [strCustomerName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[strCustomerNumber]		NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL
		,[strCustomerInfo]			NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,[strInvoiceNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL 
		,[strRecordNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL 
		,[intInvoiceId]				INT NULL
		,[intPaymentId]				INT NULL
		,[strBOLNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,[intEntityCustomerId]		INT NULL
		,[intEntityUserId]			INT NULL
		,[dblCreditLimit]			NUMERIC(18, 6) NULL
		,[dblTotalAR]				NUMERIC(18, 6) NULL
		,[dblTotalCustomerAR]       NUMERIC(18, 6) NULL
		,[dblFuture]				NUMERIC(18, 6) NULL
		,[dbl0Days]					NUMERIC(18, 6) NULL
		,[dbl10Days]				NUMERIC(18, 6) NULL
		,[dbl30Days]				NUMERIC(18, 6) NULL
		,[dbl60Days]				NUMERIC(18, 6) NULL
		,[dbl90Days]				NUMERIC(18, 6) NULL
		,[dbl120Days]				NUMERIC(18, 6) NULL
		,[dbl121Days]				NUMERIC(18, 6) NULL
		,[dblTotalDue]				NUMERIC(18, 6) NULL 
		,[dblAmountPaid]			NUMERIC(18, 6) NULL 
		,[dblInvoiceTotal]			NUMERIC(18, 6) NULL
		,[dblCredits]				NUMERIC(18, 6) NULL 
		,[dblPrepayments]			NUMERIC(18, 6) NULL
		,[dblPrepaids]				NUMERIC(18, 6) NULL
		,[dtmDate]					DATETIME NULL
		,[dtmDueDate]				DATETIME NULL 
		,[dtmAsOfDate]				DATETIME NULL 
		,[strSalespersonName]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[intCompanyLocationId]		INT NULL
		,[strSourceTransaction]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strType]					NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
		,[strTransactionType]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
		,[strCompanyName]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strCompanyAddress]        NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,[strAgingType]				NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
		,[intCurrencyId]			INT NULL
		,[strCurrency]              NVARCHAR(40)
		,[dblHistoricRate]			NUMERIC(18, 6) NULL
		,[dblHistoricAmount]		NUMERIC(18, 6) NULL
		,[dblEndOfMonthRate]		NUMERIC(18, 6) NULL
		,[dblEndOfMonthAmount]		NUMERIC(18, 6) NULL
		,[intAccountId]			    INT NULL
	)

	DECLARE @dtmDateFromLocal			DATETIME = NULL,
			@dtmDateToLocal				DATETIME = NULL,
			@strSourceTransactionLocal	NVARCHAR(100) = NULL,
			@strCustomerIdsLocal		NVARCHAR(MAX) = NULL,
			@strSalespersonIdsLocal		NVARCHAR(MAX) = NULL,		
			@strCompanyLocationIdsLocal NVARCHAR(MAX) = NULL,
			@strCompanyNameIdsLocal		NVARCHAR(MAX) = NULL,
			@strAccountStatusIdsLocal	NVARCHAR(MAX) = NULL,
			@strCompanyName				NVARCHAR(100) = NULL,
			@strCompanyAddress			NVARCHAR(500) = NULL,
			@intEntityUserIdLocal		INT = NULL,
			@intGracePeriodLocal		INT = 0,
			@ysnOverrideCashFlowLocal  	BIT = 0,
			@strCustomerAgingBy		    NVARCHAR(250) = NULL

	DECLARE  @DELCUSTOMERS		Id
			,@COMPANY			Id
			,@DECOMPANY			Id
			,@ADLOCATION		Id
			,@DELLOCATION		Id
			,@DELACCOUNTSTATUS	Id
			,@ADSALESPERSON		Id
	
	DECLARE @ADCUSTOMERS TABLE 
	(
		 intEntityCustomerId	INT	NOT NULL PRIMARY KEY
		,strCustomerNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCustomerName		NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCreditLimit			NUMERIC(18, 6)
	)

	DECLARE @ADACCOUNTSTATUS TABLE (
		 intAccountStatusId INT
		,intEntityCustomerId INT
	)

	DECLARE @ARPOSTEDPAYMENT TABLE (
		 intPaymentId			INT												NOT NULL PRIMARY KEY
		,dtmDatePaid			DATETIME										NULL
		,dblAmountPaid			NUMERIC(18, 6)									NULL DEFAULT 0
		,ysnInvoicePrepayment	BIT												NULL INDEX IX1 NONCLUSTERED
		,intPaymentMethodId		INT												NULL
		,strRecordNumber		NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
	)

	DECLARE @INVOICETOTALPREPAYMENTS TABLE (
		 intInvoiceId	INT				NOT NULL PRIMARY KEY
		,dblPayment		NUMERIC(18, 6)	NULL DEFAULT 0
		,dblBasePayment	NUMERIC(18, 6)	NULL DEFAULT 0
		,dblABSPayment	NUMERIC(18, 6)	NULL DEFAULT 0
	)

	DECLARE @GLACCOUNTS TABLE (	
		 intAccountId		INT												NOT NULL PRIMARY KEY
		,strAccountCategory	NVARCHAR (100)   COLLATE Latin1_General_CI_AS	NULL
	)

	DECLARE @CASHREFUNDS TABLE (
		 intOriginalInvoiceId		INT												NULL
		,strDocumentNumber			NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
		,dblRefundTotal				NUMERIC(18, 6)									NULL DEFAULT 0
		,dblBaseRefundTotal			NUMERIC(18, 6)									NULL DEFAULT 0
	)

	DECLARE @CASHRETURNS TABLE (
		 intInvoiceId			INT												NOT NULL PRIMARY KEY
		,intOriginalInvoiceId	INT												NULL
		,dblInvoiceTotal		NUMERIC(18, 6)									NULL DEFAULT 0
		,dblBaseInvoiceTotal	NUMERIC(18, 6)									NULL DEFAULT 0
		,strInvoiceOriginId		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,strInvoiceNumber		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,dtmPostDate			DATETIME										NULL
	)

	DECLARE @FORGIVENSERVICECHARGE TABLE (
		 intInvoiceId		INT												NOT NULL PRIMARY KEY
		,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	)

	DECLARE @CREDITMEMOPAIDREFUNDED TABLE (
		 intInvoiceId		INT												NOT NULL PRIMARY KEY
		,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,strDocumentNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	)

	DECLARE @CANCELLEDINVOICE TABLE (
		 intInvoiceId		INT												NOT NULL PRIMARY KEY
		,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,ysnPaid			BIT												NULL
	)

	DECLARE @CANCELLEDCMINVOICE TABLE (
		 intInvoiceId		INT												NOT NULL PRIMARY KEY
		,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	)

	DECLARE @POSTEDINVOICES TABLE (
	     intInvoiceId				INT												NOT NULL	PRIMARY KEY
		,intEntityCustomerId		INT												NOT NULL	INDEX IX1 NONCLUSTERED
		,intPaymentId				INT												NULL		INDEX IX2 NONCLUSTERED
		,intCompanyLocationId		INT												NULL
		,intEntitySalespersonId		INT												NULL
		,strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL	INDEX IX3 NONCLUSTERED
		,strType					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' 
		,strBOLNumber				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
		,strInvoiceNumber			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,dblInvoiceTotal			NUMERIC(18, 6)									NULL DEFAULT 0
		,dblAmountDue				NUMERIC(18, 6)									NULL DEFAULT 0
		,dblDiscount				NUMERIC(18, 6)									NULL DEFAULT 0
		,dblInterest				NUMERIC(18, 6)									NULL DEFAULT 0
		,dtmPostDate				DATETIME										NULL
		,dtmDueDate					DATETIME										NULL
		,dtmDate					DATETIME										NULL
		,dtmForgiveDate				DATETIME										NULL
		,ysnForgiven				BIT												NULL
		,ysnPaid					BIT												NULL
		,dblBaseInvoiceTotal		NUMERIC(18, 6)									NULL DEFAULT 0
		,intCurrencyId				INT												NULL
		,strCurrency				NVARCHAR(40)									NULL
		,dblCurrencyExchangeRate	NUMERIC(18, 6)									NULL DEFAULT 0
		,dblCurrencyRevalueRate		NUMERIC(18, 6)									NULL DEFAULT 0
		,dblCurrencyRevalueAmount	NUMERIC(18, 6)									NULL DEFAULT 0
		,intAccountId				INT												NULL
	)

	DECLARE @UNPAIDINVOICES TABLE 
	(
		 intInvoiceId	INT	NOT NULL PRIMARY KEY
	)

	SET @dtmDateFromLocal			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
	SET	@dtmDateToLocal				= ISNULL(@dtmDateTo, GETDATE())
	SET @strSourceTransactionLocal	= NULLIF(@strSourceTransaction, '')
	SET @strCustomerIdsLocal		= NULLIF(@strCustomerIds, '')
	SET @strSalespersonIdsLocal		= NULLIF(@strSalespersonIds, '')
	SET @strCompanyLocationIdsLocal	= NULLIF(@strCompanyLocationIds, '')
	SET @strCompanyNameIdsLocal		= NULLIF(@strCompanyNameIds, '')
	SET @strAccountStatusIdsLocal	= NULLIF(@strAccountStatusIds, '')
	SET @intEntityUserIdLocal		= NULLIF(@intEntityUserId, 0)
	SET @intGracePeriodLocal		= ISNULL(@intGracePeriod, 0)
	SET @ysnOverrideCashFlowLocal  	= ISNULL(@ysnOverrideCashFlow, 0)
	SET @dtmDateFromLocal			= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateFromLocal)))
	SET @dtmDateToLocal				= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateToLocal)))

	SELECT TOP 1 @strCompanyName	= strCompanyName
			   , @strCompanyAddress = strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
	ORDER BY intCompanySetupID DESC

	SELECT TOP 1 @strCustomerAgingBy = strCustomerAgingBy
	FROM tblARCompanyPreference WITH (NOLOCK)

	IF ISNULL(@strCustomerIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @DELCUSTOMERS
		SELECT DISTINCT intID		
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)		

		INSERT INTO @ADCUSTOMERS
		SELECT C.intEntityId 
				, C.strCustomerNumber
				, EC.strName
				, C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN @DELCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intId
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
	END
	ELSE
	BEGIN
		INSERT INTO @ADCUSTOMERS
		SELECT C.intEntityId 
				, C.strCustomerNumber
				, EC.strName
				, C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
	END

	IF ISNULL(@strCompanyLocationIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @DELLOCATION
		SELECT DISTINCT intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strCompanyLocationIdsLocal)	
		
		INSERT INTO @ADLOCATION
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
		INNER JOIN @DELLOCATION COMPANYLOCATION ON CL.intCompanyLocationId = COMPANYLOCATION.intId
	END
	ELSE
	BEGIN
		INSERT INTO @ADLOCATION
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
	END

	IF ISNULL(@strCompanyNameIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @DECOMPANY
		SELECT DISTINCT intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strCompanyNameIdsLocal)	
		
		INSERT INTO @COMPANY
		SELECT GL.intAccountId
		FROM dbo.vyuARDistinctGLCompanyAccountIds GL WITH (NOLOCK) 
		INNER JOIN @DECOMPANY COMPANY ON GL.intAccountId = COMPANY.intId
	END
	ELSE
	BEGIN
		INSERT INTO @COMPANY
		SELECT GL.intAccountId
		FROM dbo.vyuARDistinctGLCompanyAccountIds GL WITH (NOLOCK) 
	END

	IF ISNULL(@strAccountStatusIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @DELACCOUNTSTATUS
		SELECT DISTINCT intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strAccountStatusIdsLocal)	

		INSERT INTO @ADACCOUNTSTATUS (
				intAccountStatusId
			, intEntityCustomerId
		)
		SELECT intAccountStatusId	= ACCS.intAccountStatusId
				, intEntityCustomerId	= CAS.intEntityCustomerId
		FROM dbo.tblARAccountStatus ACCS WITH (NOLOCK) 
		INNER JOIN tblARCustomerAccountStatus CAS ON ACCS.intAccountStatusId = CAS.intAccountStatusId
		INNER JOIN @DELACCOUNTSTATUS ACCOUNTSTATUS ON ACCS.intAccountStatusId = ACCOUNTSTATUS.intId

		IF ISNULL(@ysnExcludeAccountStatus, 0) = 0
			BEGIN
				DELETE CUSTOMERS 
				FROM @ADCUSTOMERS CUSTOMERS
				LEFT JOIN @ADACCOUNTSTATUS ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NULL
			END
		ELSE 
			BEGIN
				DELETE CUSTOMERS 
				FROM @ADCUSTOMERS CUSTOMERS
				INNER JOIN @ADACCOUNTSTATUS ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NOT NULL
			END
	END

	--@ARPOSTEDPAYMENT
	INSERT INTO @ARPOSTEDPAYMENT (
		   intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
		 , strRecordNumber
	)
	SELECT intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
		 , strRecordNumber
	FROM dbo.tblARPayment P WITH (NOLOCK)
	INNER JOIN @ADCUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN dbo.tblARNSFStagingTableDetail NSF ON P.intPaymentId = NSF.intTransactionId AND NSF.strTransactionType = 'Payment'
	WHERE P.ysnPosted = 1
	  AND (P.ysnProcessedToNSF = 0 OR (P.ysnProcessedToNSF = 1 AND NSF.dtmDate > @dtmDateToLocal))
	  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	--@INVOICETOTALPREPAYMENTS
	INSERT INTO @INVOICETOTALPREPAYMENTS (
		  intInvoiceId
		, dblPayment
		, dblBasePayment
		, dblABSPayment
	)
	SELECT intInvoiceId 	= PD.intInvoiceId
		 , dblPayment		= SUM(PD.dblPayment) + SUM(PD.dblWriteOffAmount)
		 , dblBasePayment	= SUM(PD.dblBasePayment) + SUM(PD.dblBaseWriteOffAmount)
		 , dblABSPayment	= ABS(SUM(PD.dblPayment) + SUM(PD.dblWriteOffAmount))
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
	INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
	INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
	WHERE PD.intInvoiceId IS NOT NULL
	  AND I.strTransactionType = 'Customer Prepayment'
	  AND I.ysnProcessedToNSF = 0
	GROUP BY PD.intInvoiceId

	--@GLACCOUNTS
	INSERT INTO @GLACCOUNTS (
		 intAccountId
		,strAccountCategory
	)
	SELECT intAccountId
		 , strAccountCategory
	FROM vyuGLAccountDetail
	WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'AP Account')
	GROUP BY intAccountId,
			 strAccountCategory

	--@FORGIVENSERVICECHARGE
	INSERT INTO @FORGIVENSERVICECHARGE (
		 intInvoiceId
		,strInvoiceNumber
	)
	SELECT SC.intInvoiceId
		 , SC.strInvoiceNumber
	FROM tblARInvoice I
	INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN @ADLOCATION CL ON I.intCompanyLocationId = CL.intId
	INNER JOIN @COMPANY CO ON I.intAccountId = CO.intId
	INNER JOIN tblARInvoice SC ON I.strInvoiceOriginId = SC.strInvoiceNumber
	WHERE I.strInvoiceOriginId IS NOT NULL 
	  AND I.strTransactionType = 'Credit Memo' 
	  AND I.strType = 'Standard'
	  AND SC.strTransactionType = 'Invoice'
	  AND SC.strType = 'Service Charge'
	  AND SC.ysnForgiven = 1

	--@CREDITMEMOPAIDREFUNDED
	INSERT INTO @CREDITMEMOPAIDREFUNDED (
		 intInvoiceId
		,strInvoiceNumber
		,strDocumentNumber
	)
	SELECT I.intInvoiceId,I.strInvoiceNumber,REFUND.strDocumentNumber
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN @ADLOCATION CL ON I.intCompanyLocationId = CL.intId
	INNER JOIN @COMPANY CO ON I.intAccountId = CO.intId
	INNER JOIN(
		SELECT ID.strDocumentNumber from tblARInvoice INV
		INNER JOIN tblARInvoiceDetail ID ON INV.intInvoiceId=ID.intInvoiceId
		where   strTransactionType='Cash Refund' and ysnPosted = 1
	)REFUND ON REFUND.strDocumentNumber = I.strInvoiceNumber
	WHERE I.ysnPosted = 1 
		AND I.ysnPaid = 1
		--AND ysnCancelled = 0
		AND I.strTransactionType <> 'Cash Refund'
		AND I.strTransactionType = 'Credit Memo'
		AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
		AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

	INSERT INTO @CANCELLEDINVOICE (
		 intInvoiceId
		,strInvoiceNumber
		,ysnPaid
	)
	SELECT  INVCANCELLED.intInvoiceId,INVCANCELLED.strInvoiceNumber,INVCANCELLED.ysnPaid 
	FROM tblARInvoice INVCANCELLED
	WHERE ysnCancelled =1 and ysnPosted =1
	AND INVCANCELLED.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	

	INSERT INTO @CANCELLEDCMINVOICE (
		 intInvoiceId
		,strInvoiceNumber
	)
	SELECT CM.intInvoiceId,CM.strInvoiceNumber 
	FROM tblARInvoice CM
	WHERE CM.intOriginalInvoiceId IN (SELECT intInvoiceId FROM @CANCELLEDINVOICE WHERE ISNULL(ysnPaid, 0) = 0)
	AND CM.ysnPosted =1
	AND CM.strTransactionType = 'Credit Memo'
	AND CM.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	--@POSTEDINVOICES
	INSERT INTO @POSTEDINVOICES (
		   intInvoiceId
		 , intEntityCustomerId
		 , intPaymentId
		 , intCompanyLocationId
		 , intEntitySalespersonId
		 , strTransactionType
		 , strType
		 , strBOLNumber
		 , strInvoiceNumber
		 , dblInvoiceTotal
		 , dblAmountDue
		 , dblDiscount
		 , dblInterest
		 , dtmPostDate
		 , dtmDueDate
		 , dtmDate
		 , ysnPaid
		 , dblBaseInvoiceTotal
		 , intCurrencyId
		 , strCurrency
		 , dblCurrencyExchangeRate
		 , dblCurrencyRevalueRate
		 , dblCurrencyRevalueAmount
		 , intAccountId
	)
	SELECT intInvoiceId				= I.intInvoiceId
		 , intEntityCustomerId		= I.intEntityCustomerId
		 , intPaymentId				= I.intPaymentId	
		 , intCompanyLocationId		= I.intCompanyLocationId
		 , intEntitySalespersonId	= I.intEntitySalespersonId
		 , strTransactionType		= I.strTransactionType
		 , strType					= I.strType
		 , strBOLNumber				= I.strBOLNumber
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , dblInvoiceTotal			= I.dblInvoiceTotal
		 , dblAmountDue				= I.dblAmountDue
		 , dblDiscount				= I.dblDiscount
		 , dblInterest				= I.dblInterest
		 , dtmPostDate				= I.dtmPostDate
		 , dtmDueDate				= CASE WHEN I.ysnOverrideCashFlow = 1 AND @ysnOverrideCashFlowLocal = 1 THEN I.dtmCashFlowDate ELSE DATEADD(DAYOFYEAR, @intGracePeriodLocal, I.dtmDueDate) END 
		 , dtmDate					= CAST(I.dtmDate AS DATE)
		 , ysnPaid					= I.ysnPaid
		 , dblBaseInvoiceTotal		= I.dblBaseInvoiceTotal
		 , intCurrencyId			= I.intCurrencyId
		 , strCurrency				= CUR.strCurrency
		 , dblCurrencyExchangeRate	= I.dblCurrencyExchangeRate
		 , dblCurrencyRevalueRate	= ISNULL(GLRD.dblNewForexRate, 0)
		 , dblCurrencyRevalueAmount	= ISNULL(GLRD.dblNewAmount, 0)
		 , intAccountId				= I.intAccountId
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN @ADLOCATION CL ON I.intCompanyLocationId = CL.intId
	INNER JOIN @COMPANY CO ON I.intAccountId = CO.intId
	LEFT JOIN @FORGIVENSERVICECHARGE SC ON I.intInvoiceId = SC.intInvoiceId 
	INNER JOIN @GLACCOUNTS GL ON GL.intAccountId = I.intAccountId AND (GL.strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND GL.strAccountCategory = 'AP Account'))
	LEFT JOIN (
		SELECT strTransactionId, dblNewForexRate, dblNewAmount
		FROM vyuGLRevalueDetails
		GROUP BY strTransactionId, dblNewForexRate, dblNewAmount
	) GLRD ON I.strInvoiceNumber = GLRD.strTransactionId 
	LEFT JOIN (
		SELECT intCurrencyID
			 , strCurrency 
		FROM tblSMCurrency WITH (NOLOCK)  
	) CUR ON I.intCurrencyId = CUR.intCurrencyID
	WHERE I.ysnPosted = 1  
	  AND I.ysnProcessedToNSF = 0
	  AND I.strTransactionType <> 'Cash Refund'
	  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ( 
			(SC.intInvoiceId IS NULL AND ((I.strType = 'Service Charge' AND (@dtmDateToLocal < I.dtmForgiveDate)) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0))))
			OR 
			SC.intInvoiceId IS NOT NULL
		)	

	IF @ysnPaidInvoice = 0
		DELETE FROM @POSTEDINVOICES WHERE ysnPaid = 1

	IF @strSourceTransactionLocal IS NOT NULL
		DELETE FROM @POSTEDINVOICES WHERE strType <> @strSourceTransactionLocal

	--@CASHREFUNDS
	INSERT INTO @CASHREFUNDS (
		   intOriginalInvoiceId
		 , strDocumentNumber
		 , dblRefundTotal
		 , dblBaseRefundTotal
	)
	SELECT intOriginalInvoiceId	= I.intOriginalInvoiceId
		 , strDocumentNumber	= ID.strDocumentNumber
		 , dblRefundTotal		= SUM(ID.dblTotal)
		 , dblBaseRefundTotal	= SUM(ID.dblBaseTotal)
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN @ADLOCATION CL ON I.intCompanyLocationId = CL.intId
	INNER JOIN @COMPANY CO ON I.intAccountId = CO.intId
	WHERE I.strTransactionType = 'Cash Refund'
	  AND I.ysnPosted = 1
	  AND (I.intOriginalInvoiceId IS NOT NULL OR (ID.strDocumentNumber IS NOT NULL AND ID.strDocumentNumber <> ''))
	  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal  
	GROUP BY I.intOriginalInvoiceId, ID.strDocumentNumber

	DELETE FROM @POSTEDINVOICES
	WHERE strInvoiceNumber IN (SELECT CF.strDocumentNumber FROM @CASHREFUNDS CF INNER  JOIN @CREDITMEMOPAIDREFUNDED CMPF ON CF.strDocumentNumber = CMPF.strDocumentNumber) 

	DELETE FROM @POSTEDINVOICES
	WHERE intInvoiceId IN (SELECT intInvoiceId FROM @CANCELLEDINVOICE)

	DELETE FROM @POSTEDINVOICES
	WHERE intInvoiceId IN (SELECT intInvoiceId FROM @CANCELLEDCMINVOICE)

	--@CASHRETURNS
	INSERT INTO @CASHRETURNS (
		   intInvoiceId
		 , intOriginalInvoiceId
		 , dblInvoiceTotal
		 , dblBaseInvoiceTotal
		 , strInvoiceOriginId
		 , strInvoiceNumber
		 , dtmPostDate
	)
	SELECT I.intInvoiceId
		 , I.intOriginalInvoiceId
		 , I.dblInvoiceTotal
		 , I.dblBaseInvoiceTotal
		 , I.strInvoiceOriginId
		 , I.strInvoiceNumber
		 , I.dtmPostDate
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN tblARInvoice RI ON I.intOriginalInvoiceId = RI.intInvoiceId AND I.strInvoiceOriginId = RI.strInvoiceNumber
	WHERE I.ysnPosted = 1
	  AND I.ysnRefundProcessed = 1
	  AND I.strTransactionType = 'Credit Memo'
	  AND I.intOriginalInvoiceId IS NOT NULL
	  AND (I.strInvoiceOriginId IS NOT NULL AND I.strInvoiceOriginId <> '')
	  AND (RI.ysnReturned IS NULL OR RI.ysnReturned = 0)
	  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	IF ISNULL(@strSalespersonIdsLocal, '') <> ''
		BEGIN
			INSERT INTO @ADSALESPERSON
			SELECT SP.intEntityId
			FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
			INNER JOIN (
				SELECT intID
				FROM dbo.fnGetRowsFromDelimitedValues(@strSalespersonIdsLocal)
			) SALESPERSON ON SP.intEntityId = SALESPERSON.intID

			DELETE INVOICES
			FROM @POSTEDINVOICES INVOICES
			LEFT JOIN @ADSALESPERSON SALESPERSON ON INVOICES.intEntitySalespersonId = SALESPERSON.intId
			WHERE SALESPERSON.intId IS NULL 
		END
		
	INSERT INTO @tempReturntable
	SELECT strCustomerName		= CUSTOMER.strCustomerName
		 , strCustomerNumber	= CUSTOMER.strCustomerNumber
		 , strCustomerInfo		= CUSTOMER.strCustomerName + CHAR(13) + CUSTOMER.strCustomerNumber
		 , strInvoiceNumber		= AGING.strInvoiceNumber
		 , strRecordNumber		= AGING.strRecordNumber
		 , intInvoiceId			= AGING.intInvoiceId
		 , intPaymentId			= AGING.intPaymentId
		 , strBOLNumber			= AGING.strBOLNumber
		 , intEntityCustomerId  = AGING.intEntityCustomerId
		 , intEntityUserId		= @intEntityUserIdLocal
		 , dblCreditLimit		= ISNULL(CUSTOMER.dblCreditLimit, 0)
		 , dblTotalAR			= ISNULL(AGING.dblTotalAR, 0)
		 , dblTotalCustomerAR	= ISNULL(AGING.dblTotalAR, 0)
		 , dblFuture			= ISNULL(AGING.dblFuture, 0)
		 , dbl0Days				= ISNULL(AGING.dbl0Days, 0)
		 , dbl10Days			= ISNULL(AGING.dbl10Days, 0)
		 , dbl30Days			= ISNULL(AGING.dbl30Days, 0)
		 , dbl60Days			= ISNULL(AGING.dbl60Days, 0)
		 , dbl90Days			= ISNULL(AGING.dbl90Days, 0)
		 , dbl120Days			= CASE WHEN @ysnInclude120Days = 0 THEN ISNULL(AGING.dbl120Days, 0) + ISNULL(AGING.dbl121Days, 0) ELSE ISNULL(AGING.dbl120Days, 0) END
		 , dbl121Days			= CASE WHEN @ysnInclude120Days = 0 THEN 0 ELSE ISNULL(AGING.dbl121Days, 0) END
		 , dblTotalDue			= ISNULL(AGING.dblTotalDue, 0)
		 , dblAmountPaid		= ISNULL(AGING.dblAmountPaid, 0)
		 , dblInvoiceTotal		= ISNULL(AGING.dblInvoiceTotal, 0)
		 , dblCredits			= ISNULL(AGING.dblCredits, 0)
		 , dblPrepayments		= ISNULL(AGING.dblPrepayments, 0)
		 , dblPrepaids			= ISNULL(AGING.dblPrepayments, 0)
		 , dtmDate				= AGING.dtmDate
		 , dtmDueDate			= AGING.dtmDueDate
		 , dtmAsOfDate			= @dtmDateToLocal
		 , strSalespersonName	= 'strSalespersonName'
		 , intCompanyLocationId	= AGING.intCompanyLocationId
		 , strSourceTransaction	= @strSourceTransactionLocal
		 , strType				= AGING.strType
		 , strTransactionType	= AGING.strTransactionType
		 , strCompanyName		= @strCompanyName
		 , strCompanyAddress	= @strCompanyAddress
		 , strAgingType			= 'Detail'
		 , intCurrencyId		= AGING.intCurrencyId
		 , strCurrency			= AGING.strCurrency
		 , dblHistoricRate		= AGING.dblCurrencyExchangeRate
		 , dblHistoricAmount	= ISNULL(AGING.dblBaseTotalAR, 0)
		 , dblEndOfMonthRate	= CASE WHEN AGING.dblCurrencyRevalueRate = 0 THEN AGING.dblCurrencyExchangeRate ELSE AGING.dblCurrencyRevalueRate END
		 , dblEndOfMonthAmount	= CASE WHEN AGING.dblCurrencyRevalueRate = 0 THEN ISNULL(AGING.dblBaseTotalAR, 0) ELSE AGING.dblCurrencyRevalueAmount END
		 , intAccountId			= AGING.intAccountId
	FROM
	(SELECT A.strInvoiceNumber
		 , B.strRecordNumber
		 , A.intInvoiceId
		 , B.intPaymentId	 
		 , A.strBOLNumber
		 , A.intEntityCustomerId
		 , dblTotalAR				= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
		 , dblFuture				= B.dblFuture
		 , dbl0Days					= B.dbl0Days
		 , dbl10Days				= B.dbl10Days
		 , dbl30Days				= B.dbl30Days
		 , dbl60Days				= B.dbl60Days
		 , dbl90Days				= B.dbl90Days
		 , dbl120Days				= B.dbl120Days
		 , dbl121Days				= B.dbl121Days
		 , dblTotalDue				= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
		 , dblAmountPaid			= B.dblAmountPaid
		 , dblInvoiceTotal			= A.dblInvoiceTotal
		 , dblCredits				= B.dblAvailableCredit * -1
		 , dblPrepayments			= B.dblPrepayments * -1	 
		 , dtmDate					= ISNULL(B.dtmDatePaid, A.dtmDate)
		 , dtmDueDate	 
		 , intCompanyLocationId
		 , strType
		 , strTransactionType
		 , dblBaseTotalAR			= B.dblBaseTotalDue - B.dblBaseAvailableCredit - B.dblBasePrepayments
		 , intCurrencyId			= A.intCurrencyId
		 , strCurrency				= A.strCurrency
		 , dblCurrencyExchangeRate	= A.dblCurrencyExchangeRate
		 , dblCurrencyRevalueRate	= A.dblCurrencyRevalueRate
		 , dblCurrencyRevalueAmount = A.dblCurrencyRevalueAmount
		 , intAccountId				= A.intAccountId
	FROM
	(SELECT dtmDate				= I.dtmDate
		 , I.strInvoiceNumber
		 , I.intCompanyLocationId
		 , I.intInvoiceId
		 , I.strBOLNumber
		 , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
		 , I.intEntityCustomerId
		 , I.dtmDueDate
		 , I.strType
		 , I.strTransactionType
		 , I.intCurrencyId
		 , I.strCurrency
		 , I.dblCurrencyExchangeRate
		 , I.dblCurrencyRevalueRate
		 , I.dblCurrencyRevalueAmount
		 , I.intAccountId
		 , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
					ELSE CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 0 THEN 'Current'
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
							  WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN I.dtmDate ELSE I.dtmDueDate END ), @dtmDateToLocal) > 120 THEN 'Over 120' END
					END
	FROM @POSTEDINVOICES I) AS A

	LEFT JOIN
    
	(SELECT  
		intEntityCustomerId
	  , intInvoiceId
	  , intPaymentId
	  , dblAmountPaid
	  , dtmDatePaid
	  , dblTotalDue			= dblInvoiceTotal - dblAmountPaid
	  , dblBaseTotalDue		= dblBaseInvoiceTotal - dblBaseAmountPaid
	  , dblAvailableCredit
	  , dblBaseAvailableCredit
	  , dblPrepayments
	  , dblBasePrepayments
	  , strRecordNumber
	   , CASE WHEN strType = 'CF Tran' 
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dblFuture
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 0 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl0Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 10 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl10Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 30 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl30Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 60 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl60Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 90 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl90Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 120 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl120Days
	  , CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 120 AND strType <> 'CF Tran'
  				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl121Days 
	FROM
	(SELECT I.intInvoiceId
		  , intPaymentId			= NULL
		  , dblAmountPaid			= 0
		  , dblBaseAmountPaid		= 0
		  , dblInvoiceTotal			= ISNULL(dblInvoiceTotal,0)
		  , dblBaseInvoiceTotal		= ISNULL(dblBaseInvoiceTotal,0)
		  , I.dtmDueDate
		  , I.dtmDate
		  , dtmDatePaid				= NULL
		  , I.intEntityCustomerId
		  , dblAvailableCredit		= 0
		  , dblBaseAvailableCredit	= 0
		  , dblPrepayments			= 0
		  , dblBasePrepayments		= 0
		  , I.strType
		  , strRecordNumber			= NULL
	FROM @POSTEDINVOICES I
	WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')

	UNION ALL

	SELECT I.intInvoiceId
		 , intPaymentId				= P.intPaymentId
		 , dblAmountPaid			= 0
		 , dblBaseAmountPaid		= 0
		 , dblInvoiceTotal			= 0
		 , dblBaseInvoiceTotal		= 0
		 , dtmDueDate				= ISNULL(P.dtmDatePaid, I.dtmDueDate)
		 , dtmDate					= ISNULL(P.dtmDatePaid, I.dtmDate)
		 , dtmDatePaid				= NULL
		 , I.intEntityCustomerId
		 , dblAvailableCredit		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) + ISNULL(APD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
		 , dblBaseAvailableCredit	= ISNULL(I.dblBaseInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) + ISNULL(APD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
		 , dblPrepayments			= 0
		 , dblBasePrepayments		= 0
		 , I.strType
		 , strRecordNumber		= P.strRecordNumber
	FROM @POSTEDINVOICES I
	LEFT JOIN @ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) + SUM(dblWriteOffAmount)
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
		INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) * -1
			 , APD.intInvoiceId
		FROM dbo.tblAPPaymentDetail APD WITH (NOLOCK)
		INNER JOIN tblAPPayment P ON APD.intPaymentId = P.intPaymentId
		WHERE P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
		  AND APD.intInvoiceId IS NOT NULL
		GROUP BY APD.intInvoiceId
	) APD ON I.intInvoiceId = APD.intInvoiceId
	LEFT JOIN @CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
	WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
	  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	UNION ALL

	SELECT I.intInvoiceId
		 , intPaymentId				= P.intPaymentId
		 , dblAmountPaid			= 0
		 , dblBaseAmountPaid		= 0
		 , dblInvoiceTotal			= 0
		 , dblBaseInvoiceTotal		= 0
		 , dtmDueDate				= ISNULL(P.dtmDatePaid, I.dtmDueDate)
		 , dtmDate					= ISNULL(P.dtmDatePaid, I.dtmDate)
		 , dtmDatePaid				= P.dtmDatePaid
		 , I.intEntityCustomerId
		 , dblAvailableCredit		= 0
		 , dblBaseAvailableCredit	= 0
		 , dblPrepayments			= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
		 , dblBasePrepayments		= ISNULL(I.dblBaseInvoiceTotal, 0) + ISNULL(PD.dblBasePayment, 0) - ISNULL(CR.dblBaseRefundTotal, 0)
		 , I.strType
		 , strRecordNumber		= P.strRecordNumber
	FROM @POSTEDINVOICES I
		INNER JOIN @ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
		LEFT JOIN @INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN @CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
	WHERE I.strTransactionType = 'Customer Prepayment'
	  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	UNION ALL      
      
	SELECT 
		I.intInvoiceId
	  , intPaymentId			= PAYMENT.intPaymentId
	  , dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
	  , dblBaseAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblBaseTotalPayment, 0) END
	  , dblInvoiceTotal			= 0
	  , dblBaseInvoiceTotal		= 0
	  , dtmDueDate				= ISNULL(I.dtmDueDate, GETDATE())
	  , dtmDate					= ISNULL(I.dtmDate, GETDATE())
	  , dtmDatePaid				= PAYMENT.dtmDatePaid
	  , I.intEntityCustomerId
	  , dblAvailableCredit		= 0
	  , dblBaseAvailableCredit	= 0
	  , dblPrepayments			= 0
	  , dblBasePrepayments		= 0
	  , I.strType
	  , strRecordNumber		= PAYMENT.strRecordNumber
	FROM @POSTEDINVOICES I
	INNER JOIN (
		SELECT PD.intInvoiceId
			 , P.intPaymentId
			 , P.strRecordNumber
			 , P.dtmDatePaid
			 , dblTotalPayment		= ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) + ISNULL(PD.dblWriteOffAmount, 0) - ISNULL(PD.dblInterest, 0)
			 , dblBaseTotalPayment	= ISNULL(PD.dblBasePayment, 0) + ISNULL(PD.dblBaseDiscount, 0) + ISNULL(PD.dblBaseWriteOffAmount, 0) - ISNULL(PD.dblBaseInterest, 0)
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
		INNER JOIN @POSTEDINVOICES I ON PD.intInvoiceId = I.intInvoiceId
		WHERE I.strTransactionType IN ('Invoice', 'Debit Memo')

		UNION ALL 

		SELECT PD.intInvoiceId
			 , P.intPaymentId
			 , strRecordNumber	= strPaymentRecordNum
			 , P.dtmDatePaid
			 , dblTotalPayment		= ABS((ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)))
			 , dblBaseTotalPayment	= ABS((ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)))
		FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
				 , strPaymentRecordNum
				 , dtmDatePaid
			FROM dbo.tblAPPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
		) P ON PD.intPaymentId = P.intPaymentId
		WHERE PD.intInvoiceId IS NOT NULL
	
		UNION ALL

		SELECT intInvoiceId			= intOriginalInvoiceId
			 , intPaymentId			= NULL
			 , strRecordNumber		= strInvoiceNumber
			 , dtmDatePaid			= dtmPostDate
			 , dblTotalPayment		= dblInvoiceTotal
			 , dblBaseTotalPayment	= dblBaseInvoiceTotal
		FROM @CASHRETURNS	
	) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
	WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')
 
	) AS TBL) AS B    

	ON
	A.intEntityCustomerId	 = B.intEntityCustomerId
	AND A.intInvoiceId		 = B.intInvoiceId

	WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0) AS AGING
	INNER JOIN @ADCUSTOMERS CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId

	INSERT INTO @UNPAIDINVOICES
	SELECT DISTINCT intInvoiceId 
	FROM @tempReturntable 
	GROUP BY intInvoiceId 
	HAVING SUM(ISNULL(dblTotalAR, 0)) <> 0

	DELETE AGING
	FROM @tempReturntable AGING
	LEFT JOIN @UNPAIDINVOICES UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId
	WHERE ISNULL(UNPAID.intInvoiceId, 0) = 0
	AND intEntityUserId = @intEntityUserId 
	AND strAgingType = 'Detail'

	INSERT INTO @returntable
	SELECT * FROM @tempReturntable

	RETURN
END

GO