CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailAsOfDateReport]
	@dtmDateFrom			DATETIME = NULL,
	@dtmDateTo				DATETIME = NULL,
	@strSalesperson			NVARCHAR(100) = NULL,
    @strSourceTransaction	NVARCHAR(100) = NULL,
	@strCompanyLocation		NVARCHAR(100) = NULL,
	@intEntityCustomerId    INT	= NULL,
	@strCustomerName		NVARCHAR(MAX) = NULL,
	@strAccountStatusCode	NVARCHAR(100) = NULL,
	@ysnInclude120Days		BIT = 0,
	@strCustomerIds			NVARCHAR(MAX) = NULL,
	@intEntityUserId		INT = NULL,
	@ysnPaidInvoice			BIT = NULL
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @dtmDateFromLocal			DATETIME = NULL,
		@dtmDateToLocal				DATETIME = NULL,
		@strSalespersonLocal		NVARCHAR(100) = NULL,
		@strSourceTransactionLocal	NVARCHAR(100) = NULL,
		@strCompanyLocationLocal    NVARCHAR(100) = NULL,
		@intEntityCustomerIdLocal   INT = NULL,
		@intCompanyLocationId		INT	= NULL,
		@strCustomerNameLocal		NVARCHAR(MAX) = NULL,
		@strAccountStatusCodeLocal	NVARCHAR(100) = NULL,
		@intSalespersonId			INT = NULL,
		@strCustomerIdsLocal		NVARCHAR(MAX)	= NULL,
		@intEntityUserIdLocal		INT = NULL

DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)
		
SET @dtmDateFromLocal			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET	@dtmDateToLocal				= ISNULL(@dtmDateTo, GETDATE())
SET @strSalespersonLocal		= NULLIF(@strSalesperson, '')
SET @strSourceTransactionLocal	= NULLIF(@strSourceTransaction, '')
SET @strCompanyLocationLocal	= NULLIF(@strCompanyLocation, '')
SET @intEntityCustomerIdLocal	= NULLIF(@intEntityCustomerId, 0)
SET @strCustomerNameLocal		= NULLIF(@strCustomerName, '')
SET @strAccountStatusCodeLocal	= NULLIF(@strAccountStatusCode, '')
SET @strCustomerIdsLocal		= NULLIF(@strCustomerIds, '')
SET @intEntityUserIdLocal		= NULLIF(@intEntityUserId, 0)

IF ISNULL(@intEntityCustomerIdLocal, 0) <> 0
	BEGIN
		INSERT INTO @tblCustomers
		SELECT TOP 1 C.intEntityId 
			       , C.strCustomerNumber
				   , EC.strName
				   , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE intEntityId = @intEntityCustomerIdLocal
		) EC ON C.intEntityId = EC.intEntityId
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO @tblCustomers
		SELECT C.intEntityId 
			 , C.strCustomerNumber
			 , EC.strName
			 , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) EC ON C.intEntityId = EC.intEntityId
	END
ELSE
	BEGIN
		INSERT INTO @tblCustomers
		SELECT C.intEntityId 
			 , C.strCustomerNumber
			 , EC.strName
			 , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		OUTER APPLY (
			SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
			FROM (
				SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
				FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
				INNER JOIN (
					SELECT intAccountStatusId
							, strAccountStatusCode
					FROM dbo.tblARAccountStatus WITH (NOLOCK)
				) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
				WHERE CAS.intEntityCustomerId = C.intEntityId
				FOR XML PATH ('')
			) SC (strAccountStatusCode)
		) STATUSCODES
		WHERE (@strAccountStatusCodeLocal IS NULL OR STATUSCODES.strAccountStatusCode LIKE '%'+ @strAccountStatusCodeLocal +'%')
	END

IF ISNULL(@strSalespersonLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intSalespersonId = SP.intEntityId
		FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strSalespersonLocal IS NULL OR strName = @strSalespersonLocal)
		) ES ON SP.intEntityId = ES.intEntityId
	END

