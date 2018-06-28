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
		
		SELECT * FROM tblARCustomerActivityStagingTable
	END

-- Declare the variables.
DECLARE  @dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@xmlDocumentId					AS INT
		,@condition						AS NVARCHAR(20)
		,@strCustomerName				AS NVARCHAR(100)
		,@strInvoiceNumber				AS NVARCHAR(100)
		,@strRecordNumber				AS NVARCHAR(100)
		,@strPaymentMethod				AS NVARCHAR(100)
		,@strAccountStatusCode			AS NVARCHAR(100)
		,@strCategoryCode				AS NVARCHAR(100)
		,@strTransactionType			AS NVARCHAR(100)
		,@strFormattingOptions			AS NVARCHAR(100)
		,@strCustomerIds				AS NVARCHAR(MAX)
		,@intCategoryId					AS INT
		,@ysnPrintRecap					AS BIT = 1
		,@ysnPrintDetail				AS BIT = 1
		,@intEntityCustomerId			AS INT
		,@intEntityUserId				AS INT

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

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] IN ('strName', 'strCustomerName')

SELECT @strInvoiceNumber = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strInvoiceNumber')

SELECT @strRecordNumber = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strRecordNumber')

SELECT @strPaymentMethod = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strPaymentMethod')

SELECT @strAccountStatusCode = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strAccountStatusCode')

SELECT @strCategoryCode = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strCategoryCode')

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

SET @strCustomerName = NULLIF(@strCustomerName, '')
SET @strInvoiceNumber = NULLIF(@strInvoiceNumber, '')
SET @strRecordNumber = NULLIF(@strRecordNumber, '')
SET @strPaymentMethod = NULLIF(@strPaymentMethod, '')
SET @strAccountStatusCode = NULLIF(@strAccountStatusCode, '')
SET @strCategoryCode = NULLIF(@strCategoryCode, '')
SET @strTransactionType = NULLIF(@strTransactionType, '')
SET @strFormattingOptions = NULLIF(@strFormattingOptions, '')
SET @intEntityUserId = NULLIF(@intEntityUserId, 0)

IF @dtmDateFrom IS NULL
    SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF @dtmDateTo IS NULL
    SET @dtmDateTo = GETDATE()

