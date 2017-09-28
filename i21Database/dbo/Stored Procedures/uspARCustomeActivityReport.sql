CREATE PROCEDURE dbo.uspARCustomeActivityReport
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
	,[strCustomerInfo]			NVARCHAR(200)
	,[intEntityCustomerId]		INT
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

-- Declare the variables.
DECLARE  @strAsOfDateTo					AS NVARCHAR(50)
		,@strAsOfDateFrom				AS NVARCHAR(50)
		,@dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@xmlDocumentId					AS INT
		,@condition						AS NVARCHAR(20)
		,@strCustomerName				AS NVARCHAR(100)
		,@strInvoiceNumber				AS NVARCHAR(100)
		,@strRecordNumber				AS NVARCHAR(100)
		,@strPaymentMethod				AS NVARCHAR(100)

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

DECLARE @SelectedCustomer TABLE  (
	strName				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
); 

DECLARE @SelectedInvoice TABLE  (
	strInvoiceNumber	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
); 

DECLARE @SelectedPayment TABLE  (
	strRecordNumber		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
); 

DECLARE @SelectedPaymentMethod TABLE  (
	strPaymentMethod	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
); 

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

SELECT	@strAsOfDateFrom = ISNULL([from], '')
       ,@strAsOfDateTo   = ISNULL([to], '')
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

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

SET @strAsOfDateFrom = CASE WHEN @strAsOfDateFrom IS NULL THEN '''''' ELSE ''''+@strAsOfDateFrom+'''' END
SET @strAsOfDateTo   = CASE WHEN @strAsOfDateTo IS NULL THEN '''''' ELSE ''''+@strAsOfDateTo+'''' END

SET @strCustomerName = REPLACE (@strCustomerName, ',', '''')
SET @strCustomerName = ISNULL(REVERSE(SUBSTRING(REVERSE(@strCustomerName),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerName)),LEN(@strCustomerName) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerName)) - 1)) ), NULL)

SET @strInvoiceNumber = REPLACE (@strInvoiceNumber, ',', '''')
SET @strInvoiceNumber = ISNULL(REVERSE(SUBSTRING(REVERSE(@strInvoiceNumber),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strInvoiceNumber)),LEN(@strInvoiceNumber) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strInvoiceNumber)) - 1)) ), NULL)

SET @strRecordNumber = REPLACE (@strRecordNumber, ',', '''')
SET @strRecordNumber = ISNULL(REVERSE(SUBSTRING(REVERSE(@strRecordNumber),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strRecordNumber)),LEN(@strRecordNumber) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strRecordNumber)) - 1)) ), NULL)

SET @strPaymentMethod = REPLACE (@strPaymentMethod, ',', '''')
SET @strPaymentMethod = ISNULL(REVERSE(SUBSTRING(REVERSE(@strPaymentMethod),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strPaymentMethod)),LEN(@strPaymentMethod) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strPaymentMethod)) - 1)) ), NULL)

INSERT INTO @temp_aging_table
EXEC [uspARCustomerAgingAsOfDateReport] @dtmDateFrom, @dtmDateTo, NULL, NULL, NULL
 
