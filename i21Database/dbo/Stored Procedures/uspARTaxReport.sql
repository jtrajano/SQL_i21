CREATE PROCEDURE [dbo].[uspARTaxReport]
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

		SELECT * FROM tblARTaxStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateFrom			DATETIME
	  , @dtmDateTo				DATETIME
	  , @strTaxCode				NVARCHAR(100)
	  , @strTaxAgency			NVARCHAR(100)
	  , @strTaxClass			NVARCHAR(100)
	  , @strTaxGroup			NVARCHAR(100)
	  , @strCustomerNameFrom	NVARCHAR(100)
	  , @strCustomerNameTo		NVARCHAR(100)
	  , @strInvoiceNumberFrom	NVARCHAR(100)
	  , @strInvoiceNumberTo		NVARCHAR(100)
	  , @strLocationNameFrom	NVARCHAR(100)
	  , @strLocationNameTo		NVARCHAR(100)
	  , @strTaxReportType		NVARCHAR(100)
	  , @ysnTaxExemptOnly		BIT
	  , @xmlDocumentId			INT
	  , @query					NVARCHAR(MAX)
	  , @filter					NVARCHAR(MAX) = ''
	  , @fieldname				NVARCHAR(50)
	  , @conditionDate			NVARCHAR(20)
	  , @conditionCustomer		NVARCHAR(20)
	  , @conditionInvoice		NVARCHAR(20)
	  , @conditionLocation		NVARCHAR(20)
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
SELECT @strTaxCode = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTaxCode'

SELECT @strTaxAgency = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTaxAgency'

SELECT @strTaxClass = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTaxClass'

SELECT @strTaxGroup = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTaxGroup'

