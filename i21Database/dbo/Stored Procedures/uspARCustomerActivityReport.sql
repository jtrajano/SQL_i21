CREATE PROCEDURE dbo.uspARCustomerActivityReport
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL
		
		SELECT *,0 [dblUnitsRecap], 0 [dblAmountsRecap] FROM tblARCustomerActivityStagingTable
	END

-- Declare the variables.
DECLARE  @dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@xmlDocumentId					AS INT
		,@filter						AS NVARCHAR(MAX) = ''
		,@fieldname						AS NVARCHAR(50)
		,@condition						AS NVARCHAR(20)
		,@id							AS INT 
		,@from							AS NVARCHAR(100)
		,@to							AS NVARCHAR(100)
		,@strInvoiceIds					AS NVARCHAR(MAX)
		,@strPaymentIds					AS NVARCHAR(MAX)
		,@strPaymentMethodIds			AS NVARCHAR(MAX)
		,@strCategoryCodeIds			AS NVARCHAR(MAX)
		,@strTransactionType			AS NVARCHAR(100)
		,@strFormattingOptions			AS NVARCHAR(100)
		,@strCustomerIds				AS NVARCHAR(MAX)
		,@strAccountStatusIds			AS NVARCHAR(MAX)
		,@intCategoryId					AS INT
		,@ysnPrintRecap					AS BIT = 1
		,@ysnPrintDetail				AS BIT = 1
		,@intEntityCustomerId			AS INT
		,@intEntityUserId				AS INT
		,@ysnExcludeAccountStatus		AS BIT = 0
		,@ysnExcludePaymentMethods		AS BIT = 0
		,@strCompanyName				NVARCHAR(100)	= NULL
		,@strCompanyAddress				NVARCHAR(500)	= NULL

DECLARE @tblAccountStatus	TABLE (intAccountStatusId	INT)
DECLARE @tblInvoices		TABLE (intInvoiceId			INT)
DECLARE @tblPayments		TABLE (intPaymentId			INT, intPaymentMethodId	INT)
DECLARE @tblPaymentMethods	TABLE (intPaymentMethodId	INT)
DECLARE @tblItemCategories	TABLE (intCategoryId		INT)
DECLARE @tblCustomers		TABLE (
	  intEntityCustomerId	INT
	, strCustomerName		NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerAddress	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)

SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

IF(OBJECT_ID('tempdb..#TRANSACTIONS') IS NOT NULL)
BEGIN
	DROP TABLE #TRANSACTIONS
END

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
	DROP TABLE #INVOICES
END

IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #PAYMENTS
END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[condition]	NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[from]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[to]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
	,[begingroup]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
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

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(MAX)
	, [to]		   NVARCHAR(MAX)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

