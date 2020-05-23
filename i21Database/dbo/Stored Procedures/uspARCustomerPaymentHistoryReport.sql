CREATE PROCEDURE [dbo].[uspARCustomerPaymentHistoryReport]
	@xmlParam NVARCHAR(MAX) = NULL,
	@customerId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT *
			, dblBareInvoiceTotal = cast(0 as numeric(18, 6))
			, rownum = 0
			, dblBareInvoiceTotalPayment = cast(0 as numeric(18, 6))
		FROM tblARCustomerStatementStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateTo				DATETIME
      , @dtmDateFrom			DATETIME
	  , @strCustomerName		NVARCHAR(100)
	  , @strRecordNumberFrom	NVARCHAR(100)
	  , @strRecordNumberTo		NVARCHAR(100)
	  , @strInvoiceNumberFrom	NVARCHAR(100)
	  , @strInvoiceNumberTo		NVARCHAR(100)
	  , @strPaymentMethod		NVARCHAR(100)
	  , @xmlDocumentId			INT
	  , @query					NVARCHAR(MAX)
	  , @filter					NVARCHAR(MAX) = ''
	  , @fieldname				NVARCHAR(50)
	  , @condition				NVARCHAR(20)
	  , @id						INT 
	  , @from					NVARCHAR(100)
	  , @to						NVARCHAR(100)
	  , @join					NVARCHAR(10)
	  , @begingroup				NVARCHAR(50)
	  , @endgroup				NVARCHAR(50)
	  , @datatype				NVARCHAR(50)
		
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(100)
	,[to]			NVARCHAR(100)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(100)
	, [to]		   NVARCHAR(100)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

-- Gather the variables values from the xml table.
SELECT  @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] IN ('strName', 'strCustomerName')

