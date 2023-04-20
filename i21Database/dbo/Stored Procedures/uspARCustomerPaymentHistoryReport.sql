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


IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL) DROP TABLE #PAYMENTS
IF(OBJECT_ID('tempdb..#PAYMENTMETHODS') IS NOT NULL) DROP TABLE #PAYMENTMETHODS
IF(OBJECT_ID('tempdb..#TEMPHISTORY') IS NOT NULL) DROP TABLE #TEMPHISTORY
IF(OBJECT_ID('tempdb..#FINALPAYMENTHISTORY') IS NOT NULL) DROP TABLE #FINALPAYMENTHISTORY

CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT	NOT NULL PRIMARY KEY
	, strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerName			NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, strContact				NVARCHAR(500) COLLATE Latin1_General_CI_AS
)
CREATE TABLE #PAYMENTS (
	   intPaymentId					INT												NOT NULL
	 , strRecordNumber				NVARCHAR (25) COLLATE Latin1_General_CI_AS		NULL
	 , strPaymentMethod				NVARCHAR (100) COLLATE Latin1_General_CI_AS		NULL
	 , strReferenceNumber			NVARCHAR (50) COLLATE Latin1_General_CI_AS		NULL
	 , dtmDatePaid					DATETIME										NULL
	 , dblAmountPaid				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblUnappliedAmount			NUMERIC(18, 6)									NULL DEFAULT 0

	 , intInvoiceId					INT												NULL
	 , strInvoiceNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS		NULL
	 , dblInvoiceTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblAmountApplied				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18, 6)									NULL DEFAULT 0
	 , strPaid						NVARCHAR (5) COLLATE Latin1_General_CI_AS		NULL

	 , intEntityCustomerId			INT												NOT NULL
	 , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS		NULL
	 , strContact					NVARCHAR(500) COLLATE Latin1_General_CI_AS		NULL
	 , strCompanyName				NVARCHAR(200) COLLATE Latin1_General_CI_AS		NULL
	 , strCompanyAddress			NVARCHAR(500) COLLATE Latin1_General_CI_AS		NULL
)
CREATE TABLE #PAYMENTMETHODS (
	  intPaymentMethodId		INT	NOT NULL PRIMARY KEY
	, strPaymentMethod			NVARCHAR(200) COLLATE Latin1_General_CI_AS
)

DECLARE @strCompanyName			NVARCHAR(100)	= NULL
	  , @strCompanyAddress		NVARCHAR(500)	= NULL
	  , @intRecordNumberFrom	INT = NULL
	  , @intRecordNumberTo		INT = NULL
	  , @intInvoiceNumberFrom	INT = NULL
	  , @intInvoiceNumberTo		INT = NULL

SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--CUSTOMER FILTERS	
INSERT INTO #CUSTOMERS (
	  intEntityCustomerId
	, strCustomerNumber
	, strCustomerName
	, strContact
)
SELECT intEntityCustomerId	= C.intEntityId 
	, strCustomerNumber		= C.strCustomerNumber
	, strCustomerName		= EC.strName
	, strContact			= ISNULL(NULLIF(LTRIM(RTRIM(EL.strAddress)), ''), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(LTRIM(RTRIM(EL.strCity)), ''), '') + ISNULL(', ' + NULLIF(LTRIM(RTRIM(EL.strState)), ''), '') + ISNULL(', ' + NULLIF(LTRIM(RTRIM(EL.strZipCode)), ''), '') + ISNULL(', ' + NULLIF(LTRIM(RTRIM(EL.strCountry)), ''), '')
FROM tblARCustomer C WITH (NOLOCK)
INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityId AND EL.ysnDefaultLocation = 1
WHERE @strCustomerName IS NULL 
   OR (@strCustomerName IS NOT NULL AND EC.strName = @strCustomerName)

--RECORD NUMBER FILTERS
IF @strRecordNumberFrom IS NOT NULL
	BEGIN
		SELECT TOP 1 @intRecordNumberFrom = P.intPaymentId
		FROM tblARPayment P
		INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
		WHERE P.strRecordNumber = @strRecordNumberFrom
	END
ELSE 
	BEGIN
		SELECT @intRecordNumberFrom = MIN(P.intPaymentId)
		FROM tblARPayment P
		INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
	END

IF @strRecordNumberTo IS NOT NULL
	BEGIN
		SELECT TOP 1 @intRecordNumberTo = intPaymentId
		FROM tblARPayment P
		INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
		WHERE P.strRecordNumber = @strRecordNumberTo
	END
ELSE
	BEGIN
		SELECT @intRecordNumberTo = MAX(intPaymentId)
		FROM tblARPayment P
		INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
	END