IF @strFormattingOptions IS NULL OR @strFormattingOptions <> 'Product Recap Totals Only'
	BEGIN
		IF @strCategoryCode IS NOT NULL
			SELECT TOP 1 @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @strCategoryCode

		IF(OBJECT_ID('tempdb..#TRANSACTIONS') IS NOT NULL)
		BEGIN
			DROP TABLE #TRANSACTIONS
		END

		--#TRANSACTIONS
		SELECT intTransactionId			= I.intInvoiceId
			 , strTransactionNumber		= I.strInvoiceNumber
			 , strTransactionType		= I.strTransactionType
			 , strActivityType			= 'Invoice'
			 , dtmTransactionDate		= I.dtmDate
			 , dblInvoiceTotal			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
			 , dblInvoiceSubtotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
			 , dblInvoiceLineTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblInvoiceLineTotal, 0) * -1 ELSE ISNULL(ID.dblInvoiceLineTotal, 0) END
			 , dblPayment				= NULL
			 , dblDiscount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblDiscount, 0) * -1 ELSE ISNULL(I.dblDiscount, 0) END
			 , dblInterest				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInterest, 0) * -1 ELSE ISNULL(I.dblInterest, 0) END
			 , intEntityCustomerId		= I.intEntityCustomerId
			 , intItemId				= ID.intItemId
			 , intInvoiceDetailId		= ID.intInvoiceDetailId
			 , intInvoiceDetailTaxId	= ID.intInvoiceDetailTaxId
			 , strNotes					= NULL
			 , strPaymentMethod			= NULL
			 , strTaxCode				= ID.strTaxCode
			 , strTaxGroup				= ID.strTaxGroup
			 , strItemDescription		= ID.strItemDescription
			 , strUnitMeasure			= ID.strUnitMeasure
			 , dblAdjustedTax			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblAdjustedTax, 0) * -1 ELSE ISNULL(ID.dblAdjustedTax, 0) END 
			 , dblQtyShipped			= ID.dblQtyShipped
			 , dblTotalTax				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(ID.dblTotalTax, 0) * -1 ELSE ISNULL(ID.dblTotalTax, 0) END
		INTO #TRANSACTIONS
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN (
			SELECT ARID.intInvoiceId
				 , ARID.intInvoiceDetailId
				 , IDT.intInvoiceDetailTaxId 
				 , IDT.strTaxCode
				 , IDT.dblAdjustedTax
				 , ARID.intItemId
				 , ARID.strItemDescription
				 , dblQtyShipped
				 , dblInvoiceLineTotal	= dbo.fnRoundBanker(ARID.dblQtyShipped * ARID.dblPrice, dbo.fnARGetDefaultDecimal())
				 , ICUM.strUnitMeasure
				 , dblTotalTax
				 , SMTG.strTaxGroup
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
		WHERE I.ysnPosted = 1
		AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
		AND (@strInvoiceNumber IS NULL OR I.strInvoiceNumber LIKE '%'+@strInvoiceNumber+'%')
		AND (@strTransactionType IS NULL OR I.strType LIKE  '%'+@strTransactionType+'%')
		AND (@strRecordNumber IS NULL OR 0 = 1)

		UNION ALL

		SELECT intTransactionId			= P.intPaymentId
			 , strTransactionNumber		= P.strRecordNumber
			 , strTransactionType		= 'Payment'
			 , strActivityType			= 'Payment'
			 , dtmTransactionDate		= P.dtmDatePaid
			 , dblInvoiceTotal			= NULL		 
			 , dblInvoiceSubtotal		= NULL
			 , dblInvoiceLineTotal		= NULL
			 , dblPayment				= P.dblAmountPaid		 
			 , dblDiscount				= NULL
			 , dblInterest				= NULL
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
			 , dblAdjustedTax			= NULL
			 , dblQtyShipped			= NULL
			 , dblTotalTax				= NULL
		FROM dbo.tblARPayment P WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND ysnInvoicePrepayment = 0
			AND ISNULL(dblAmountPaid, 0) <> 0
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
			AND (@strPaymentMethod IS NULL OR P.strPaymentMethod LIKE '%'+@strPaymentMethod+'%')  
			AND (@strRecordNumber IS NULL OR P.strRecordNumber LIKE '%'+@strRecordNumber+'%')
			AND (@strInvoiceNumber IS NULL OR 0 = 1)
			AND (@strCategoryCode IS NULL OR 0 = 1)
			AND (@strTransactionType IS NULL OR 0 = 1)

		SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
		FROM (
			SELECT DISTINCT CAST(A.intEntityCustomerId AS VARCHAR(200))  + ', '
			FROM (
				SELECT intEntityCustomerId FROM #TRANSACTIONS
			) A INNER JOIN (
				SELECT intEntityId
				FROM tblEMEntity WITH (NOLOCK)
				WHERE (@strCustomerName IS NULL OR strName = @strCustomerName)
			) E ON A.intEntityCustomerId = E.intEntityId
			FOR XML PATH ('')
		) C (intEntityCustomerId)

		EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom		= @dtmDateFrom
												, @dtmDateTo		= @dtmDateTo
												, @strCustomerIds	= @strCustomerIds
												, @intEntityUserId	= @intEntityUserId

		DELETE FROM tblARCustomerActivityStagingTable WHERE intEntityUserId = @intEntityUserId
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
			, intEntityCustomerId	= AGING.intEntityCustomerId
			, intInvoiceDetailId	= TRANSACTIONS.intInvoiceDetailId
			, intEntityUserId		= @intEntityUserId
			, strCustomerNumber		= AGING.strCustomerNumber
			, strCustomerName		= AGING.strCustomerName	 
			, strCustomerAddress	= CUSTOMER.strFullAddress
			, strCompanyName		= AGING.strCompanyName
			, strCompanyAddress		= AGING.strCompanyAddress
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
		FROM tblARCustomerAgingStagingTable AGING WITH (NOLOCK)
		INNER JOIN (
			SELECT C.intEntityId
				 , strFullAddress = dbo.fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
			FROM dbo.vyuARCustomer C WITH (NOLOCK)
			INNER JOIN (
				SELECT intEntityId
					 , strPhone
					 , strEmail
					 , ysnDefaultContact
				FROM vyuARCustomerContacts WITH (NOLOCK)
			) CC ON C.intEntityId = CC.intEntityId
				AND CC.ysnDefaultContact = 1
		) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityId
		INNER JOIN #TRANSACTIONS TRANSACTIONS ON AGING.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId
		OUTER APPLY (
			SELECT TOP 1 P.intEntityCustomerId
					   , P.dtmDatePaid
					   , P.dblAmountPaid
			FROM dbo.tblARPayment P WITH (NOLOCK)
			WHERE P.intEntityCustomerId = AGING.intEntityCustomerId
				AND P.ysnPosted = 1 
				AND P.strPaymentMethod != 'CF Invoice'
			ORDER BY P.intPaymentId DESC
		) PAYMENT
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
				WHERE CAS.intEntityCustomerId = AGING.intEntityCustomerId
				FOR XML PATH ('')
			) SC (strAccountStatusCode)
			WHERE (@strAccountStatusCode IS NULL OR LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1) LIKE '%'+@strAccountStatusCode+'%')
		) STATUSCODES
		WHERE AGING.intEntityUserId = @intEntityUserId
		  AND AGING.strAgingType = 'Summary'
		ORDER BY TRANSACTIONS.dtmTransactionDate
	END

IF @ysnPrintRecap = 1
	BEGIN
		EXEC dbo.uspARInvoiceProductRecapReport @dtmDateFrom = @dtmDateFrom
											  , @dtmDateTo = @dtmDateTo
											  , @strCustomerName = @strCustomerName
											  , @strCategoryCode = @strCategoryCode
											  , @strTransactionType = @strTransactionType
											  , @strFormattingOptions = @strFormattingOptions
											  , @intEntityUserId = @intEntityUserId
	END

IF @strFormattingOptions IS NULL OR @strFormattingOptions <> 'Product Recap Totals Only'
	BEGIN
		SELECT * FROM tblARCustomerActivityStagingTable 
		WHERE intEntityUserId = @intEntityUserId 
		ORDER BY dtmTransactionDate
	END
ELSE 
	BEGIN
		SELECT * FROM tblARCustomerActivityStagingTable 
		WHERE intEntityUserId = @intEntityUserId 
		ORDER BY strCustomerName
	END