--FILTERS
WHILE EXISTS (SELECT TOP 1 NULL FROM @temp_xml_table WHERE [fieldname] IN ('strName', 'strCustomerName', 'strInvoiceNumber', 'strRecordNumber', 'strPaymentMethod', 'strAccountStatusCode', 'strCategoryCode'))
	BEGIN
		SELECT TOP 1 @condition = [condition]
				   , @from		= REPLACE(ISNULL([from], ''), '''''', '''')
				   , @to		= REPLACE(ISNULL([to], ''), '''''', '''')
				   , @fieldname = [fieldname]
				   , @id		= [id]
		FROM @temp_xml_table 
		WHERE [fieldname] IN ('strName', 'strCustomerName', 'strInvoiceNumber', 'strRecordNumber', 'strPaymentMethod', 'strAccountStatusCode', 'strCategoryCode')

		IF @condition = 'Equal To'
			BEGIN				
				IF @fieldname IN ('strName', 'strCustomerName')
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch C
							INNER JOIN @temp_xml_table TT ON C.strName = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname IN ('strName', 'strCustomerName')
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strInvoiceNumber'
					BEGIN
						SELECT @strInvoiceIds = ISNULL(@strInvoiceIds, '') + LEFT(intInvoiceId, LEN(intInvoiceId) - 1)
						FROM (
							SELECT DISTINCT CAST(I.intInvoiceId AS VARCHAR(200))  + ', '
							FROM tblARInvoice I
							INNER JOIN @temp_xml_table TT ON I.strInvoiceNumber = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strInvoiceNumber'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intInvoiceId)
					END
				ELSE IF @fieldname = 'strRecordNumber'
					BEGIN
						SELECT @strPaymentIds = ISNULL(@strPaymentIds, '') + LEFT(intPaymentId, LEN(intPaymentId) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentId AS VARCHAR(200))  + ', '
							FROM tblARPayment P
							INNER JOIN @temp_xml_table TT ON P.strRecordNumber = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strRecordNumber'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intPaymentId)
					END
				ELSE IF @fieldname = 'strPaymentMethod'
					BEGIN
						SELECT @strPaymentMethodIds = ISNULL(@strPaymentMethodIds, '') + LEFT(intPaymentMethodID, LEN(intPaymentMethodID) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentMethodID AS VARCHAR(200))  + ', '
							FROM tblSMPaymentMethod PM
							INNER JOIN @temp_xml_table TT ON PM.strPaymentMethod = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strPaymentMethod'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intPaymentMethodID)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = ISNULL(@strAccountStatusIds, '') + LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(S.intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus S
							INNER JOIN @temp_xml_table TT ON S.strAccountStatusCode = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strAccountStatusCode'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intAccountStatusId)
					END
				ELSE IF @fieldname = 'strCategoryCode'
					BEGIN
						SELECT @strCategoryCodeIds = ISNULL(@strCategoryCodeIds, '') + LEFT(intCategoryId, LEN(intCategoryId) - 1)
						FROM (
							SELECT DISTINCT CAST(CAT.intCategoryId AS VARCHAR(200))  + ', '
							FROM tblICCategory CAT
							INNER JOIN @temp_xml_table TT ON CAT.strCategoryCode = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strCategoryCode'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intCategoryId)
					END
			END
		ELSE IF @condition = 'Not Equal To'
			BEGIN
				IF @fieldname IN ('strName', 'strCustomerName')
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch C
							WHERE strName <> @from
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strInvoiceNumber'
					BEGIN
						SELECT @strInvoiceIds = ISNULL(@strInvoiceIds, '') + LEFT(intInvoiceId, LEN(intInvoiceId) - 1)
						FROM (
							SELECT DISTINCT CAST(I.intInvoiceId AS VARCHAR(200))  + ', '
							FROM tblARInvoice I
							WHERE I.strInvoiceNumber <> @from
							FOR XML PATH ('')
						) C (intInvoiceId)
					END
				ELSE IF @fieldname = 'strRecordNumber'
					BEGIN
						SELECT @strPaymentIds = ISNULL(@strPaymentIds, '') + LEFT(intPaymentId, LEN(intPaymentId) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentId AS VARCHAR(200))  + ', '
							FROM tblARPayment P
							WHERE P.strRecordNumber <> @from
							FOR XML PATH ('')
						) C (intPaymentId)
					END
				ELSE IF @fieldname = 'strPaymentMethod'
					BEGIN
						SELECT @strPaymentMethodIds = ISNULL(@strPaymentMethodIds, '') + LEFT(intPaymentMethodID, LEN(intPaymentMethodID) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentMethodID AS VARCHAR(200))  + ', '
							FROM tblSMPaymentMethod PM							
							WHERE PM.strPaymentMethod <> @from
							FOR XML PATH ('')
						) C (intPaymentMethodID)

						SET @ysnExcludeAccountStatus = CAST(1 AS BIT)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = ISNULL(@strAccountStatusIds, '') + LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(S.intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus S
							WHERE S.strAccountStatusCode <> @from
							FOR XML PATH ('')
						) C (intAccountStatusId)

						SET @ysnExcludeAccountStatus = CAST(1 AS BIT)
					END
				ELSE IF @fieldname = 'strCategoryCode'
					BEGIN
						SELECT @strCategoryCodeIds = ISNULL(@strCategoryCodeIds, '') + LEFT(intCategoryId, LEN(intCategoryId) - 1)
						FROM (
							SELECT DISTINCT CAST(CAT.intCategoryId AS VARCHAR(200))  + ', '
							FROM tblICCategory CAT
							WHERE CAT.strCategoryCode <> @from
							FOR XML PATH ('')
						) C (intCategoryId)
					END
			END
		ELSE IF @condition = 'Between'
			BEGIN
				IF @fieldname IN ('strName', 'strCustomerName')
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch C
							WHERE strName BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strInvoiceNumber'
					BEGIN
						SELECT @strInvoiceIds = ISNULL(@strInvoiceIds, '') + LEFT(intInvoiceId, LEN(intInvoiceId) - 1)
						FROM (
							SELECT DISTINCT CAST(I.intInvoiceId AS VARCHAR(200))  + ', '
							FROM tblARInvoice I
							WHERE I.strInvoiceNumber BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intInvoiceId)
					END
				ELSE IF @fieldname = 'strRecordNumber'
					BEGIN
						SELECT @strPaymentIds = ISNULL(@strPaymentIds, '') + LEFT(intPaymentId, LEN(intPaymentId) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentId AS VARCHAR(200))  + ', '
							FROM tblARPayment P
							WHERE P.strRecordNumber BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intPaymentId)
					END
				ELSE IF @fieldname = 'strPaymentMethod'
					BEGIN
						SELECT @strPaymentMethodIds = ISNULL(@strPaymentMethodIds, '') + LEFT(intPaymentMethodID, LEN(intPaymentMethodID) - 1)
						FROM (
							SELECT DISTINCT CAST(intPaymentMethodID AS VARCHAR(200))  + ', '
							FROM tblSMPaymentMethod PM							
							WHERE PM.strPaymentMethod BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intPaymentMethodID)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = ISNULL(@strAccountStatusIds, '') + LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(S.intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus S
							WHERE S.strAccountStatusCode BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intAccountStatusId)
					END
				ELSE IF @fieldname = 'strCategoryCode'
					BEGIN
						SELECT @strCategoryCodeIds = ISNULL(@strCategoryCodeIds, '') + LEFT(intCategoryId, LEN(intCategoryId) - 1)
						FROM (
							SELECT DISTINCT CAST(CAT.intCategoryId AS VARCHAR(200))  + ', '
							FROM tblICCategory CAT
							WHERE CAT.strCategoryCode BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intCategoryId)
					END
			END

		DELETE FROM @temp_xml_table WHERE [fieldname] = @fieldname
		SET @condition = NULL
		SET @from = NULL
		SET @to = NULL
		SET @fieldname = NULL
		SET @id =  NULL
	END

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT @strTransactionType = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strTransactionType')

