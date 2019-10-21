CREATE PROCEDURE [dbo].[uspARAccrualBalanceReport]
	@xmlParam NVARCHAR(MAX) = NULL
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

		SELECT * FROM tblARCustomerStatementStagingTable
	END

-- Declare the variables.
DECLARE @dtmAsOfDate			DATETIME
	  , @strCustomerName		NVARCHAR(100)
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

SELECT  @dtmAsOfDate   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmAsOfDate IS NOT NULL
	SET @dtmAsOfDate = CAST(FLOOR(CAST(@dtmAsOfDate AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmAsOfDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

SET @strCustomerName = NULLIF(@strCustomerName, '')

SELECT intInvoiceId					= I.intInvoiceId
	 , intEntityCustomerId			= CUSTOMER.intEntityCustomerId
	 , intPeriodsToAccrue			= intPeriodsToAccrue
	 , strInvoiceNumber				= strInvoiceNumber
	 , strCustomerDisplay			= CUSTOMER.strCustomerNumber + ' - ' + CUSTOMER.strCustomerName
	 , strCustomerName				= CUSTOMER.strCustomerName
	 , strCustomerNumber			= CUSTOMER.strCustomerNumber
	 , strCompanyName				= COMPANY.strCompanyName
	 , strCompanyAddress			= COMPANY.strCompanyAddress
	 , strMonthAccrued				= ACCRUAL.strMonthAccrued
	 , dtmDate
	 , dtmPostDate
	 , dblInvoiceTotal
	 , dblMonthlyAccrual			= dbo.fnRoundBanker(dblInvoiceTotal / intPeriodsToAccrue, 2)
	 , dblRunningAccrualBalance		= dbo.fnRoundBanker(ACCRUAL.dblRunningAccrualBalance, 2)
	 , dtmAsOfDate					= @dtmAsOfDate
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId	= C.intEntityId
		 , strCustomerName		= E.strName
		 , strCustomerNumber	= C.strCustomerNumber
	FROM dbo.tblARCustomer C WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity
		WHERE (@strCustomerName IS NULL OR strName = @strCustomerName)
	) E ON C.intEntityId = E.intEntityId
) CUSTOMER ON I.intEntityCustomerId = CUSTOMER.intEntityCustomerId
CROSS APPLY (
	SELECT *
	FROM dbo.fnARGetMonthlyAccrual(I.intInvoiceId, @dtmAsOfDate)
	WHERE intInvoiceId = I.intInvoiceId
) ACCRUAL
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE I.ysnPosted = 1
  AND dblInvoiceTotal > 0
  AND ISNULL(I.intPeriodsToAccrue, 0) > 1