SELECT  @strRecordNumberFrom = ISNULL([from], '')
	  , @strRecordNumberTo = ISNULL([to], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strRecordNumber'

SELECT  @strInvoiceNumberFrom = ISNULL([from], '')
	  , @strInvoiceNumberTo = ISNULL([to], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strInvoiceNumber'

SELECT  @strPaymentMethod = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strPaymentMethod'

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	  , @dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmDatePaid'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)


IF OBJECT_ID('tempdb..#TmpPayments') IS NOT NULL DROP TABLE #TmpPayments


SELECT 
	rownm = ROW_NUMBER() OVER(PARTITION BY strInvoiceNumber ORDER BY strRecordNumber ASC)
	 , strCustomerName		= CUSTOMER.strName
	 , strCompanyName		= COMPANY.strCompanyName
     , strCompanyAddress	= COMPANY.strCompanyAddress
	 , strContact			= CUSTOMER.strFullAddress
	 , strPaid				= CASE WHEN PAYMENTS.dblAmountDue = 0 THEN 'Yes' ELSE 'No' END
	 --CASE WHEN PAYMENTS.dblInvoiceTotal - (dbo.fnARGetInvoiceAmountMultiplier(PAYMENTS.strTransactionType) * TOTALPAYMENTS.dblTotalPayments) = 0 THEN 'Yes' ELSE 'No' END
	 , PAYMENTS.*
	 , dblBareInvoiceTotal = cast(0 as numeric(18, 6))
	 , rownum = 0
	 , dblBareInvoiceTotalPayment = dbo.fnARGetInvoiceAmountMultiplier(PAYMENTS.strTransactionType) * TOTALPAYMENTS.dblTotalPayments
INTO #TmpPayments

FROM ( 
	SELECT I.strInvoiceNumber
		 , I.intEntityCustomerId
		 , I.intInvoiceId	 
		 , strRecordNumber		= PAYMENTS.strRecordNumber	 
		 , dtmDatePaid			= PAYMENTS.dtmDatePaid
		 , dblAmountPaid		= ISNULL(PAYMENTS.dblAmountPaid, 0)
		 , dblAmountApplied		= ISNULL(PAYMENTS.dblAmountApplied, 0)
		 , dblInvoiceTotal		= dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType) * I.dblInvoiceTotal
		 , dblAmountDue			= (dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType) * I.dblInvoiceTotal) - (ISNULL(PAYMENTS.dblAmountApplied, 0) + ISNULL(PAYMENTS.dblDiscount, 0) - ISNULL(PAYMENTS.dblInterest, 0)) -- CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(PAYMENTS.dblAmountDue, 0) * -1 ELSE ISNULL(PAYMENTS.dblAmountDue, 0) END
		 , intPaymentId			= PAYMENTS.intPaymentId	 
		 , strReferenceNumber	= PAYMENTS.strPaymentInfo
		 , strPaymentMethod		= PAYMENTS.strPaymentMethod
		 , dblUnappliedAmount	= ISNULL(PAYMENTS.dblUnappliedAmount, 0)
		 , strTransactionType	= I.strTransactionType
	FROM dbo.tblARInvoice I	WITH (NOLOCK)
	INNER JOIN (
		SELECT strRecordNumber	= P.strRecordNumber
			 , P.dtmDatePaid
			 , P.dblAmountPaid			 
			 , dblAmountApplied	= PD.dblPayment
			 , PD.dblDiscount
			 , PD.dblInterest
			 , P.intPaymentId
			 , P.intPaymentMethodId
			 , P.strPaymentInfo
			 , P.strPaymentMethod
			 , P.dblUnappliedAmount
			 , PD.intInvoiceId
			 , PD.dblAmountDue
		FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
				 , intInvoiceId
				 , dblPayment
				 , dblDiscount
				 , dblInterest
				 , dblAmountDue
			FROM dbo.tblARPaymentDetail 
		) PD ON P.intPaymentId = PD.intPaymentId
			AND P.strPaymentMethod <> 'CF Invoice'
		WHERE P.ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strPaymentMethod IS NULL OR strPaymentMethod LIKE '%'+@strPaymentMethod+'%' OR (@strPaymentMethod LIKE '%Credit Card%' AND P.intEntityCardInfoId IS NOT NULL))
		  AND (@strRecordNumberFrom IS NULL OR strRecordNumber LIKE '%'+@strRecordNumberFrom+'%')

		UNION ALL

		SELECT strRecordNumber		= APP.strPaymentRecordNum
			 , APP.dtmDatePaid
			 , APP.dblAmountPaid
			 , dblAmountApplied		= APPD.dblPayment
			 , APPD.dblDiscount
			 , APPD.dblInterest
			 , APP.intPaymentId
			 , APP.intPaymentMethodId
			 , APP.strPaymentInfo
			 , strPaymentMethod		= NULL
			 , dblUnappliedAmount	= APP.dblUnapplied
			 , APPD.intInvoiceId
			 , APPD.dblAmountDue
		FROM dbo.tblAPPayment APP WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
				 , intInvoiceId
				 , dblPayment
				 , dblDiscount
				 , dblInterest
				 , dblAmountDue
			FROM tblAPPaymentDetail WITH (NOLOCK)
		) APPD ON APP.intPaymentId = APPD.intPaymentId 
		WHERE APP.ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo	
		  AND (@strRecordNumberFrom IS NULL OR strPaymentRecordNum LIKE '%'+@strRecordNumberFrom+'%')
	) AS PAYMENTS ON I.intInvoiceId = PAYMENTS.intInvoiceId	
	WHERE I.ysnPosted = 1
	  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	  AND (@strInvoiceNumberFrom IS NULL OR strInvoiceNumber LIKE '%'+@strInvoiceNumberFrom+'%')

	UNION ALL

	SELECT I.strInvoiceNumber
		 , I.intEntityCustomerId
		 , I.intInvoiceId	 
		 , strRecordNumber		= PREPAYMENT.strRecordNumber	 
		 , dtmDatePaid			= PREPAYMENT.dtmDatePaid
		 , dblAmountPaid		= ISNULL(PREPAYMENT.dblAmountPaid, 0)
		 , dblAmountApplied		= 0
		 , dblInvoiceTotal		= 0
		 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END	 
		 , intPaymentId			= PREPAYMENT.intPaymentId	 
		 , strReferenceNumber	= PREPAYMENT.strPaymentInfo
		 , strPaymentMethod		= PREPAYMENT.strPaymentMethod
		 , dblUnappliedAmount	= ISNULL(PREPAYMENT.dblUnappliedAmount, 0)
		 , strTransactionType	= I.strTransactionType
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , intEntityCustomerId
		     , strRecordNumber
			 , strPaymentInfo
			 , strPaymentMethod
			 , dtmDatePaid
			 , dblUnappliedAmount
			 , dblAmountPaid
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strPaymentMethod IS NULL OR strPaymentMethod LIKE '%'+@strPaymentMethod+'%' OR (@strPaymentMethod LIKE '%Credit Card%' AND intEntityCardInfoId IS NOT NULL))
		  AND (@strRecordNumberFrom IS NULL OR strRecordNumber LIKE '%'+@strRecordNumberFrom+'%')
	) PREPAYMENT ON I.intEntityCustomerId = PREPAYMENT.intEntityCustomerId 
				AND I.intPaymentId = PREPAYMENT.intPaymentId
	WHERE I.ysnPosted = 1 
	  AND I.strTransactionType = 'Customer Prepayment'
	  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	  AND (@strInvoiceNumberFrom IS NULL OR strInvoiceNumber LIKE '%'+@strInvoiceNumberFrom+'%')
) PAYMENTS
INNER JOIN (
	SELECT E.intEntityId
		 , strName
		 , strFullAddress = dbo.fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, E.strBillToLocationName, E.strBillToAddress, E.strBillToCity, E.strBillToState, E.strBillToZipCode, E.strBillToCountry, NULL, 0)
	FROM dbo.vyuARCustomer E WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strPhone
			 , strEmail
		FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
		WHERE ysnDefaultContact = 1
	) CC ON E.intEntityId = CC.intEntityId
	WHERE  (( @customerId IS NULL AND (@strCustomerName IS NULL OR E.strName LIKE '%'+@strCustomerName+'%'))OR E.intEntityId = @customerId)
) CUSTOMER ON PAYMENTS.intEntityCustomerId = CUSTOMER.intEntityId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT intInvoiceId
		 , dblTotalPayments = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
	FROM dbo.tblARPaymentDetail PD
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	) P ON PD.intPaymentId = P.intPaymentId
	WHERE intInvoiceId = PAYMENTS.intInvoiceId	  
	GROUP BY intInvoiceId
) TOTALPAYMENTS

UPDATE #TmpPayments SET dblBareInvoiceTotal = dblInvoiceTotal, dblBareInvoiceTotalPayment = CASE WHEN strPaid = 'Yes' THEN dblInvoiceTotal ELSE 0 END WHERE rownm = 1

DECLARE @Tmp TABLE
(
	rownm INT,
	intInvoiceId INT,
	dblAmount NUMERIC(18,6)
)

INSERT INTO @Tmp
SELECT rownm, intInvoiceId, dblAmountApplied FROM #TmpPayments --WHERE rownm > 1

UPDATE A 
	SET dblAmountDue = dblAmountDue - D.dblAmount
	,strPaid = CASE WHEN dblAmountDue - D.dblAmount = 0 THEN 'Yes' ELSE 'No' END	
	FROM #TmpPayments A
		OUTER APPLY(
			select 
				intInvoiceId, 
				dblAmount = SUM(dblAmount) 
				from @Tmp C 
					where C.rownm < A.rownm and C.intInvoiceId = A.intInvoiceId
			GROUP BY intInvoiceId
		) D 
	WHERE A.rownm > 1

SELECT * FROM #TmpPayments