SELECT @strFormattingOptions = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strFormattingOptions')

SELECT @ysnPrintRecap = CASE WHEN ISNULL([from], 'True') = 'True' THEN 1 ELSE 0 END
FROM @temp_xml_table
WHERE [fieldname] IN ('ysnPrintRecap')

SELECT @ysnPrintDetail = CASE WHEN ISNULL([from], 'True') = 'True' THEN 1 ELSE 0 END
FROM @temp_xml_table
WHERE [fieldname] IN ('ysnPrintDetail')

SELECT @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
FROM @temp_xml_table
WHERE [fieldname] = 'intSrCurrentUserId'

SET @strCustomerIds			= NULLIF(@strCustomerIds, '')
SET @strInvoiceIds			= NULLIF(@strInvoiceIds, '')
SET @strPaymentIds			= NULLIF(@strPaymentIds, '')
SET @strPaymentMethodIds	= NULLIF(@strPaymentMethodIds, '')
SET @strAccountStatusIds	= NULLIF(@strAccountStatusIds, '')
SET @strCategoryCodeIds		= NULLIF(@strCategoryCodeIds, '')
SET @strTransactionType		= NULLIF(@strTransactionType, '')
SET @strFormattingOptions	= NULLIF(@strFormattingOptions, '')
SET @intEntityUserId		= NULLIF(@intEntityUserId, 0)

IF @dtmDateFrom IS NULL
    SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF @dtmDateTo IS NULL
    SET @dtmDateTo = GETDATE()

--CUSTOMERS
IF ISNULL(@strCustomerIds, '') <> ''
	BEGIN
		INSERT INTO @tblCustomers (
			  intEntityCustomerId
			, strCustomerName
			, strCustomerNumber
			, strCustomerAddress
		)
		SELECT intEntityCustomerId	= C.intEntityId
			 , strCustomerName		= C.strName
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerAddress	= dbo.fnARFormatCustomerAddress(C.strPhone, C.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
		FROM vyuARCustomerSearch C
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strCustomerIds) DV ON C.intEntityId = DV.intID
	END