SELECT DISTINCT
		strReportDateRange		= 'From ' + @strAsOfDateFrom + ' To ' + @strAsOfDateTo
		, dtmLastPaymentDate	= ARCIR.dtmLastPaymentDate
		, intEntityCustomerId	= I.intEntityCustomerId
		, strCustomerNumber		=	C.strCustomerNumber
		, strCustomerName		= C.strName	 
		, strCustomerAddress	= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)	 
		, strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
		, strCompanyAddress		= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
		, intPaymentId			= PAYMENTS.intPaymentId	 
		, strRecordNumber		= PAYMENTS.strRecordNumber	
		, intInvoiceId			= I.intInvoiceId	 
		, strInvoiceNumber		= I.strInvoiceNumber
		, strTransactionType	= I.strTransactionType
		, strType				= I.strType
		, dtmInvoiceDate		= I.dtmDate
		, dtmPostDate			= I.dtmPostDate
		, dtmDatePaid			= PAYMENTS.dtmDatePaid	 
		, dblPayments			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
		, dblInvoices			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
		, dblDiscount			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblDiscount, 0) * -1 ELSE ISNULL(I.dblDiscount, 0) END
		, dblInterest			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInterest, 0) * -1 ELSE ISNULL(I.dblInterest, 0) END		
		, strPaymentMethod		= PM.strPaymentMethod	 
		, intItemId				= ID.intItemId
		, strItemDescription	= ID.strItemDescription
		, dblQtyShipped			= ID.dblQtyShipped
		, strUnitMeasure		= ID.strUnitMeasure		 
		, dblTax				= ID.dblTotalTax
		, strTaxGroup			= ID.strTaxGroup		 
		, strNotes				= PAYMENTS.strNotes
 		, [dblCreditLimit]			
		, [dblTotalAR]				
		, [dblFuture]				
		, [dbl0Days]					
		, [dbl10Days]				
		, [dbl30Days]				
		, [dbl60Days]				
		, [dbl90Days]				
		, [dbl91Days]				
		, [dblTotalDue]				
		, [dblAmountPaid]			
		, [dblCredits]				
		, [dblPrepayments]			
		, [dblPrepaids]				
		, [dtmAsOfDate]				
FROM 
	tblARInvoice I
INNER JOIN 
	(SELECT 
		ARID.intInvoiceId 
		, ARID.intItemId
		, ARID.strItemDescription			
		, dblQtyShipped
		, ICUM.strUnitMeasure
		, dblTotalTax
		, SMTG.strTaxGroup
	FROM
		tblARInvoiceDetail ARID
	LEFT JOIN 
		(SELECT 
			intItemUOMId, 
			intUnitMeasureId 
		FROM 
			tblICItemUOM) ICIUOM ON ARID.intItemUOMId = ICIUOM.intItemUOMId
	INNER JOIN 
		(SELECT 
			intUnitMeasureId, 
			strUnitMeasure 
		FROM 
			tblICUnitMeasure) ICUM ON ICIUOM.intUnitMeasureId = ICUM.intUnitMeasureId
	LEFT JOIN
		(SELECT 
			intTaxGroupId
			, strTaxGroup
			, strDescription
		FROM
			tblSMTaxGroup) SMTG ON ARID.intTaxGroupId = SMTG.intTaxGroupId
	) ID ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN 
	(SELECT P.intPaymentId
				, P.intPaymentMethodId
				, P.strRecordNumber
				, P.dtmDatePaid
				, PD.dblPayment
				, PD.intInvoiceId
				, P.strNotes
			FROM 
				tblARPaymentDetail PD 
			INNER JOIN 
				(SELECT 
					intPaymentId, 
					strRecordNumber,
					dtmDatePaid,
					intPaymentMethodId,
					ysnPosted,					
					strNotes = CASE WHEN strPaymentInfo  IS NULL OR strPaymentInfo = '' THEN 
									CASE WHEN strNotes IS NULL OR strNotes = '' THEN '' ELSE ISNULL(strNotes, '') END
								ELSE
									CASE WHEN strNotes IS NULL OR strNotes = '' THEN ISNULL(strPaymentInfo, '') ELSE ISNULL(strPaymentInfo, '')  + ' - ' +  ISNULL(strNotes, '') END
								END
				FROM 
					tblARPayment
				) P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1

			UNION ALL

			SELECT APP.intPaymentId
				, APP.intPaymentMethodId
				, APP.strPaymentRecordNum
				, APP.dtmDatePaid
				, APPD.dblPayment
				, APPD.intInvoiceId 
				, APP.strNotes
			FROM 
				tblAPPaymentDetail APPD 
			INNER JOIN 
				(SELECT 
					intPaymentId,
					intPaymentMethodId,
					strPaymentRecordNum,
					dtmDatePaid,
					ysnPosted,					
					strNotes = CASE WHEN strPaymentInfo  IS NULL OR strPaymentInfo = '' THEN 
									CASE WHEN strNotes IS NULL OR strNotes = '' THEN '' ELSE ISNULL(strNotes, '') END
								ELSE
									CASE WHEN strNotes IS NULL OR strNotes = '' THEN ISNULL(strPaymentInfo, '') ELSE ISNULL(strPaymentInfo, '')  + ' - ' +  ISNULL(strNotes, '') END
								END
				FROM 
					tblAPPayment
				) APP ON APP.intPaymentId = APPD.intPaymentId AND APP.ysnPosted = 1 AND APPD.intInvoiceId IS NOT NULL

			UNION ALL

			SELECT PC.intPrepaymentId
				, NULL
				, PCI.strInvoiceNumber
				, PCI.dtmPostDate
				, PC.dblAppliedInvoiceAmount
				, PC.intInvoiceId
				, strNotes = ''
			FROM 
				tblARPrepaidAndCredit PC
			INNER JOIN 
				(SELECT 
					intInvoiceId,
					strInvoiceNumber,
					dtmPostDate
				FROM 
					tblARInvoice) PCI ON PC.intPrepaymentId = PCI.intInvoiceId AND PC.ysnApplied = 1
	) PAYMENTS ON PAYMENTS.intInvoiceId = I.intInvoiceId
	LEFT JOIN 
		(SELECT 
			intPaymentMethodID, 
			strPaymentMethod 
		FROM 
			tblSMPaymentMethod)  PM ON PAYMENTS.intPaymentMethodId = PM.intPaymentMethodID
	INNER JOIN 
		((SELECT 
				[intEntityId],
				strCustomerNumber,
				strName,				 
				strBillToLocationName, 
				strBillToAddress,
				strBillToCity, 
				strBillToState, 
				strBillToZipCode, 
				strBillToCountry
			FROM 
				vyuARCustomer) C 
			INNER JOIN 
			(SELECT 
				[intEntityId],				
				strPhone,
				strEmail,
				ysnDefaultContact
			 FROM 
				vyuARCustomerContacts) CC ON C.[intEntityId] = CC.[intEntityId] AND ysnDefaultContact = 1
		) ON I.intEntityCustomerId = C.[intEntityId]
