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
	  , @strState				NVARCHAR(100)
	  , @strSalespersonName		NVARCHAR(200)
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

SELECT @strState = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strState'

SELECT @strSalespersonName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strSalespersonName'

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
	, intEntitySalespersonId
	, intCurrencyId
	, intCompanyLocationId
	, intShipToLocationId
	, intTaxCodeId
	, intTaxClassId
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
	, strTaxNumber
	, strSalespersonNumber
	, strSalespersonName
	, strSalespersonDisplayName
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
	, dblCheckOffTax
	, dblCitySalesTax
	, dblCityExciseTax
	, dblCountySalesTax
	, dblCountyExciseTax
	, dblFederalExciseTax
	, dblFederalLustTax
	, dblFederalOilSpillTax
	, dblFederalOtherTax
	, dblLocalOtherTax
	, dblPrepaidSalesTax
	, dblStateExciseTax
	, dblStateOtherTax
	, dblStateSalesTax
	, dblTonnageTax
	, ysnTaxExempt
	, strFederalTaxId
	, strStateTaxId
)
SELECT intEntityCustomerId			= TAX.intEntityCustomerId
	, intEntitySalespersonId		= TAX.intEntitySalespersonId
	, intCurrencyId					= TAX.intCurrencyId
	, intCompanyLocationId			= TAX.intCompanyLocationId
	, intShipToLocationId			= TAX.intShipToLocationId
	, intTaxCodeId					= TAX.intTaxCodeId
	, intTaxClassId					= TAX.intTaxClassId
	, intInvoiceId					= TAX.intInvoiceId
	, intInvoiceDetailId			= TAX.intInvoiceDetailId
	, intItemId						= TAX.intItemId
	, intItemUOMId					= TAX.intItemUOMId
	, intTaxGroupId					= TAX.intTaxGroupId
	, intTonnageTaxUOMId			= TAX.intTonnageTaxUOMId
	, dtmDate						= TAX.dtmDate
	, strInvoiceNumber				= TAX.strInvoiceNumber
	, strCalculationMethod			= TAX.strCalculationMethod
	, strCustomerNumber				= TAX.strCustomerNumber
	, strCustomerName				= TAX.strCustomerName
	, strDisplayName				= TAX.strDisplayName
	, strTaxNumber					= TAX.strTaxNumber
	, strSalespersonNumber			= TAX.strSalespersonNumber
	, strSalespersonName			= TAX.strSalespersonName
	, strSalespersonDisplayName		= TAX.strSalespersonDisplayName
	, strCompanyName				= TAX.strCompanyName
	, strCompanyAddress				= TAX.strCompanyAddress
	, strCurrency					= TAX.strCurrency
	, strCurrencyDescription		= TAX.strCurrencyDescription
	, strTaxGroup					= TAX.strTaxGroup
	, strTaxAgency					= TAX.strTaxAgency
	, strTaxCode					= TAX.strTaxCode
	, strTaxCodeDescription			= TAX.strTaxCodeDescription
	, strCountry					= TAX.strCountry
	, strState						= TAX.strState
	, strCounty						= TAX.strCounty
	, strCity						= TAX.strCity
	, strTaxClass					= TAX.strTaxClass
	, strSalesTaxAccount			= TAX.strSalesTaxAccount
	, strPurchaseTaxAccount			= TAX.strPurchaseTaxAccount
	, strLocationName				= TAX.strLocationName
	, strShipToLocationAddress		= TAX.strShipToLocationAddress
	, strItemNo						= TAX.strItemNo
	, strCategoryCode				= TAX.strCategoryCode
	, strTaxReportType				= @strTaxReportType
	, dblRate						= TAX.dblRate
	, dblUnitPrice					= TAX.dblUnitPrice
	, dblQtyShipped					= TAX.dblQtyShipped
	, dblAdjustedTax				= TAX.dblAdjustedTax
	, dblTax						= TAX.dblTax
	, dblTotalAdjustedTax			= TAX.dblTotalAdjustedTax
	, dblTotalTax					= TAX.dblTotalTax
	, dblTaxDifference				= TAX.dblTaxDifference
	, dblTaxAmount					= TAX.dblTaxAmount
	, dblNonTaxable					= TAX.dblNonTaxable
	, dblTaxable					= TAX.dblTaxable
	, dblTotalSales					= TAX.dblTotalSales
	, dblTaxCollected				= TAX.dblTaxCollected
	, dblQtyTonShipped				= TAX.dblQtyTonShipped
	, dblCheckOffTax		 		= CASE WHEN TRT.strType = 'Checkoff Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblCitySalesTax		 		= CASE WHEN TRT.strType = 'City Sales Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblCityExciseTax		 		= CASE WHEN TRT.strType = 'City Excise Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblCountySalesTax		 		= CASE WHEN TRT.strType = 'County Sales Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblCountyExciseTax	 		= CASE WHEN TRT.strType = 'County Excise Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblFederalExciseTax	 		= CASE WHEN TRT.strType = 'Federal Excise Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblFederalLustTax		 		= CASE WHEN TRT.strType = 'Federal Lust Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblFederalOilSpillTax	 		= CASE WHEN TRT.strType = 'Federal Oil Spill Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblFederalOtherTax	 		= CASE WHEN TRT.strType = 'Federal Other Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblLocalOtherTax		 		= CASE WHEN TRT.strType = 'Local Other Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblPrepaidSalesTax	 		= CASE WHEN TRT.strType = 'Prepaid Sales Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblStateExciseTax	 	 		= CASE WHEN TRT.strType = 'State Excise Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblStateOtherTax		 		= CASE WHEN TRT.strType = 'State Other Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblStateSalesTax		 		= CASE WHEN TRT.strType = 'State Sales Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, dblTonnageTax			 		= CASE WHEN TRT.strType = 'Tonnage Tax' THEN TAX.dblTaxAmount ELSE 0 END
	, ysnTaxExempt					= TAX.ysnTaxExempt
	, strFederalTaxId				= TAX.strFederalTaxId
	, strStateTaxId					= TAX.strStateTaxId
FROM dbo.vyuARTaxReport TAX WITH (NOLOCK)
LEFT JOIN tblSMTaxClass TCLASS ON TAX.intTaxClassId = TCLASS.intTaxClassId
LEFT JOIN tblSMTaxReportType TRT ON TCLASS.intTaxReportTypeId = TRT.intTaxReportTypeId
INNER JOIN #CUSTOMERS C ON TAX.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON TAX.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN #INVOICES I ON TAX.intInvoiceId = I.intInvoiceId
WHERE TAX.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
AND (@strTaxCode IS NULL OR TAX.strTaxCode LIKE '%'+ @strTaxCode +'%')
AND (@strTaxAgency IS NULL OR TAX.strTaxAgency LIKE '%'+ @strTaxAgency +'%')
AND (@strTaxClass IS NULL OR TAX.strTaxClass LIKE '%'+ @strTaxClass +'%')
AND (@strTaxGroup IS NULL OR TAX.strTaxGroup LIKE '%'+ @strTaxGroup +'%')
AND (@strState IS NULL OR TAX.strState LIKE '%'+ @strState +'%')
AND (@strSalespersonName IS NULL OR TAX.strSalespersonName LIKE '%' + @strSalespersonName + '%')

IF ISNULL(@ysnTaxExemptOnly, 0) = 1 
	DELETE FROM tblARTaxStagingTable WHERE ysnTaxExempt = 0

SELECT strTaxReportType = ISNULL(@strTaxReportType, 'Tax Detail')