ELSE
	BEGIN
		INSERT INTO @tblCustomers (
			  intEntityCustomerId
			, strCustomerName
			, strCustomerNumber
			, strCustomerAddress
		)
		SELECT intEntityCustomerId	= C.intEntityId
			 , strCustomerName		= C.strName
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerAddress	= dbo.fnARFormatCustomerAddress(C.strPhone, C.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
		FROM vyuARCustomerSearch C
	END

--ACCOUNT STATUS
IF ISNULL(@strAccountStatusIds, '') <> ''
	BEGIN
		INSERT INTO @tblAccountStatus
		SELECT ACCS.intAccountStatusId
		FROM dbo.tblARAccountStatus ACCS WITH (NOLOCK) 
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strAccountStatusIds)
		) ACCOUNTSTATUS ON ACCS.intAccountStatusId = ACCOUNTSTATUS.intID

		IF ISNULL(@ysnExcludeAccountStatus, 0) = 0
			BEGIN
				DELETE CUSTOMERS
				FROM @tblCustomers CUSTOMERS
				LEFT JOIN tblARCustomerAccountStatus CAS ON CUSTOMERS.intEntityCustomerId = CAS.intEntityCustomerId
				LEFT JOIN @tblAccountStatus ACCSTATUS ON CAS.intAccountStatusId = ACCSTATUS.intAccountStatusId
				WHERE ACCSTATUS.intAccountStatusId IS NULL
			END
		ELSE 
			BEGIN
				DELETE CUSTOMERS 
				FROM @tblCustomers CUSTOMERS
				INNER JOIN tblARCustomerAccountStatus CAS ON CUSTOMERS.intEntityCustomerId = CAS.intEntityCustomerId
				INNER JOIN @tblAccountStatus ACCSTATUS ON CAS.intAccountStatusId = ACCSTATUS.intAccountStatusId
			END
END

--FILTERED INVOICES
IF ISNULL(@strInvoiceIds, '') <> ''
	BEGIN
		INSERT INTO @tblInvoices
		SELECT intInvoiceId
		FROM tblARInvoice I
		INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strInvoiceIds) DV ON I.intInvoiceId = DV.intID
		WHERE I.ysnPosted = 1
		  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strTransactionType IS NULL OR I.strType LIKE  '%' + @strTransactionType + '%')
		  AND (@strPaymentIds IS NULL OR 0 = 1)
		  AND (@ysnPrintDetail = 1 OR (@ysnPrintDetail = 0 AND I.strType <> 'CF Tran'))
	END
ELSE
	BEGIN
		INSERT INTO @tblInvoices
		SELECT intInvoiceId
		FROM tblARInvoice I
		INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
		WHERE I.ysnPosted = 1
		  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strTransactionType IS NULL OR I.strType LIKE  '%' + @strTransactionType + '%')
		  AND (@strPaymentIds IS NULL OR 0 = 1)
		  AND (@ysnPrintDetail = 1 OR (@ysnPrintDetail = 0 AND I.strType <> 'CF Tran'))
	END

--FILTERED PAYMENTS
IF ISNULL(@strPaymentIds, '') <> ''
	BEGIN
		INSERT INTO @tblPayments
		SELECT intPaymentId
			 , intPaymentMethodId
		FROM tblARPayment P
		INNER JOIN @tblCustomers C ON P.intEntityCustomerId = C.intEntityCustomerId
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strPaymentIds) DV ON P.intPaymentId = DV.intID
		WHERE P.ysnPosted = 1
		  AND P.ysnInvoicePrepayment = 0
		  AND ISNULL(P.dblAmountPaid, 0) <> 0
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strInvoiceIds IS NULL OR 0 = 1)
		  AND (@strCategoryCodeIds IS NULL OR 0 = 1)
		  AND (@strTransactionType IS NULL OR 0 = 1)
	END
ELSE
	BEGIN
		INSERT INTO @tblPayments
		SELECT intPaymentId
			 , intPaymentMethodId
		FROM tblARPayment P
		INNER JOIN @tblCustomers C ON P.intEntityCustomerId = C.intEntityCustomerId
		WHERE P.ysnPosted = 1
		  AND P.ysnInvoicePrepayment = 0
		  AND ISNULL(P.dblAmountPaid, 0) <> 0
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		  AND (@strInvoiceIds IS NULL OR 0 = 1)
		  AND (@strCategoryCodeIds IS NULL OR 0 = 1)
		  AND (@strTransactionType IS NULL OR 0 = 1)
	END

--PAYMENT METHODS	
IF ISNULL(@strPaymentMethodIds, '') <> ''
	BEGIN
		INSERT INTO @tblPaymentMethods
		SELECT intPaymentMethodId	= PM.intPaymentMethodID
		FROM tblSMPaymentMethod PM
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strPaymentMethodIds) DV ON PM.intPaymentMethodID = DV.intID

		IF ISNULL(@ysnExcludePaymentMethods, 0) = 0
			BEGIN
				DELETE P
				FROM @tblPayments P
				LEFT JOIN @tblPaymentMethods PM ON P.intPaymentMethodId = PM.intPaymentMethodId
				WHERE PM.intPaymentMethodId IS NULL
			END
		ELSE 
			BEGIN
				DELETE P 
				FROM @tblPayments P
				INNER JOIN @tblPaymentMethods PM ON P.intPaymentMethodId = PM.intPaymentMethodId
			END	
	END