SELECT @strCustomerNameFrom = REPLACE(ISNULL([from], ''), '''''', '''')
	 , @strCustomerNameTo	= REPLACE(ISNULL([to], ''), '''''', '''')
	 , @conditionCustomer	= [condition]
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerName'

SELECT @strInvoiceNumberFrom = REPLACE(ISNULL([from], ''), '''''', '''')
	 , @strInvoiceNumberTo	 = REPLACE(ISNULL([to], ''), '''''', '''')
	 , @conditionInvoice	 = [condition]
FROM @temp_xml_table
WHERE [fieldname] = 'strInvoiceNumber'

SELECT @strLocationNameFrom = REPLACE(ISNULL([from], ''), '''''', '''')
	 , @strLocationNameTo	= REPLACE(ISNULL([to], ''), '''''', '''')
	 , @conditionLocation	= [condition]
FROM @temp_xml_table
WHERE [fieldname] = 'strLocationName'

SELECT @strTaxReportType = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTaxReportType'

SELECT @ysnTaxExemptOnly = [from] 
FROM @temp_xml_table
WHERE [fieldname] = 'ysnTaxExemptOnly'

SELECT  @dtmDateFrom	= CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo		= CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@conditionDate	= [condition]
FROM @temp_xml_table 
WHERE [fieldname] = 'dtmDate'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

CREATE TABLE #CUSTOMERS (intEntityCustomerId INT) 

IF (@conditionCustomer IS NOT NULL AND UPPER(@conditionCustomer) = 'BETWEEN' AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT C.intEntityId
		FROM tblARCustomer C WITH (NOLOCK) 
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strName BETWEEN @strCustomerNameFrom AND @strCustomerNameTo
		) E ON C.intEntityId = E.intEntityId
	END
ELSE IF (@conditionCustomer IS NOT NULL AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT C.intEntityId
		FROM tblARCustomer C WITH (NOLOCK) 
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strName = @strCustomerNameFrom
		) E ON C.intEntityId = E.intEntityId
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT C.intEntityId
		FROM tblARCustomer C WITH (NOLOCK) 
	END

IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
BEGIN
    DROP TABLE #COMPANYLOCATIONS
END

CREATE TABLE #COMPANYLOCATIONS (intCompanyLocationId INT)

IF (@conditionLocation IS NOT NULL AND UPPER(@conditionLocation) = 'BETWEEN' AND ISNULL(@strLocationNameFrom, '') <> '')
	BEGIN
		INSERT INTO #COMPANYLOCATIONS
		SELECT intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE strLocationName BETWEEN @strLocationNameFrom AND @strLocationNameTo
	END
ELSE IF (@conditionLocation IS NOT NULL AND ISNULL(@strLocationNameFrom, '') <> '')
	BEGIN
		INSERT INTO #COMPANYLOCATIONS
		SELECT intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE strLocationName = @strLocationNameFrom
	END
ELSE
	BEGIN
		INSERT INTO #COMPANYLOCATIONS
		SELECT intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	END

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICES
END

CREATE TABLE #INVOICES (intInvoiceId INT)

IF (@conditionInvoice IS NOT NULL AND UPPER(@conditionInvoice) = 'BETWEEN' AND ISNULL(@strInvoiceNumberFrom, '') <> '')
	BEGIN
		INSERT INTO #INVOICES
		SELECT intInvoiceId
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE strInvoiceNumber BETWEEN @strInvoiceNumberFrom AND @strInvoiceNumberTo
	END
ELSE IF (@conditionInvoice IS NOT NULL AND ISNULL(@strInvoiceNumberFrom, '') <> '')
	BEGIN
		INSERT INTO #INVOICES
		SELECT intInvoiceId
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE strInvoiceNumber = @strInvoiceNumberFrom
	END
ELSE
	BEGIN
		INSERT INTO #INVOICES
		SELECT intInvoiceId
		FROM dbo.tblARInvoice WITH (NOLOCK)
	END

TRUNCATE TABLE tblARTaxStagingTable
INSERT INTO tblARTaxStagingTable (
	  intEntityCustomerId
	, intCurrencyId
	, intCompanyLocationId
	, intShipToLocationId
	, intTaxCodeId
	, intInvoiceId
	, intInvoiceDetailId
	, intItemId
	, intItemUOMId
	, intTaxGroupId
	, intTonnageTaxUOMId
	, dtmDate
	, strInvoiceNumber
	, strCalculationMethod
	, strCustomerNumber
	, strCustomerName
	, strDisplayName
	, strCompanyName
	, strCompanyAddress
	, strCurrency
	, strCurrencyDescription
	, strTaxGroup
	, strTaxAgency
	, strTaxCode
	, strTaxCodeDescription
	, strCountry
	, strState
	, strCounty
	, strCity
	, strTaxClass
	, strSalesTaxAccount
	, strPurchaseTaxAccount
	, strLocationName
	, strShipToLocationAddress
	, strItemNo
	, strCategoryCode
	, strTaxReportType
	, dblRate
	, dblUnitPrice
	, dblQtyShipped
	, dblAdjustedTax
	, dblTax
	, dblTotalAdjustedTax
	, dblTotalTax
	, dblTaxDifference
	, dblTaxAmount
	, dblNonTaxable
	, dblTaxable
	, dblTotalSales
	, dblTaxCollected
	, dblQtyTonShipped
	, ysnTaxExempt
)
SELECT TAX.intEntityCustomerId
	, TAX.intCurrencyId
	, TAX.intCompanyLocationId
	, TAX.intShipToLocationId
	, TAX.intTaxCodeId
	, TAX.intInvoiceId
	, TAX.intInvoiceDetailId
	, TAX.intItemId
	, TAX.intItemUOMId
	, TAX.intTaxGroupId
	, TAX.intTonnageTaxUOMId
	, TAX.dtmDate
	, TAX.strInvoiceNumber
	, TAX.strCalculationMethod
	, TAX.strCustomerNumber
	, TAX.strCustomerName
	, TAX.strDisplayName
	, TAX.strCompanyName
	, TAX.strCompanyAddress
	, TAX.strCurrency
	, TAX.strCurrencyDescription
	, TAX.strTaxGroup
	, TAX.strTaxAgency
	, TAX.strTaxCode
	, TAX.strTaxCodeDescription
	, TAX.strCountry
	, TAX.strState
	, TAX.strCounty
	, TAX.strCity
	, TAX.strTaxClass
	, TAX.strSalesTaxAccount
	, TAX.strPurchaseTaxAccount
	, TAX.strLocationName
	, TAX.strShipToLocationAddress
	, TAX.strItemNo
	, TAX.strCategoryCode
	, @strTaxReportType
	, TAX.dblRate
	, TAX.dblUnitPrice
	, TAX.dblQtyShipped
	, TAX.dblAdjustedTax
	, TAX.dblTax
	, TAX.dblTotalAdjustedTax
	, TAX.dblTotalTax
	, TAX.dblTaxDifference
	, TAX.dblTaxAmount
	, TAX.dblNonTaxable
	, TAX.dblTaxable
	, TAX.dblTotalSales
	, TAX.dblTaxCollected
	, TAX.dblQtyTonShipped
	, TAX.ysnTaxExempt
FROM dbo.vyuARTaxReport TAX WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON TAX.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON TAX.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN #INVOICES I ON TAX.intInvoiceId = I.intInvoiceId
WHERE TAX.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
AND (@strTaxCode IS NULL OR TAX.strTaxCode LIKE '%'+ @strTaxCode +'%')
AND (@strTaxAgency IS NULL OR TAX.strTaxAgency LIKE '%'+ @strTaxAgency +'%')
AND (@strTaxClass IS NULL OR TAX.strTaxClass LIKE '%'+ @strTaxClass +'%')
AND (@strTaxGroup IS NULL OR TAX.strTaxGroup LIKE '%'+ @strTaxGroup +'%')

IF ISNULL(@ysnTaxExemptOnly, 0) = 1 
	DELETE FROM tblARTaxStagingTable WHERE ysnTaxExempt = 0

SELECT strTaxReportType = ISNULL(@strTaxReportType, 'Tax Detail')