--INVOICE NUMBER FILTERS
IF @strInvoiceNumberFrom IS NOT NULL
	BEGIN
		SELECT TOP 1 @intInvoiceNumberFrom = intInvoiceId
		FROM tblARInvoice I
		INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
		WHERE strInvoiceNumber = @strInvoiceNumberFrom
	END
ELSE 
	BEGIN
		SELECT @intInvoiceNumberFrom = MIN(intInvoiceId)
		FROM tblARInvoice I
		INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	END

IF @strInvoiceNumberTo IS NOT NULL
	BEGIN
		SELECT TOP 1 @intInvoiceNumberTo = intInvoiceId
		FROM tblARInvoice I
		INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
		WHERE strInvoiceNumber = @strInvoiceNumberTo
	END
ELSE
	BEGIN
		SELECT @intInvoiceNumberTo = MAX(intInvoiceId)
		FROM tblARInvoice I
		INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	END

--PAYMENT METHOD FILTERS
INSERT INTO #PAYMENTMETHODS (
	  intPaymentMethodId
	, strPaymentMethod
)
SELECT intPaymentMethodID
   , strPaymentMethod
FROM tblSMPaymentMethod
WHERE @strPaymentMethod IS NULL
  OR (@strPaymentMethod IS NOT NULL AND strPaymentMethod = @strPaymentMethod)

INSERT INTO #PAYMENTS (
	   intPaymentId
	 , strRecordNumber
	 , strPaymentMethod
	 , strReferenceNumber
	 , dtmDatePaid
	 , dblAmountPaid
	 , dblUnappliedAmount

	 , intInvoiceId
	 , strInvoiceNumber
	 , dblInvoiceTotal
	 , dblAmountApplied
	 , dblAmountDue
	 , strPaid

	 , intEntityCustomerId
	 , strCustomerName
	 , strContact
	 , strCompanyName
	 , strCompanyAddress
)
SELECT intPaymentId					= P.intPaymentId
	 , strRecordNumber				= P.strRecordNumber
	 , strPaymentMethod				= PM.strPaymentMethod
	 , strReferenceNumber			= P.strPaymentInfo
	 , dtmDatePaid					= P.dtmDatePaid
	 , dblAmountPaid				= P.dblAmountPaid
	 , dblUnappliedAmount			= P.dblUnappliedAmount

	 , intInvoiceId					= I.intInvoiceId
	 , strInvoiceNumber				= I.strInvoiceNumber
	 , dblInvoiceTotal				= PD.dblInvoiceTotal
	 , dblAmountApplied				= PD.dblPayment
	 , dblAmountDue					= PD.dblAmountDue
	 , strPaid						= CASE WHEN PD.dblAmountDue = 0 THEN 'Yes' ELSE 'No' END

	 , intEntityCustomerId			= C.intEntityCustomerId
	 , strCustomerName				= C.strCustomerName
	 , strContact					= C.strContact
	 , strCompanyName				= @strCompanyName
	 , strCompanyAddress			= @strCompanyAddress
FROM tblARPayment P
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #PAYMENTMETHODS PM ON P.intPaymentMethodId = PM.intPaymentMethodId
LEFT JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
WHERE P.intPaymentId BETWEEN @intRecordNumberFrom AND @intRecordNumberTo
  AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo

SELECT rownm						= ROW_NUMBER() OVER(PARTITION BY strInvoiceNumber ORDER BY strRecordNumber ASC) 
     , strCustomerName				= strCustomerName 
	 , strCompanyName				= strCompanyName
	 , strCompanyAddress			= strCompanyAddress
	 , strContact					= strContact
	 , strPaid						= strPaid
	 , dblBareInvoiceTotal			= CAST(0 AS NUMERIC(18, 6))
	 , rownum						= CAST(0 AS INT)
	 , dblBareInvoiceTotalPayment	= dblAmountApplied
	 , strRecordNumber				= P.strRecordNumber
	 , strPaymentMethod				= P.strPaymentMethod
	 , strReferenceNumber			= P.strReferenceNumber
	 , dtmDatePaid					= P.dtmDatePaid
	 , dblAmountPaid				= P.dblAmountPaid
	 , dblUnappliedAmount			= P.dblUnappliedAmount
	 , strInvoiceNumber				= P.strInvoiceNumber
	 , dblInvoiceTotal				= P.dblInvoiceTotal
	 , dblAmountApplied				= P.dblAmountApplied
	 , dblAmountDue					= P.dblAmountDue
INTO #TEMPHISTORY
FROM #PAYMENTS P

UPDATE #TEMPHISTORY
SET dblBareInvoiceTotal	= dblInvoiceTotal
WHERE rownm = 1

SELECT *
INTO #FINALPAYMENTHISTORY
FROM #TEMPHISTORY

SELECT * FROM #FINALPAYMENTHISTORY