--INVOICES
SELECT intTransactionId			= I.intInvoiceId
	 , strTransactionNumber		= I.strInvoiceNumber
	 , strTransactionType		= I.strTransactionType
	 , strActivityType			= 'Invoice'
	 , strType					= I.strType
	 , dtmTransactionDate		= I.dtmDate
	 , dblInvoiceTotal			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblInvoiceSubtotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
	 , dblInvoiceLineTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblInvoiceLineTotal, 0) * -1 ELSE ISNULL(ID.dblInvoiceLineTotal, 0) END
	 , dblDiscount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblDiscount, 0) * -1 ELSE ISNULL(I.dblDiscount, 0) END
	 , dblInterest				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInterest, 0) * -1 ELSE ISNULL(I.dblInterest, 0) END
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , intItemId				= ID.intItemId
	 , intInvoiceDetailId		= ID.intInvoiceDetailId
	 , intInvoiceDetailTaxId	= ID.intInvoiceDetailTaxId
	 , strTaxCode				= ID.strTaxCode
	 , strTaxGroup				= ID.strTaxGroup
	 , strItemDescription		= ID.strItemDescription
	 , strUnitMeasure			= ID.strUnitMeasure
	 , dblAdjustedTax			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblAdjustedTax, 0) * -1 ELSE ISNULL(ID.dblAdjustedTax, 0) END 
	 , dblQtyShipped			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblQtyShipped, 0) * -1 ELSE ISNULL(ID.dblQtyShipped, 0) END
	 , dblTotalTax				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblTotalTax, 0) * -1 ELSE ISNULL(ID.dblTotalTax, 0) END
INTO #INVOICES 
FROM dbo.tblARInvoice I
INNER JOIN @tblInvoices FI ON I.intInvoiceId = FI.intInvoiceId
LEFT JOIN (
	SELECT intInvoiceId				= ARID.intInvoiceId
		 , intInvoiceDetailId		= ARID.intInvoiceDetailId
		 , intInvoiceDetailTaxId	= IDT.intInvoiceDetailTaxId 
		 , strTaxCode				= IDT.strTaxCode
		 , dblAdjustedTax			= IDT.dblAdjustedTax
		 , intItemId				= ARID.intItemId
		 , strItemDescription		= ARID.strItemDescription
		 , dblQtyShipped			= ARID.dblQtyShipped
		 , dblInvoiceLineTotal		= dbo.fnRoundBanker(ARID.dblQtyShipped * CASE WHEN ARID.intPriceUOMId IS NULL THEN ARID.dblPrice ELSE dbo.fnCalculateCostBetweenUOM(ARID.intPriceUOMId, ARID.intItemUOMId, ISNULL(ARID.dblPrice, 0)) END, dbo.fnARGetDefaultDecimal())
		 , strUnitMeasure			= ICUM.strUnitMeasure
		 , dblTotalTax				= ARID.dblTotalTax
		 , strTaxGroup				= SMTG.strTaxGroup
	FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intInvoiceDetailId	 = intTransactionDetailId
			 , intInvoiceDetailTaxId = intTransactionDetailTaxId
			 , strTaxCode
			 , dblAdjustedTax
		FROM dbo.vyuARTaxDetailReport WITH (NOLOCK)
		WHERE strTaxTransactionType = 'Invoice'
	) IDT ON ARID.intInvoiceDetailId = IDT.intInvoiceDetailId
	LEFT JOIN (
		SELECT intItemUOMId
			 , intUnitMeasureId 
		FROM dbo.tblICItemUOM WITH (NOLOCK)
	) ICIUOM ON ARID.intItemUOMId = ICIUOM.intItemUOMId
	LEFT JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure 
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) ICUM ON ICIUOM.intUnitMeasureId = ICUM.intUnitMeasureId
	LEFT JOIN (
		SELECT intTaxGroupId
			 , strTaxGroup
			 , strDescription
		FROM dbo.tblSMTaxGroup WITH (NOLOCK)
	) SMTG ON ARID.intTaxGroupId = SMTG.intTaxGroupId
	WHERE @ysnPrintDetail = 1
) ID ON I.intInvoiceId = ID.intInvoiceId

--PAYMENTS
SELECT intTransactionId			= P.intPaymentId
	 , strTransactionNumber		= P.strRecordNumber
	 , strTransactionType		= 'Payment'
	 , strActivityType			= 'Payment'
	 , strPaymentInfo			= P.strPaymentInfo
	 , dtmTransactionDate		= P.dtmDatePaid
	 , dblPayment				= P.dblAmountPaid		 
	 , intEntityCustomerId		= P.intEntityCustomerId
	 , strNotes					= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END
	 , strPaymentMethod			= P.strPaymentMethod
