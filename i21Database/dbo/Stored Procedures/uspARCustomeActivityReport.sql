CREATE PROCEDURE dbo.uspARCustomeActivityReport
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

-- Declare the variables.
DECLARE  @dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@xmlDocumentId					AS INT
		,@condition						AS NVARCHAR(20)
		,@strCustomerName				AS NVARCHAR(100)
		,@strInvoiceNumber				AS NVARCHAR(100)
		,@strRecordNumber				AS NVARCHAR(100)
		,@strPaymentMethod				AS NVARCHAR(100)
		,@intEntityCustomerId			AS INT

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

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT @strCustomerName = [from]
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

IF @dtmDateFrom IS NULL
    SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF @dtmDateTo IS NULL
    SET @dtmDateTo = GETDATE()

TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
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
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
)
EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom = @dtmDateFrom
									    , @dtmDateTo = @dtmDateTo
									    , @strCustomerName	= @strCustomerName
 
SELECT strReportDateRange	= 'From ' + CONVERT(NVARCHAR(50), @dtmDateFrom, 101) + ' To ' + CONVERT(NVARCHAR(50), @dtmDateTo, 101)
	, dtmLastPaymentDate	= PAYMENT.dtmDatePaid
	, intEntityCustomerId	= I.intEntityCustomerId
	, intInvoiceDetailId	= ID.intInvoiceDetailId
	, strCustomerNumber		= CUSTOMER.strCustomerNumber
	, strCustomerName		= CUSTOMER.strName	 
	, strCustomerAddress	= CUSTOMER.strFullAddress
	, strCompanyName		= AGING.strCompanyName
	, strCompanyAddress		= AGING.strCompanyAddress
	, intPaymentId			= PAYMENTS.intPaymentId	 
	, strRecordNumber		= PAYMENTS.strRecordNumber	
	, intInvoiceId			= I.intInvoiceId	 
	, strInvoiceNumber		= I.strInvoiceNumber
	, strTransactionType	= I.strTransactionType
	, strInvoice			= 'Invoice'
	, strType				= I.strType
	, dtmInvoiceDate		= I.dtmDate
	, dtmPostDate			= I.dtmPostDate
	, dtmDatePaid			= PAYMENTS.dtmDatePaid	 
	, dblPayments			= ISNULL(PAYMENTS.dblPayment, 0)
	, dblInvoices			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
	, dblDiscount			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblDiscount, 0) * -1 ELSE ISNULL(I.dblDiscount, 0) END
	, dblInterest			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInterest, 0) * -1 ELSE ISNULL(I.dblInterest, 0) END		
	, strPaymentMethod		= PAYMENTS.strPaymentMethod
	, intItemId				= ID.intItemId
	, strItemDescription	= ID.strItemDescription
	, dblQtyShipped			= ID.dblQtyShipped
	, strUnitMeasure		= ID.strUnitMeasure		 
	, dblTax				= ID.dblTotalTax
	, strTaxGroup			= ID.strTaxGroup
	, intInvoiceDetailTaxId	= ID.intInvoiceDetailTaxId 
	, strTaxCode			= ID.strTaxCode
	, dblAdjustedTax		= ID.dblAdjustedTax
	, strNotes				= PAYMENTS.strNotes
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
FROM tblARInvoice I WITH (NOLOCK)
LEFT JOIN dbo.tblARCustomerAgingStagingTable AGING ON I.intEntityCustomerId = AGING.intEntityCustomerId
LEFT JOIN (
	SELECT ARID.intInvoiceId
		 , ARID.intInvoiceDetailId
		 , IDT.intInvoiceDetailTaxId 
		 , IDT.strTaxCode
		 , IDT.dblAdjustedTax
		 , ARID.intItemId
		 , ARID.strItemDescription
		 , dblQtyShipped
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
	INNER JOIN (
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
) ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN (
	SELECT C.intEntityId
		 , strCustomerNumber
		 , strName 
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
) CUSTOMER ON I.intEntityCustomerId = CUSTOMER.intEntityId
OUTER APPLY (
	SELECT P.intPaymentId
		 , P.strRecordNumber
		 , P.dtmDatePaid
		 , dblPayment = ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)
		 , PD.intInvoiceId
		 , P.strNotes
		 , P.strPaymentMethod
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strRecordNumber
			 , dtmDatePaid
			 , strPaymentMethod
			 , ysnPosted
			 , strNotes = CASE WHEN ISNULL(strPaymentInfo, '') = ''
							THEN ISNULL(strNotes, '')
						  ELSE
							CASE WHEN ISNULL(strNotes, '') = '' THEN strPaymentInfo ELSE strPaymentInfo + ' - ' +  ISNULL(strNotes, '') END
						  END
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	) P ON P.intPaymentId = PD.intPaymentId 
	WHERE PD.intInvoiceId = I.intInvoiceId

	UNION ALL

	SELECT APP.intPaymentId		 
		 , APP.strPaymentRecordNum
		 , APP.dtmDatePaid
		 , dblPayment = ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)
		 , APPD.intInvoiceId 
		 , APP.strNotes
		 , strPaymentMethod	 = NULL
	FROM dbo.tblAPPaymentDetail APPD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strPaymentRecordNum
			 , dtmDatePaid
			 , ysnPosted
			 , strNotes = CASE WHEN ISNULL(strPaymentInfo, '') = ''
							THEN ISNULL(strNotes, '')
						  ELSE
							CASE WHEN ISNULL(strNotes, '') = '' THEN strPaymentInfo ELSE strPaymentInfo + ' - ' +  ISNULL(strNotes, '') END
						  END
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	) APP ON APP.intPaymentId = APPD.intPaymentId		 
	WHERE APPD.intInvoiceId = I.intInvoiceId

	UNION ALL

	SELECT intPaymentId = PC.intPrepaymentId		 
		 , strRecordNumber = PCI.strInvoiceNumber
		 , dtmDatePaid = PCI.dtmPostDate
		 , PC.dblAppliedInvoiceAmount
		 , PC.intInvoiceId
		 , strNotes = ''
		 , strPaymentMethod = NULL
	FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
			 , dtmPostDate
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
	) PCI ON PC.intPrepaymentId = PCI.intInvoiceId 
	     AND PC.ysnApplied = 1
	WHERE PC.intInvoiceId = I.intInvoiceId
) PAYMENTS
OUTER APPLY (
	SELECT TOP 1 P.intEntityCustomerId
			   , P.dtmDatePaid 
    FROM dbo.tblARPayment P WITH (NOLOCK)
	WHERE P.intEntityCustomerId = I.intEntityCustomerId
		AND P.ysnPosted = 1 
		AND P.strPaymentMethod != 'CF Invoice'
	ORDER BY P.intPaymentId DESC
) PAYMENT
WHERE I.ysnPosted = 1
AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
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
AND (@strCustomerName IS NULL OR CUSTOMER.strName LIKE '%'+@strCustomerName+'%')
AND (@strInvoiceNumber IS NULL OR I.strInvoiceNumber LIKE '%'+@strInvoiceNumber+'%')
AND (@strRecordNumber IS NULL OR PAYMENTS.strRecordNumber LIKE '%'+@strRecordNumber+'%')
AND (@strPaymentMethod IS NULL OR PAYMENTS.strPaymentMethod LIKE '%'+@strPaymentMethod+'%')
ORDER BY 
	intEntityCustomerId, dtmDatePaid DESC, intInvoiceId, strTransactionType, strType, intItemId