INNER JOIN (SELECT
				[intEntityCustomerId]		
				,[dblCreditLimit]			
				,[dblTotalAR]				
				,[dblFuture]				
				,[dbl0Days]					
				,[dbl10Days]				
				,[dbl30Days]				
				,[dbl60Days]				
				,[dbl90Days]				
				,[dbl91Days]				
				,[dblTotalDue]				
				,[dblAmountPaid]			
				,[dblCredits]				
				,[dblPrepayments]			
				,[dblPrepaids]				
				,[dtmAsOfDate]				
			FROM 
				@temp_aging_table) Aging ON I.intEntityCustomerId = Aging.intEntityCustomerId
LEFT JOIN (SELECT 
				intEntityCustomerId, 
				dtmLastPaymentDate 
			FROM 
				vyuARCustomerInquiryReport) ARCIR ON ARCIR.intEntityCustomerId = I.intEntityCustomerId  
WHERE I.ysnPosted = 1
	AND I.intAccountId IN (SELECT 
								intAccountId 
							FROM 
								vyuGLAccountDetail 
							WHERE 
								strAccountCategory IN ('AR Account', 'Customer Prepayments', 'Undeposited Funds'))
AND 
	(@strCustomerName IS NULL OR C.strName LIKE '%'+@strCustomerName+'%')
	AND (@strInvoiceNumber IS NULL OR I.strInvoiceNumber LIKE '%'+@strInvoiceNumber+'%')
	AND (@strRecordNumber IS NULL OR PAYMENTS.strRecordNumber LIKE '%'+@strRecordNumber+'%')
	AND (@strPaymentMethod IS NULL OR PM.strPaymentMethod LIKE '%'+@strPaymentMethod+'%')
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PAYMENTS.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo		
ORDER BY 
	intEntityCustomerId, dtmDatePaid DESC, intInvoiceId, strTransactionType, strType, intItemId
 