INTO #PAYMENTS
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN @tblPayments FP ON P.intPaymentId = FP.intPaymentId

--AGING REPORT
SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
	FROM @tblCustomers C
	FOR XML PATH ('')
) C (intEntityCustomerId)

EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateTo		= @dtmDateTo
										, @strCustomerIds	= @strCustomerIds
										, @intEntityUserId	= @intEntityUserId

IF ISNULL(@ysnPrintDetail, 0) = 0
	BEGIN
		UPDATE tblARCustomerAgingStagingTable
		SET dblFuture	= 0
		  , dblTotalAR	= dblTotalAR - ISNULL(dblFuture, 0)
		WHERE intEntityUserId = @intEntityUserId
	END

DELETE FROM tblARCustomerActivityStagingTable WHERE intEntityUserId = @intEntityUserId

IF @strFormattingOptions IS NULL OR @strFormattingOptions <> 'Product Recap Totals Only'
	BEGIN
		--#TRANSACTIONS
		SELECT intTransactionId			= I.intTransactionId
			 , strTransactionNumber		= I.strTransactionNumber
			 , strTransactionType		= I.strTransactionType
			 , strActivityType			= 'Invoice'
			 , dtmTransactionDate		= I.dtmTransactionDate
			 , dblInvoiceTotal			= CASE  WHEN I.strType = 'Service Charge' THEN  0 ELSE  CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END END 
			 , dblInvoiceSubtotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
			 , dblInvoiceLineTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceLineTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceLineTotal, 0) END
			 , dblPayment				= NULL
			 , dblDiscount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblDiscount, 0) * -1 ELSE ISNULL(I.dblDiscount, 0) END
			 , dblInterest				= CASE  WHEN I.strType = 'Service Charge' THEN CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END ELSE CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInterest, 0) * -1 ELSE ISNULL(I.dblInterest, 0) END END 			 , intEntityCustomerId		= I.intEntityCustomerId
			 , intItemId				= I.intItemId
			 , intInvoiceDetailId		= I.intInvoiceDetailId
			 , intInvoiceDetailTaxId	= I.intInvoiceDetailTaxId
			 , strNotes					= NULL
			 , strPaymentMethod			= NULL
			 , strTaxCode				= I.strTaxCode
			 , strTaxGroup				= I.strTaxGroup
			 , strItemDescription		= I.strItemDescription
			 , strUnitMeasure			= I.strUnitMeasure
			 , dblAdjustedTax			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAdjustedTax, 0) * -1 ELSE ISNULL(I.dblAdjustedTax, 0) END 
			 , dblQtyShipped			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblQtyShipped, 0) * -1 ELSE ISNULL(I.dblQtyShipped, 0) END
			 , dblTotalTax				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblTotalTax, 0) * -1 ELSE ISNULL(I.dblTotalTax, 0) END
		INTO #TRANSACTIONS
		FROM #INVOICES I

		UNION ALL

		SELECT intTransactionId			= P.intTransactionId
			 , strTransactionNumber		= P.strTransactionNumber
			 , strTransactionType		= 'Payment'
			 , strActivityType			= 'Payment'
			 , dtmTransactionDate		= P.dtmTransactionDate
			 , dblInvoiceTotal			= CAST(0 AS NUMERIC(18, 6))
			 , dblInvoiceSubtotal		= CAST(0 AS NUMERIC(18, 6))
			 , dblInvoiceLineTotal		= CAST(0 AS NUMERIC(18, 6))
			 , dblPayment				= P.dblPayment		 
			 , dblDiscount				= CAST(0 AS NUMERIC(18, 6))
			 , dblInterest				= CAST(0 AS NUMERIC(18, 6))
			 , intEntityCustomerId		= P.intEntityCustomerId
			 , intItemId				= NULL
			 , intInvoiceDetailId		= NULL
			 , intInvoiceDetailTaxId	= NULL
			 , strNotes					= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END
			 , strPaymentMethod			= P.strPaymentMethod
			 , strTaxCode				= NULL
			 , strTaxGroup				= NULL
			 , strItemDescription		= NULL
			 , strUnitMeasure			= NULL
			 , dblAdjustedTax			= CAST(0 AS NUMERIC(18, 6))
			 , dblQtyShipped			= CAST(0 AS NUMERIC(18, 6))
			 , dblTotalTax				= CAST(0 AS NUMERIC(18, 6))
		FROM #PAYMENTS P

		INSERT INTO tblARCustomerActivityStagingTable (
			  strReportDateRange
			, dtmLastPaymentDate
			, dblLastPayment
			, intEntityCustomerId
			, intInvoiceDetailId
			, intEntityUserId
			, strCustomerNumber
			, strCustomerName
			, strCustomerAddress
			, strCompanyName
			, strCompanyAddress
			, strTransactionNumber
			, intTransactionId
			, strInvoiceNumber
			, strTransactionType
			, strActivityType
			, dtmTransactionDate
			, dblPayment
			, dblInvoiceTotal
			, dblInvoiceSubtotal
			, dblInvoiceLineTotal
			, dblDiscount
			, dblInterest
			, intItemId
			, strItemDescription
			, dblQtyShipped
			, strUnitMeasure
			, dblTax
			, strTaxGroup
			, intInvoiceDetailTaxId
			, strTaxCode
			, dblAdjustedTax
			, strNotes
			, dblCreditLimit
			, dblTotalAR
			, dblFuture
			, dbl0Days
			, dbl10Days
			, dbl30Days
			, dbl60Days
			, dbl90Days
			, dbl91Days
			, dblTotalDue
			, dblAmountPaid
			, dblCredits
			, dblPrepayments
			, dblPrepaids
			, dtmAsOfDate
			, ysnPrintDetail
			, ysnPrintRecap
			, strFormattingOptions
			, dtmFilterFrom
			, dtmFilterTo
		)
		SELECT strReportDateRange	= 'From ' + CONVERT(NVARCHAR(50), @dtmDateFrom, 101) + ' To ' + CONVERT(NVARCHAR(50), @dtmDateTo, 101)
			, dtmLastPaymentDate	= PAYMENT.dtmDatePaid
			, dblLastPayment		= ISNULL(PAYMENT.dblAmountPaid, 0)
			, intEntityCustomerId	= CUSTOMER.intEntityCustomerId
			, intInvoiceDetailId	= TRANSACTIONS.intInvoiceDetailId
			, intEntityUserId		= @intEntityUserId
			, strCustomerNumber		= CUSTOMER.strCustomerNumber
			, strCustomerName		= CUSTOMER.strCustomerName	 
			, strCustomerAddress	= CUSTOMER.strCustomerAddress
			, strCompanyName		= @strCompanyName
			, strCompanyAddress		= @strCompanyAddress
			, strTransactionNumber	= TRANSACTIONS.strTransactionNumber
			, intTransactionId		= TRANSACTIONS.intTransactionId
			, strInvoiceNumber		= TRANSACTIONS.strTransactionType
			, strTransactionType	= TRANSACTIONS.strTransactionType
			, strActivityType		= TRANSACTIONS.strActivityType	
			, dtmTransactionDate	= TRANSACTIONS.dtmTransactionDate
			, dblPayment			= TRANSACTIONS.dblPayment
			, dblInvoiceTotal		= CASE WHEN @ysnPrintDetail = 0 THEN TRANSACTIONS.dblInvoiceTotal ELSE NULL END	
			, dblInvoiceSubtotal	= TRANSACTIONS.dblInvoiceSubtotal
			, dblInvoiceLineTotal	= TRANSACTIONS.dblInvoiceLineTotal
			, dblDiscount			= NULLIF(TRANSACTIONS.dblDiscount, 0)
			, dblInterest			= NULLIF(TRANSACTIONS.dblInterest, 0)
			, intItemId				= TRANSACTIONS.intItemId
			, strItemDescription	= TRANSACTIONS.strItemDescription
			, dblQtyShipped			= TRANSACTIONS.dblQtyShipped
			, strUnitMeasure		= TRANSACTIONS.strUnitMeasure		 
			, dblTax				= TRANSACTIONS.dblTotalTax
			, strTaxGroup			= TRANSACTIONS.strTaxGroup
			, intInvoiceDetailTaxId	= TRANSACTIONS.intInvoiceDetailTaxId 
			, strTaxCode			= TRANSACTIONS.strTaxCode
			, dblAdjustedTax		= TRANSACTIONS.dblAdjustedTax
			, strNotes				= TRANSACTIONS.strNotes
 			, dblCreditLimit		= AGING.dblCreditLimit
			, dblTotalAR			= AGING.dblTotalAR
			, dblFuture				= AGING.dblFuture
			, dbl0Days				= AGING.dbl0Days
			, dbl10Days				= AGING.dbl10Days
			, dbl30Days				= AGING.dbl30Days
			, dbl60Days				= AGING.dbl60Days
			, dbl90Days				= AGING.dbl90Days
			, dbl91Days				= AGING.dbl91Days
			, dblTotalDue			= AGING.dblTotalDue
			, dblAmountPaid			= AGING.dblAmountPaid
			, dblCredits			= AGING.dblCredits
			, dblPrepayments		= AGING.dblPrepayments
			, dblPrepaids			= AGING.dblPrepaids
			, dtmAsOfDate			= AGING.dtmAsOfDate
			, ysnPrintDetail		= @ysnPrintDetail
			, ysnPrintRecap			= @ysnPrintRecap
			, strFormattingOptions	= @strFormattingOptions
			, dtmFilterFrom			= @dtmDateFrom
			, dtmFilterTo			= @dtmDateTo
		FROM @tblCustomers CUSTOMER 
		INNER JOIN #TRANSACTIONS TRANSACTIONS ON CUSTOMER.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId
		LEFT JOIN tblARCustomerAgingStagingTable AGING ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId AND AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Summary'
		LEFT JOIN (
			SELECT dblAmountPaid		= MAX(dblAmountPaid)
				 , dtmDatePaid			= MAX(dtmDatePaid)
				 , intEntityCustomerId
			FROM (
				SELECT dblAmountPaid		
					 , dtmDatePaid				
					 , intEntityCustomerId
					 , intRowNumber			=  ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ORDER BY intPaymentId DESC) 
				FROM dbo.tblARPayment P WITH (NOLOCK)
				WHERE P.ysnPosted = 1
				  AND ISNULL(P.strPaymentInfo, '') != 'CF Invoice'		
			) I 
			WHERE I.intRowNumber = 1
			GROUP BY intEntityCustomerId
		) PAYMENT ON PAYMENT.intEntityCustomerId = CUSTOMER.intEntityCustomerId 		
		ORDER BY TRANSACTIONS.dtmTransactionDate
	END

