CREATE PROCEDURE [dbo].[uspARCustomerStatementDetailReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

-- Declare the variables.
DECLARE  @dtmDateTo					AS DATETIME
		,@dtmDateFrom				AS DATETIME
		,@xmlDocumentId				AS INT
		,@intEntityUserId			AS INT
		,@fieldname					AS NVARCHAR(50)
		,@condition					AS NVARCHAR(20)
		,@id						AS INT 
		,@from						AS NVARCHAR(MAX)
		,@to						AS NVARCHAR(MAX)
		,@join						AS NVARCHAR(10)
		,@begingroup				AS NVARCHAR(50)
		,@endgroup					AS NVARCHAR(50)
		,@datatype					AS NVARCHAR(50)
		,@strCustomerName			AS NVARCHAR(MAX)
		,@strCustomerIds			AS NVARCHAR(MAX)
		,@strCustomerIdsLocal		AS NVARCHAR(MAX)
		,@strCustomerNumber			AS NVARCHAR(MAX)
		,@conditionCustomerNumber   AS NVARCHAR(20)
		,@strCompanyName			AS NVARCHAR(100) = NULL
	    ,@strCompanyAddress			AS NVARCHAR(500) = NULL
		,@ysnEmailOnly				AS BIT
		
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(MAX)
	,[to]			NVARCHAR(MAX)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

IF(OBJECT_ID('tempdb..#ADCUSTOMERS') IS NOT NULL) DROP TABLE #ADCUSTOMERS
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL) DROP TABLE #STATEMENTREPORT
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES

CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL PRIMARY KEY
	, strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strFullAddress			NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFooterComment	NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
	, dblARBalance				NUMERIC(18,6) NULL DEFAULT 0
	, ysnStatementCreditLimit	BIT NULL
)
CREATE TABLE #STATEMENTREPORT (
	   strReferenceNumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , strTransactionType				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , intEntityCustomerId				INT NOT NULL
	 , dtmDate							DATETIME NULL
	 , dtmDueDate						DATETIME NULL
	 , dtmPostDate						DATETIME NULL
	 , intDaysDue						INT NULL DEFAULT 0
	 , dblTotalAmount					NUMERIC(18,6) NULL DEFAULT 0
	 , dblAmountPaid					NUMERIC(18,6) NULL DEFAULT 0
	 , dblAmountDue						NUMERIC(18,6) NULL DEFAULT 0
	 , dblPastDue						NUMERIC(18,6) NULL DEFAULT 0
	 , dblMonthlyBudget					NUMERIC(18,6) NULL DEFAULT 0
	 , strDescription					NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	 , strItemNo						NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	 , dblQtyOrdered					NUMERIC(18,6) NULL DEFAULT 0
	 , dblQtyShipped					NUMERIC(18,6) NULL DEFAULT 0
	 , dblDiscountAmount				NUMERIC(18,6) NULL DEFAULT 0
	 , dblTax							NUMERIC(18,6) NULL DEFAULT 0
	 , dblTotal							NUMERIC(18,6) NULL DEFAULT 0
	 , dblPrice							NUMERIC(18,6) NULL DEFAULT 0
	 , intInvoiceId						INT NULL
	 , strCustomerNumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , strName							NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , strBOLNumber						NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , dblCreditLimit					NUMERIC(18,6) NULL DEFAULT 0
	 , strFullAddress					NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	 , strStatementFooterComment		NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	 , strCompanyName					NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , strCompanyAddress				NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	 , strTicketNumbers					NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , ysnStatementCreditLimit			BIT NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTREPORT_STATEMENTDETAIL] ON [#STATEMENTREPORT]([intEntityCustomerId], [strTransactionType])
CREATE TABLE #INVOICES (
	   intInvoiceId				INT NOT NULL PRIMARY KEY
	 , strTransactionType		NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , strType					NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	 , intEntityCustomerId		INT NOT NULL
	 , dtmDate					DATETIME NULL
	 , dtmDueDate				DATETIME NULL
	 , dtmPostDate				DATETIME NULL
	 , dblInvoiceTotal			NUMERIC(18,6) NULL DEFAULT 0
	 , dblPayment				NUMERIC(18,6) NULL DEFAULT 0
	 , dblAmountDue				NUMERIC(18,6) NULL DEFAULT 0
	 , dblMonthlyBudget			NUMERIC(18,6) NULL DEFAULT 0
	 , strBOLNumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
)
CREATE NONCLUSTERED INDEX [NC_Index_#INVOICES_STATEMENTDETAIL] ON [#INVOICES]([intEntityCustomerId])

--COMPANY INFO
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry + CHAR(13) + CHAR(10) + strPhone
FROM tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT * FROM #STATEMENTREPORT
	END

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
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

-- Gather the variables values from the xml table.
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmDate'

SELECT @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] IN ('strName', 'strCustomerName')