IF ISNULL(@strCompanyLocationLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE (@strCompanyLocationLocal IS NULL OR strLocationName = @strCompanyLocationLocal)
	END

--DROP TEMP TABLES
IF(OBJECT_ID('tempdb..#ARPOSTEDPAYMENT') IS NOT NULL)
BEGIN
    DROP TABLE #ARPOSTEDPAYMENT
END

IF(OBJECT_ID('tempdb..#INVOICETOTALPREPAYMENTS') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICETOTALPREPAYMENTS
END

IF(OBJECT_ID('tempdb..#POSTEDINVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #POSTEDINVOICES
END

--#ARPOSTEDPAYMENT
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , strRecordNumber
INTO #ARPOSTEDPAYMENT
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON P.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND ysnProcessedToNSF = 0
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	

--#INVOICETOTALPREPAYMENTS
SELECT dblPayment = SUM(dblPayment)
		, PD.intInvoiceId
INTO #INVOICETOTALPREPAYMENTS
FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
GROUP BY PD.intInvoiceId

--#POSTEDINVOICES
SELECT I.intInvoiceId
	 , I.intPaymentId
	 , I.intEntityCustomerId
	 , I.intCompanyLocationId
	 , I.dtmPostDate
	 , I.dtmDueDate
	 , I.dtmDate
	 , I.strTransactionType
	 , I.strType
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dblInterest
	 , I.strBOLNumber
	 , I.strInvoiceNumber
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND (@ysnPaidInvoice is null or (ysnPaid = @ysnPaidInvoice))
	AND ysnCancelled = 0
	AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
	AND I.intAccountId IN (
		SELECT A.intAccountId
		FROM dbo.tblGLAccount A WITH (NOLOCK)
		INNER JOIN (SELECT intAccountSegmentId
						 , intAccountId
					FROM dbo.tblGLAccountSegmentMapping WITH (NOLOCK)
		) ASM ON A.intAccountId = ASM.intAccountId
		INNER JOIN (SELECT intAccountSegmentId
						 , intAccountCategoryId
						 , intAccountStructureId
					FROM dbo.tblGLAccountSegment WITH (NOLOCK)
		) GLAS ON ASM.intAccountSegmentId = GLAS.intAccountSegmentId
		INNER JOIN (SELECT intAccountStructureId                 
					FROM dbo.tblGLAccountStructure WITH (NOLOCK)
					WHERE strType = 'Primary'
		) AST ON GLAS.intAccountStructureId = AST.intAccountStructureId
		INNER JOIN (SELECT intAccountCategoryId
						 , strAccountCategory 
					FROM dbo.tblGLAccountCategory WITH (NOLOCK)
					WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
	)
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
	AND (@intCompanyLocationId IS NULL OR I.intCompanyLocationId = @intCompanyLocationId)
	AND (@intSalespersonId IS NULL OR intEntitySalespersonId = @intSalespersonId)
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')
	

DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
INSERT INTO tblARCustomerAgingStagingTable (
		  strCustomerName
		, strCustomerNumber
		, strCustomerInfo
		, strInvoiceNumber
		, strRecordNumber
		, intInvoiceId
		, strBOLNumber
		, intEntityCustomerId
		, intEntityUserId
		, dblCreditLimit
		, dblTotalAR
		, dblFuture
		, dbl0Days
		, dbl10Days
		, dbl30Days
		, dbl60Days
		, dbl90Days
		, dbl120Days
		, dbl121Days
		, dblTotalDue
		, dblAmountPaid
		, dblInvoiceTotal
		, dblCredits
		, dblPrepayments
		, dblPrepaids
		, dtmDate
		, dtmDueDate
		, dtmAsOfDate
		, strSalespersonName
		, intCompanyLocationId
		, strSourceTransaction
		, strType
		, strCompanyName
		, strCompanyAddress
		, strAgingType
)	
SELECT strCustomerName		= CUSTOMER.strCustomerName
	 , strCustomerNumber	= CUSTOMER.strCustomerNumber
	 , strCustomerInfo		= CUSTOMER.strCustomerName + CHAR(13) + CUSTOMER.strCustomerNumber
     , strInvoiceNumber		= AGING.strInvoiceNumber
	 , strRecordNumber		= AGING.strRecordNumber
	 , intInvoiceId			= AGING.intInvoiceId
	 , strBOLNumber			= AGING.strBOLNumber
	 , intEntityCustomerId  = AGING.intEntityCustomerId
	 , intEntityUserId		= @intEntityUserIdLocal
	 , dblCreditLimit		= CUSTOMER.dblCreditLimit
	 , dblTotalAR			= AGING.dblTotalAR
	 , dblFuture			= AGING.dblFuture
	 , dbl0Days				= AGING.dbl0Days
	 , dbl10Days			= AGING.dbl10Days
	 , dbl30Days			= AGING.dbl30Days
	 , dbl60Days			= AGING.dbl60Days
	 , dbl90Days			= AGING.dbl90Days
	 , dbl120Days			= CASE WHEN @ysnInclude120Days = 0 THEN AGING.dbl120Days + AGING.dbl121Days ELSE AGING.dbl120Days END
	 , dbl121Days			= CASE WHEN @ysnInclude120Days = 0 THEN 0 ELSE AGING.dbl121Days END
	 , dblTotalDue			= AGING.dblTotalDue
	 , dblAmountPaid		= AGING.dblAmountPaid
	 , dblInvoiceTotal		= AGING.dblInvoiceTotal
	 , dblCredits			= AGING.dblCredits
	 , dblPrepayments		= AGING.dblPrepayments
	 , dblPrepaids			= AGING.dblPrepayments
	 , dtmDate				= AGING.dtmDate
	 , dtmDueDate			= AGING.dtmDueDate
	 , dtmAsOfDate			= @dtmDateToLocal
	 , strSalespersonName	= 'strSalespersonName'
	 , intCompanyLocationId	= AGING.intCompanyLocationId
	 , strSourceTransaction	= @strSourceTransactionLocal
	 , strType				= AGING.strType
	 , strCompanyName		= COMPANY.strCompanyName
	 , strCompanyAddress	= COMPANY.strCompanyAddress
	 , strAgingType			= 'Detail'
FROM
(SELECT A.strInvoiceNumber
     , B.strRecordNumber
     , A.intInvoiceId	 
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblFuture			= B.dblFuture
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl120Days			= B.dbl120Days
	 , dbl121Days			= B.dbl121Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblAmountPaid		= B.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit * -1
	 , dblPrepayments		= B.dblPrepayments * -1	 
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , intCompanyLocationId
	 , strType
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
	 , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
				END
FROM #POSTEDINVOICES I WITH (NOLOCK)) AS A    

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , intInvoiceId
  , dblAmountPaid
  , dtmDatePaid
  , dblTotalDue		= dblInvoiceTotal - dblAmountPaid
  , dblAvailableCredit
  , dblPrepayments
  , strRecordNumber
  , CASE WHEN strType = 'CF Tran' 
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dblFuture
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 0 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 10 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 30 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 60 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 90 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl90Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 120 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl120Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 120 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl121Days 
FROM
(SELECT I.intInvoiceId
      , dblAmountPaid			= 0
      , dblInvoiceTotal			= ISNULL(dblInvoiceTotal,0)	  
	  , I.dtmDueDate
	  , dtmDatePaid				= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit		= 0
	  , dblPrepayments			= 0
	  , I.strType
	  , strRecordNumber			= NULL
FROM #POSTEDINVOICES I WITH (NOLOCK)
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , dtmDatePaid			= NULL
	 , I.intEntityCustomerId
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
	 , dblPrepayments		= 0
	 , I.strType
	 , strRecordNumber		= P.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
	LEFT JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment)
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId		
WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , dtmDatePaid			= P.dtmDatePaid
	 , I.intEntityCustomerId
	 , dblAvailableCredit	= 0
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
	 , I.strType
	 , strRecordNumber		= P.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
WHERE I.strTransactionType = 'Customer Prepayment'
						      
UNION ALL      
      
SELECT DISTINCT
	I.intInvoiceId
  , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
  , dblInvoiceTotal		= 0
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , dtmDatePaid			= PAYMENT.dtmDatePaid
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
  , dblPrepayments		= 0
  , I.strType
  , strRecordNumber		= PAYMENT.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
LEFT JOIN (
	SELECT PD.intInvoiceId
		 , P.strRecordNumber
		 , P.dtmDatePaid
		 , dblTotalPayment	= ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , strRecordNumber	= strPaymentRecordNum
		 , P.dtmDatePaid
		 , dblTotalPayment	= ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strPaymentRecordNum
			 , dtmDatePaid
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	) P ON PD.intPaymentId = P.intPaymentId	
) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo')
 
) AS TBL) AS B    

ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0) AS AGING
INNER JOIN @tblCustomers CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