IF @ysnPrintRecap = 1 OR @strFormattingOptions = 'Product Recap Totals Only'
	BEGIN
		EXEC dbo.uspARInvoiceProductRecapReport @dtmDateFrom = @dtmDateFrom
											  , @dtmDateTo = @dtmDateTo
											  , @strCustomerIds = @strCustomerIds
											  , @strCategoryCodeIds = @strCategoryCodeIds
											  , @strTransactionType = @strTransactionType
											  , @strFormattingOptions = @strFormattingOptions
											  , @intEntityUserId = @intEntityUserId
											  , @ysnPrintDetail	= @ysnPrintDetail
											  , @strCompanyName = @strCompanyName
                                              , @strCompanyAddress = @strCompanyAddress
	END

IF @strFormattingOptions IS NULL OR @strFormattingOptions <> 'Product Recap Totals Only'
	BEGIN
	SELECT * FROM(
		SELECT ISNULL(PostDatePayment.dtmDatePaid,PostDateInvoice.dtmPostDate)[PostDate],* FROM tblARCustomerActivityStagingTable ARST
		LEFT  JOIN(
		SELECT 
			ARI.strInvoiceNumber[strInvoiceNumber2],
			ARI.dtmPostDate
			FROM dbo.tblARInvoice ARI
		)  PostDateInvoice ON PostDateInvoice.strInvoiceNumber2=ARST.strTransactionNumber 
		LEFT  JOIN(
		SELECT 
			ARI.strRecordNumber[strRecordNumber2],
			ARI.dtmDatePaid
			FROM dbo.tblARPayment ARI
		)  PostDatePayment ON PostDatePayment.strRecordNumber2=ARST.strTransactionNumber 
		OUTER APPLY(
		SELECT SUM(ISNULL(dblUnits,0))[dblUnitsRecap],SUM(ISNULL(dblAmounts,0))[dblAmountsRecap] FROM dbo.tblARProductRecapStagingTable
		WHERE intEntityUserId = @intEntityUserId and intEntityCustomerId in (SELECT intEntityCustomerId from @tblCustomers)
		)Recap

		WHERE intEntityUserId = @intEntityUserId)NST
		ORDER BY NST.PostDate 
	END
ELSE 
	BEGIN
		SELECT * FROM tblARCustomerActivityStagingTable 
		OUTER APPLY(
		SELECT SUM(ISNULL(dblUnits,0))[dblUnitsRecap],SUM(ISNULL(dblAmounts,0))[dblAmountsRecap] FROM dbo.tblARProductRecapStagingTable
		WHERE intEntityUserId = @intEntityUserId and intEntityCustomerId in (SELECT intEntityCustomerId from @tblCustomers)
		)Recap
		WHERE intEntityUserId = @intEntityUserId 
		ORDER BY strCustomerName
	END