SELECT @strCustomerIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerIds'

SELECT @strCustomerNumber = REPLACE(ISNULL([from], ''), '''''', ''''), 
	   @conditionCustomerNumber = [condition]
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerNumber'

SELECT @intEntityUserId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intSrCurrentUserId'

SELECT @ysnEmailOnly = [from] 
FROM @temp_xml_table
WHERE [fieldname] = 'ysnHasEmailSetup'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
SET @intEntityUserId = NULLIF(@intEntityUserId, 0)

--FILTER CUSTOMERS
IF ISNULL(@strCustomerName, '') <> ''
	BEGIN
		INSERT INTO #CUSTOMERS (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
			, dblARBalance
			, ysnStatementCreditLimit
		)
		SELECT TOP 1 intEntityCustomerId	= C.intEntityId 
			   , strCustomerNumber			= C.strCustomerNumber
			   , strCustomerName			= EC.strName
			   , dblCreditLimit				= C.dblCreditLimit
			   , dblARBalance				= C.dblARBalance   
			   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit     
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
		  AND EC.strName = @strCustomerName
	END
ELSE IF ISNULL(@strCustomerIds, '') <> ''
	BEGIN
		SELECT DISTINCT intEntityCustomerId = intID
		INTO #ADCUSTOMERS
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIds)

		INSERT INTO #CUSTOMERS (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
			, dblARBalance
			, ysnStatementCreditLimit
		)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName			= EC.strName
			 , dblCreditLimit			= C.dblCreditLimit
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #ADCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
	END
ELSE IF ISNULL(@strCustomerNumber, '') <> ''
	BEGIN
		IF ISNULL(@conditionCustomerNumber, '') = 'Starts With'
		BEGIN
			INSERT INTO #CUSTOMERS (
				  intEntityCustomerId
				, strCustomerNumber
				, strCustomerName
				, dblCreditLimit
				, dblARBalance
				, ysnStatementCreditLimit
			)
			SELECT intEntityCustomerId			= C.intEntityId 
					, strCustomerNumber			= C.strCustomerNumber
					, strCustomerName			= EC.strName
					, dblCreditLimit			= C.dblCreditLimit
					, dblARBalance				= C.dblARBalance
					, ysnStatementCreditLimit	= C.ysnStatementCreditLimit
			FROM tblARCustomer C WITH (NOLOCK)
			INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
			WHERE C.ysnActive = 1
			  AND C.strCustomerNumber LIKE @strCustomerNumber+'%'
		END 
		IF ISNULL(@conditionCustomerNumber, '') = 'Ends With'
		BEGIN
			INSERT INTO #CUSTOMERS (
				  intEntityCustomerId
				, strCustomerNumber
				, strCustomerName
				, dblCreditLimit
				, dblARBalance
				, ysnStatementCreditLimit
			)
			SELECT intEntityCustomerId		= C.intEntityId 
				, strCustomerNumber			= C.strCustomerNumber
				, strCustomerName			= EC.strName
				, dblCreditLimit			= C.dblCreditLimit
				, dblARBalance				= C.dblARBalance
				, ysnStatementCreditLimit	= C.ysnStatementCreditLimit
			FROM tblARCustomer C WITH (NOLOCK)
			INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
			WHERE C.ysnActive = 1
			  AND C.strCustomerNumber LIKE '%'+@strCustomerNumber
		END 
		IF ISNULL(@conditionCustomerNumber, '') = 'Equal To'
		BEGIN
			INSERT INTO #CUSTOMERS (
				  intEntityCustomerId
				, strCustomerNumber
				, strCustomerName
				, dblCreditLimit
				, dblARBalance
				, ysnStatementCreditLimit
			)
			SELECT TOP 1 intEntityCustomerId	= C.intEntityId 
					, strCustomerNumber			= C.strCustomerNumber
					, strCustomerName			= EC.strName
					, dblCreditLimit			= C.dblCreditLimit
					, dblARBalance				= C.dblARBalance
					, ysnStatementCreditLimit	= C.ysnStatementCreditLimit
			FROM tblARCustomer C WITH (NOLOCK)
			INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
			WHERE C.ysnActive = 1
			  AND C.strCustomerNumber = @strCustomerNumber
		END 
		IF ISNULL(@conditionCustomerNumber, '') = 'Not Equal To'
		BEGIN
			INSERT INTO #CUSTOMERS (
				  intEntityCustomerId
				, strCustomerNumber
				, strCustomerName
				, dblCreditLimit
				, dblARBalance
				, ysnStatementCreditLimit
			)
			SELECT intEntityCustomerId		= C.intEntityId 
				, strCustomerNumber			= C.strCustomerNumber
				, strCustomerName			= EC.strName
				, dblCreditLimit			= C.dblCreditLimit
				, dblARBalance				= C.dblARBalance
				, ysnStatementCreditLimit	= C.ysnStatementCreditLimit
			FROM tblARCustomer C WITH (NOLOCK)
			INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
			WHERE C.ysnActive = 1
		END 
		IF ISNULL(@conditionCustomerNumber, '') = 'Like'
		BEGIN
			INSERT INTO #CUSTOMERS (
				  intEntityCustomerId
				, strCustomerNumber
				, strCustomerName
				, dblCreditLimit
				, dblARBalance
				, ysnStatementCreditLimit
			)
			SELECT intEntityCustomerId		= C.intEntityId 
				 , strCustomerNumber		= C.strCustomerNumber
				 , strCustomerName			= EC.strName
				 , dblCreditLimit			= C.dblCreditLimit
				 , dblARBalance				= C.dblARBalance
				 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
			FROM tblARCustomer C WITH (NOLOCK)
			INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
			WHERE C.ysnActive = 1
			  AND C.strCustomerNumber LIKE '%'+@strCustomerNumber+'%'
		END 
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
			, dblARBalance
			, ysnStatementCreditLimit
		)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName			= EC.strName
			 , dblCreditLimit			= C.dblCreditLimit
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
	END

--FILTER CUSTOMER BY EMAIL SETUP
IF @ysnEmailOnly IS NOT NULL
	BEGIN
		DELETE C
		FROM #CUSTOMERS C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM tblARCustomer CC
			INNER JOIN tblEMEntityToContact CONT ON CC.intEntityId = CONT.intEntityId 
			INNER JOIN tblEMEntity E ON CONT.intEntityContactId = E.intEntityId 
			WHERE E.strEmail <> '' 
			  AND E.strEmail IS NOT NULL
			  AND E.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress		= EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1

--CUSTOMER_FOOTERCOMMENT
UPDATE C
SET strStatementFooterComment	= FOOTER.strMessage
FROM #CUSTOMERS C
CROSS APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strSource = 'Statement Report'
	  AND M.intEntityCustomerId = C.intEntityCustomerId
	  AND M.intEntityCustomerId IS NOT NULL
	ORDER BY M.intDocumentMaintenanceId DESC
		   , intEntityCustomerId DESC
) FOOTER

--#INVOICES
INSERT INTO #INVOICES WITH (TABLOCK) (
	   intInvoiceId
	 , strTransactionType
	 , strType
	 , strInvoiceNumber
	 , intEntityCustomerId
	 , dtmDate
	 , dtmDueDate
	 , dtmPostDate
	 , dblInvoiceTotal
	 , dblPayment
	 , dblAmountDue
	 , strBOLNumber
)
SELECT intInvoiceId			= I.intInvoiceId
	 , strTransactionType	= I.strTransactionType
	 , strType				= I.strType
	 , strInvoiceNumber		= I.strInvoiceNumber
	 , intEntityCustomerId	= I.intEntityCustomerId
	 , dtmDate				= I.dtmDate
	 , dtmDueDate			= I.dtmDueDate
	 , dtmPostDate			= I.dtmPostDate
	 , dblInvoiceTotal		= I.dblInvoiceTotal
	 , dblPayment			= I.dblPayment
	 , dblAmountDue			= I.dblAmountDue
	 , strBOLNumber			= I.strBOLNumber			
FROM tblARInvoice I
INNER JOIN #CUSTOMERS CUSTOMER ON I.intEntityCustomerId = CUSTOMER.intEntityCustomerId  
WHERE I.ysnPosted = 1   
  AND I.ysnPaid = 0   
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))   
  AND I.dtmPostDate <= @dtmDateTo  

--MONTHLY BUDGET
UPDATE I
SET dblMonthlyBudget = dblBudgetAmount
FROM #INVOICES I
INNER JOIN tblARCustomerBudget CB ON I.intEntityCustomerId = CB.intEntityCustomerId
WHERE I.dtmDate BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)

--AGING SUMMARY REPORT
SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo			= @dtmDateTo
										  , @intEntityUserId	= @intEntityUserId
										  , @strCustomerIds		= @strCustomerIdsLocal
 
--#STATEMENTREPORT
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   strReferenceNumber
	 , strTransactionType
	 , intEntityCustomerId
	 , dtmDate
	 , dtmDueDate
	 , dtmPostDate
	 , intDaysDue
	 , dblTotalAmount
	 , dblAmountPaid
	 , dblAmountDue
	 , dblPastDue
	 , dblMonthlyBudget
	 , strDescription
	 , strItemNo
	 , dblQtyOrdered
	 , dblQtyShipped
	 , dblDiscountAmount
	 , dblTax
	 , dblTotal
	 , dblPrice
	 , intInvoiceId
	 , strCustomerNumber
	 , strName
	 , strBOLNumber
	 , dblCreditLimit
	 , strFullAddress
	 , strStatementFooterComment
	 , strCompanyName
	 , strCompanyAddress
	 , strTicketNumbers
	 , ysnStatementCreditLimit
)
SELECT strReferenceNumber			= I.strInvoiceNumber    
	 , strTransactionType			= CASE WHEN I.strType = 'Service Charge' THEN 'Service Charge' ELSE I.strTransactionType END    
	 , intEntityCustomerId			= I.intEntityCustomerId    
	 , dtmDate						= I.dtmDate
	 , dtmDueDate					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo') THEN NULL ELSE I.dtmDueDate END    
	 , dtmPostDate					= I.dtmPostDate    
	 , intDaysDue					= DATEDIFF(DAY, I.[dtmDueDate], @dtmDateTo)    
	 , dblTotalAmount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END    
	 , dblAmountPaid				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END    
	 , dblAmountDue					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END    
	 , dblPastDue					= CASE WHEN @dtmDateTo > I.[dtmDueDate] AND I.strTransactionType IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblAmountDue, 0) ELSE 0 END    
	 , dblMonthlyBudget				= I.dblMonthlyBudget
	 , strDescription				= CASE WHEN I.strType = 'Service Charge' THEN ISNULL(ID.strSCInvoiceNumber, ID.strSCBudgetDescription) ELSE ITEM.strDescription END    
	 , strItemNo					= ITEM.strItemNo    
	 , dblQtyOrdered				= ID.dblQtyOrdered    
	 , dblQtyShipped				= ID.dblQtyShipped    
	 , dblDiscountAmount			= (ID.dblQtyShipped * ID.dblPrice) * (ID.dblDiscount/100)    
	 , dblTax						= ID.dblTotalTax    
	 , dblTotal						= ID.dblTotal + ID.dblTotalTax    
	 , dblPrice						= ID.dblPrice    
	 , intInvoiceId					= I.intInvoiceId    
	 , strCustomerNumber			= CUSTOMER.strCustomerNumber    
	 , strName						= CUSTOMER.strCustomerName    
	 , strBOLNumber					= I.strBOLNumber    
	 , dblCreditLimit				= CUSTOMER.dblCreditLimit    
	 , strFullAddress				= CUSTOMER.strFullAddress    
	 , strStatementFooterComment	= CUSTOMER.strStatementFooterComment
	 , strCompanyName				= @strCompanyName    
	 , strCompanyAddress			= @strCompanyAddress    
	 , strTicketNumbers				= SCALE.strTicketNumber    
	 , ysnStatementCreditLimit		= CUSTOMER.ysnStatementCreditLimit  
FROM #INVOICES I  
INNER JOIN #CUSTOMERS CUSTOMER ON I.intEntityCustomerId = CUSTOMER.intEntityCustomerId  
INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK) ON I.intInvoiceId = ID.intInvoiceId  
LEFT JOIN tblSCTicket SCALE WITH (NOLOCK) ON ID.intTicketId = SCALE.intTicketId  
LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON ID.intItemId = ITEM.intItemId  

DELETE FROM #STATEMENTREPORT
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

SELECT strReferenceNumber			= STATEMENTREPORT.strReferenceNumber
	 , strTransactionType			= STATEMENTREPORT.strTransactionType
	 , intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
	 , dtmDueDate					= STATEMENTREPORT.dtmDueDate
	 , dtmDate						= STATEMENTREPORT.dtmDate
	 , intDaysDue					= STATEMENTREPORT.intDaysDue
	 , dblTotalAmount				= STATEMENTREPORT.dblTotalAmount
	 , dblAmountPaid				= STATEMENTREPORT.dblAmountPaid
	 , dblAmountDue					= STATEMENTREPORT.dblAmountDue
	 , dblPastDue					= STATEMENTREPORT.dblPastDue
	 , dblMonthlyBudget				= STATEMENTREPORT.dblMonthlyBudget
	 , strDescription				= STATEMENTREPORT.strDescription
	 , strItemNo					= STATEMENTREPORT.strItemNo
	 , dblQtyOrdered				= STATEMENTREPORT.dblQtyOrdered
	 , dblQtyShipped				= STATEMENTREPORT.dblQtyShipped
	 , dblDiscountAmount			= STATEMENTREPORT.dblDiscountAmount
	 , dblTax						= STATEMENTREPORT.dblTax
	 , dblTotal						= STATEMENTREPORT.dblTotal
	 , dblPrice						= STATEMENTREPORT.dblPrice
	 , intInvoiceId					= STATEMENTREPORT.intInvoiceId
	 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
	 , strName						= STATEMENTREPORT.strName
	 , strBOLNumber					= STATEMENTREPORT.strBOLNumber
	 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit
	 , dblCreditAvailable			= CASE WHEN (STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days						= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits					= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments				= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , strFullAddress				= STATEMENTREPORT.strFullAddress
	 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment	  
	 , strCompanyName				= STATEMENTREPORT.strCompanyName
	 , strCompanyAddress			= STATEMENTREPORT.strCompanyAddress
	 , dtmAsOfDate					= @dtmDateTo
	 , ysnStatementCreditLimit		= STATEMENTREPORT.ysnStatementCreditLimit
	 , strTicketNumbers				= STATEMENTREPORT.strTicketNumbers
FROM #STATEMENTREPORT AS STATEMENTREPORT
INNER JOIN tblARCustomerAgingStagingTable AS AGINGREPORT 
ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
 AND AGINGREPORT.intEntityUserId = @intEntityUserId
 AND AGINGREPORT.strAgingType = 'Summary'
