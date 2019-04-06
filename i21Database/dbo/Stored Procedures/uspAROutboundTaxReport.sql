CREATE PROCEDURE [dbo].[uspAROutboundTaxReport]
    @xmlParam      NVARCHAR(MAX) = NULL
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
	END

-- Declare the variables.

DECLARE	@ZeroBit        BIT
       ,@OneBit         BIT
       --,@ZeroDecimal    DECIMAL(18,6)

--SET @ZeroDecimal = CAST(0.000000 AS DECIMAL(18,6))
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

DECLARE @dtmDateFrom            DATETIME
	  , @dtmDateTo              DATETIME
	  , @conditionDate          NVARCHAR(20)
	  , @strInvoiceNumberFrom   NVARCHAR(100)
	  , @strInvoiceNumberTo     NVARCHAR(100)
	  , @conditionInvoice       NVARCHAR(20)
	  , @strTypeFrom            NVARCHAR(100)
	  , @strTypeTo              NVARCHAR(100)
	  , @conditionType          NVARCHAR(20)
	  , @strCustomerNameFrom    NVARCHAR(100)
	  , @strCustomerNameTo      NVARCHAR(100)
	  , @conditionCustomer      NVARCHAR(20)
	  , @strLocationNumberFrom    NVARCHAR(100)
	  , @strLocationNumberTo      NVARCHAR(100)
	  , @conditionLocation      NVARCHAR(20)
	  , @strItemNo              NVARCHAR(100)
	  , @strCategoryFrom        NVARCHAR(100)
	  , @strCategoryTo          NVARCHAR(100)
	  , @conditionCategory      NVARCHAR(20)
	  , @strAccountStatusFrom   CHAR(1)
	  , @strAccountStatusTo     CHAR(1)
	  , @conditionAccountStatus NVARCHAR(20)
	  , @AccountStatusFiltered  BIT
	  , @strSalespersonName     NVARCHAR(200)
	  , @strTaxCode             NVARCHAR(100)
	  , @strState               NVARCHAR(100)
	  , @strTaxClass            NVARCHAR(100)
	  , @strTaxClassType        NVARCHAR(100)
	  , @strTaxGroup            NVARCHAR(100)
	  , @strSubTotalBy          NVARCHAR(100)
	  , @strIncludeExemptOnly   NVARCHAR(100)
	  , @ysnInvoiceDetail       BIT
	  , @xmlDocumentId          INT
	  , @fieldname              NVARCHAR(50)
      , @UserName               NVARCHAR(150)
	  , @strCompanyName         NVARCHAR(100)
	  , @strCompanyAddress      NVARCHAR(500)

SET @AccountStatusFiltered = @ZeroBit
SET @strSubTotalBy = 'Tax Group'
SET @strIncludeExemptOnly = 'No'
--SELECT @UserName = [strName] FROM tblEMEntity WHERE[intEntityId] = @EntityUserId
SELECT TOP 1 @strCompanyName = strCompanyName
     , @strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) COLLATE Latin1_General_CI_AS
 FROM dbo.tblSMCompanySetup WITH (NOLOCK)

		
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
        [id]         INT IDENTITY(1,1)
      , [fieldname]  NVARCHAR(50)
      , [condition]  NVARCHAR(20)
      , [from]       NVARCHAR(100)
      , [to]         NVARCHAR(100)
      , [join]       NVARCHAR(10)
      , [begingroup] NVARCHAR(50)
      , [endgroup]   NVARCHAR(50)
      , [datatype]   NVARCHAR(50)
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
     , [from]       NVARCHAR(100)
     , [to]         NVARCHAR(100)
     , [join]       NVARCHAR(10)
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

SELECT @strTaxClassType = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strTaxReportType'

SELECT @strTaxClass = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strTaxClass'

SELECT @strTaxGroup = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strTaxGroup'

SELECT @strCustomerNameFrom = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strCustomerNameTo   = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionCustomer   = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strCustomerName'

SELECT @strInvoiceNumberFrom = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strInvoiceNumberTo   = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionInvoice     = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strInvoiceNumber'

SELECT @strTypeFrom = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strTypeTo   = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionType     = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strType'

SELECT @strLocationNumberFrom = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strLocationNumberTo   = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionLocation   = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strLocationNumber'

SELECT @strCategoryFrom   = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strCategoryTo     = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionCategory = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strCategoryCode'

SELECT @strAccountStatusFrom   = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strAccountStatusTo     = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionAccountStatus = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strAccountStatusCode'

SELECT @strSubTotalBy = REPLACE(ISNULL([from], 'Tax Group'), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strSubTotalBy'

SELECT @strIncludeExemptOnly = REPLACE(ISNULL([from], 'No'), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strIncludeExemptOnly'

SELECT @ysnInvoiceDetail = [from] 
  FROM @temp_xml_table
 WHERE [fieldname] = 'ysnInvoiceDetail'

SELECT @dtmDateFrom     = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
     , @dtmDateTo       = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
     , @conditionDate   = [condition]
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


--SET FMTONLY OFF
--IF(OBJECT_ID('tempdb..#STATUSCODES') IS NOT NULL)
--BEGIN
--    DROP TABLE #STATUSCODES
--END

--CREATE TABLE #STATUSCODES ([intAccountStatusId] INT PRIMARY KEY, [strAccountStatusCode] CHAR(1) COLLATE Latin1_General_CI_AS)
DECLARE @STATUSCODES AS TABLE([intAccountStatusId] INT, [strAccountStatusCode] CHAR(1) COLLATE Latin1_General_CI_AS, [intEntityCustomerId] INT)

IF (@conditionAccountStatus IS NOT NULL AND UPPER(@conditionAccountStatus) = 'BETWEEN' AND ISNULL(@strAccountStatusFrom, '') <> '')
    BEGIN
        SET @AccountStatusFiltered = @OneBit
        INSERT INTO @STATUSCODES([intAccountStatusId], [strAccountStatusCode], [intEntityCustomerId])
        SELECT S.[intAccountStatusId], S.[strAccountStatusCode], CAS.intEntityCustomerId
          FROM dbo.tblARAccountStatus S WITH (NOLOCK)
               INNER JOIN (
                           SELECT MIN(intAccountStatusId) intAccountStatusId, intEntityCustomerId
						     FROM tblARCustomerAccountStatus WITH (NOLOCK)
                            GROUP BY intEntityCustomerId
                          ) CAS 
                               ON S.intAccountStatusId = CAS.intAccountStatusId 
         WHERE [strAccountStatusCode] BETWEEN @strAccountStatusFrom AND @strAccountStatusTo
    END
ELSE IF (@conditionAccountStatus IS NOT NULL AND ISNULL(@strAccountStatusFrom, '') <> '')
    BEGIN
        SET @AccountStatusFiltered = @OneBit
        INSERT INTO @STATUSCODES([intAccountStatusId], [strAccountStatusCode], [intEntityCustomerId])
        SELECT S.[intAccountStatusId], S.[strAccountStatusCode], CAS.intEntityCustomerId
          FROM dbo.tblARAccountStatus S WITH (NOLOCK)
               INNER JOIN (
                           SELECT MIN(intAccountStatusId) intAccountStatusId, intEntityCustomerId
						     FROM tblARCustomerAccountStatus WITH (NOLOCK)
                            GROUP BY intEntityCustomerId
                          ) CAS 
                               ON S.intAccountStatusId = CAS.intAccountStatusId 
         WHERE [strAccountStatusCode] = @strAccountStatusFrom
    END
ELSE
    BEGIN
        SET @AccountStatusFiltered = @ZeroBit
        INSERT INTO @STATUSCODES([intAccountStatusId], [strAccountStatusCode], [intEntityCustomerId])
        SELECT S.[intAccountStatusId], S.[strAccountStatusCode], CAS.intEntityCustomerId
          FROM dbo.tblARAccountStatus S WITH (NOLOCK)
               INNER JOIN (
                           SELECT MIN(intAccountStatusId) intAccountStatusId, intEntityCustomerId
						     FROM tblARCustomerAccountStatus WITH (NOLOCK)
                            GROUP BY intEntityCustomerId
                          ) CAS 
                               ON S.intAccountStatusId = CAS.intAccountStatusId 
    END

--IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
--BEGIN
--    DROP TABLE #CUSTOMERS
--END

--CREATE TABLE #CUSTOMERS(
DECLARE @CUSTOMERS AS TABLE(
    [intEntityCustomerId]   INT PRIMARY KEY,
    [strCustomerNumber]     NVARCHAR(15)  COLLATE Latin1_General_CI_AS,
    [strCustomerName]       NVARCHAR(150) COLLATE Latin1_General_CI_AS,
    [strAccountStatusCode]  CHAR(1) COLLATE Latin1_General_CI_AS) 

IF (@conditionCustomer IS NOT NULL AND UPPER(@conditionCustomer) = 'BETWEEN' AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
        INSERT INTO @CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK) 
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                           WHERE strName BETWEEN @strCustomerNameFrom AND @strCustomerNameTo
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN @STATUSCODES SC
                               ON SC.[intEntityCustomerId] = C.intEntityId
         WHERE (@AccountStatusFiltered = @OneBit AND SC.[intAccountStatusId] IS NOT NULL)
            OR @AccountStatusFiltered = @ZeroBit
	END
ELSE IF (@conditionCustomer IS NOT NULL AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
        INSERT INTO @CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK) 
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                           WHERE strName = @strCustomerNameFrom
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN @STATUSCODES SC
                               ON SC.[intEntityCustomerId] = C.intEntityId
         WHERE (@AccountStatusFiltered = @OneBit AND SC.[intAccountStatusId] IS NOT NULL)
            OR @AccountStatusFiltered = @ZeroBit
	END
ELSE
	BEGIN
        INSERT INTO @CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK)
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN @STATUSCODES SC
                               ON SC.[intEntityCustomerId] = C.intEntityId
         WHERE (@AccountStatusFiltered = @OneBit AND SC.[intAccountStatusId] IS NOT NULL)
            OR @AccountStatusFiltered = @ZeroBit

	END

--IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
--BEGIN
--    DROP TABLE #COMPANYLOCATIONS
--END

--CREATE TABLE #COMPANYLOCATIONS ([intCompanyLocationId] INT PRIMARY KEY, [strCompanyNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS)
DECLARE @COMPANYLOCATIONS AS TABLE ([intCompanyLocationId] INT PRIMARY KEY, [strCompanyNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS)

IF (@conditionLocation IS NOT NULL AND UPPER(@conditionLocation) = 'BETWEEN' AND ISNULL(@strLocationNumberFrom, '') <> '')
    BEGIN
        INSERT INTO @COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
         WHERE strLocationNumber BETWEEN @strLocationNumberFrom AND @strLocationNumberTo
    END
ELSE IF (@conditionLocation IS NOT NULL AND ISNULL(@strLocationNumberFrom, '') <> '')
    BEGIN
        INSERT INTO @COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE strLocationNumber = @strLocationNumberFrom
    END
ELSE
    BEGIN
        INSERT INTO @COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
    END

--IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
--BEGIN
--    DROP TABLE #INVOICES
--END

DECLARE @TYPES AS TABLE ([strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS PRIMARY KEY)

IF (@conditionType IS NOT NULL AND UPPER(@conditionType) = 'BETWEEN' AND ISNULL(@strTypeFrom, '') <> '')
    BEGIN
        INSERT INTO @TYPES([strType])
        SELECT [strInvoiceSource]
          FROM [dbo].[fnARGetInvoiceSourceList]()
         WHERE [strInvoiceSource] BETWEEN @strLocationNumberFrom AND @strLocationNumberTo
    END
ELSE IF (@conditionType IS NOT NULL AND ISNULL(@strTypeFrom, '') <> '')
    BEGIN
        INSERT INTO @TYPES([strType])
        SELECT [strInvoiceSource]
          FROM [dbo].[fnARGetInvoiceSourceList]()
		WHERE [strInvoiceSource] = @strTypeFrom
    END
ELSE
    BEGIN
        INSERT INTO @TYPES([strType])
        SELECT [strInvoiceSource]
          FROM [dbo].[fnARGetInvoiceSourceList]()
    END

--CREATE TABLE #INVOICES
DECLARE @INVOICES AS TABLE
    ([intInvoiceId]         INT PRIMARY KEY,
    [strInvoiceNumber]      NVARCHAR(25)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]               NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strSalespersonName]    NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]               DATETIME                                   NULL)

IF (@conditionInvoice IS NOT NULL AND UPPER(@conditionInvoice) = 'BETWEEN' AND ISNULL(@strInvoiceNumberFrom, '') <> '')
    BEGIN
        INSERT INTO @INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName], [dtmDate])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName, I.dtmDate
          FROM dbo.tblARInvoice I WITH (NOLOCK)
               LEFT OUTER JOIN (
                               SELECT SP.intEntityId, E.strName
                                 FROM tblARSalesperson SP WITH (NOLOCK)
                                      INNER JOIN tblEMEntity E
                                                 ON SP.intEntityId = E.intEntityId
                               ) S ON I.intEntitySalespersonId = S.intEntityId
         WHERE I.strInvoiceNumber BETWEEN @strInvoiceNumberFrom AND @strInvoiceNumberTo
           AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
           AND (@strSalespersonName IS NULL OR S.strName LIKE '%' + @strSalespersonName + '%')
           --AND I.dblTax <> 0.000000
    END
ELSE IF (@conditionInvoice IS NOT NULL AND ISNULL(@strInvoiceNumberFrom, '') <> '')
    BEGIN
        INSERT INTO @INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName], [dtmDate])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName, I.dtmDate
          FROM dbo.tblARInvoice I WITH (NOLOCK)
               LEFT OUTER JOIN (
                               SELECT SP.intEntityId, E.strName
                                 FROM tblARSalesperson SP WITH (NOLOCK)
                                      INNER JOIN tblEMEntity E
                                                 ON SP.intEntityId = E.intEntityId
                               ) S ON I.intEntitySalespersonId = S.intEntityId
         WHERE I.strInvoiceNumber = @strInvoiceNumberFrom
           AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
           AND (@strSalespersonName IS NULL OR S.strName LIKE '%' + @strSalespersonName + '%')
           --AND I.dblTax <> 0.000000
    END
ELSE
    BEGIN
        INSERT INTO @INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName], [dtmDate])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName, I.dtmDate
          FROM dbo.tblARInvoice I WITH (NOLOCK)
               LEFT OUTER JOIN (
                               SELECT SP.intEntityId, E.strName
                                 FROM tblARSalesperson SP WITH (NOLOCK)
                                      INNER JOIN tblEMEntity E
                                                 ON SP.intEntityId = E.intEntityId
                               ) S ON I.intEntitySalespersonId = S.intEntityId
         WHERE I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
           AND (@strSalespersonName IS NULL OR S.strName LIKE '%' + @strSalespersonName + '%')
           --AND I.dblTax <> 0.000000
    END

--IF(OBJECT_ID('tempdb..#ITEMS') IS NOT NULL)
--BEGIN
--    DROP TABLE #ITEMS
--END

--CREATE TABLE #ITEMS ([intItemId] INT PRIMARY KEY, [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS, [intCategoryId] INT)
DECLARE @ITEMS AS TABLE ([intItemId] INT PRIMARY KEY, [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS, [intCategoryId] INT)

INSERT INTO @ITEMS([intItemId], [strItemNo], [intCategoryId])
SELECT [intItemId], [strItemNo], [intCategoryId]
  FROM dbo.tblICItem WITH (NOLOCK)
 WHERE (@strItemNo IS NULL OR [strItemNo] LIKE '%' + @strItemNo + '%')

--IF(OBJECT_ID('tempdb..#CATEGORIES') IS NOT NULL)
--BEGIN
--    DROP TABLE #CATEGORIES
--END

--CREATE TABLE #CATEGORIES ([intCategoryId] INT PRIMARY KEY, [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DECLARE @CATEGORIES AS TABLE ([intCategoryId] INT PRIMARY KEY, [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS)

IF (@conditionCategory IS NOT NULL AND UPPER(@conditionCategory) = 'BETWEEN' AND ISNULL(@strCategoryFrom, '') <> '')
    BEGIN
        INSERT INTO @CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
         WHERE [strCategoryCode] BETWEEN @strCategoryFrom AND @strCategoryTo
    END
ELSE IF (@conditionCategory IS NOT NULL AND ISNULL(@strCategoryFrom, '') <> '')
    BEGIN
        INSERT INTO @CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
         WHERE [strCategoryCode] = @strCategoryFrom
    END
ELSE
    BEGIN
        INSERT INTO @CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
    END


--SET FMTONLY ON
IF @strSubTotalBy = 'Tax Group'
BEGIN
    SELECT
           [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = C.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = C.[strCustomerNumber]
         , [strCustomerName]              = C.[strCustomerName]
         , [strAccountStatusCode]         = C.[strAccountStatusCode]
         , [strCompanyNumber]             = CL.[strCompanyNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = null --@EntityUserId
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ICI.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ICI.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ICI.[strItemNo] ELSE LTRIM(RTRIM(ICI.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ICC.[strCategoryCode]
         , [dblQtyShipped]                = OT.[dblQtyShipped]
         , [dblPrice]                     = OT.[dblPrice]
         , [dblTotalTax]                  = OT.[dblTotalTax]
         , [dblTotalTaxOnTax]             = OT.[dblSSTOnCheckoffTax] + OT.[dblSSTOnCitySalesTax] + OT.[dblSSTOnCityExciseTax] + OT.[dblSSTOnCountySalesTax] + OT.[dblSSTOnCountyExciseTax] + OT.[dblSSTOnFederalExciseTax] + OT.[dblSSTOnFederalLustTax]
                                            + OT.[dblSSTOnFederalOilSpillTax] + OT.[dblSSTOnFederalOtherTax] + OT.[dblSSTOnLocalOtherTax] + OT.[dblSSTOnPrepaidSalesTax] + OT.[dblSSTOnStateExciseTax] + OT.[dblSSTOnStateOtherTax] + OT.[dblSSTOnTonnageTax]
         , [dblTotal]                     = OT.[dblTotal]
         , [dblLineTotal]                 = OT.[dblTotal] + OT.[dblTotalTax]
         , [strTaxGroup]                  = OT.[strTaxGroup]
         , [strTaxCode]                   = '' --OT.[strTaxCode]
         , [strState]                     = '' --OT.[strState]
         , [strTaxClass]                  = '' --OT.[strTaxClass]
         , [strGrouping]                  = OT.[strTaxGroup]
         , [strGroupingLabel]             = 'Tax Group : '
         , [ysnInvoiceDetail]             = @ysnInvoiceDetail
         , [dblCheckoffTax]               = OT.[dblCheckoffTax]
         , [dblCitySalesTax]              = OT.[dblCitySalesTax]
         , [dblCityExciseTax]             = OT.[dblCityExciseTax]
         , [dblCountySalesTax]            = OT.[dblCountySalesTax]
         , [dblCountyExciseTax]           = OT.[dblCountyExciseTax]
         , [dblFederalExciseTax]          = OT.[dblFederalExciseTax]
         , [dblFederalLustTax]            = OT.[dblFederalLustTax]
         , [dblFederalOilSpillTax]        = OT.[dblFederalOilSpillTax]
         , [dblFederalOtherTax]           = OT.[dblFederalOtherTax]
         , [dblLocalOtherTax]             = OT.[dblLocalOtherTax]
         , [dblPrepaidSalesTax]           = OT.[dblPrepaidSalesTax]
         , [dblStateExciseTax]            = OT.[dblStateExciseTax]
         , [dblStateOtherTax]             = OT.[dblStateOtherTax]
         , [dblStateSalesTax]             = OT.[dblStateSalesTax]
         , [dblTonnageTax]                = OT.[dblTonnageTax]
         , [dblSSTOnCheckoffTax]          = OT.[dblSSTOnCheckoffTax]
         , [dblSSTOnCitySalesTax]         = OT.[dblSSTOnCitySalesTax]
         , [dblSSTOnCityExciseTax]        = OT.[dblSSTOnCityExciseTax]
         , [dblSSTOnCountySalesTax]       = OT.[dblSSTOnCountySalesTax]
         , [dblSSTOnCountyExciseTax]      = OT.[dblSSTOnCountyExciseTax]
         , [dblSSTOnFederalExciseTax]     = OT.[dblSSTOnFederalExciseTax]
         , [dblSSTOnFederalLustTax]       = OT.[dblSSTOnFederalLustTax]
         , [dblSSTOnFederalOilSpillTax]   = OT.[dblSSTOnFederalOilSpillTax]
         , [dblSSTOnFederalOtherTax]      = OT.[dblSSTOnFederalOtherTax]
         , [dblSSTOnLocalOtherTax]        = OT.[dblSSTOnLocalOtherTax]
         , [dblSSTOnPrepaidSalesTax]      = OT.[dblSSTOnPrepaidSalesTax]
         , [dblSSTOnStateExciseTax]       = OT.[dblSSTOnStateExciseTax]
         , [dblSSTOnStateOtherTax]        = OT.[dblSSTOnStateOtherTax]
         , [dblSSTOnTonnageTax]           = OT.[dblSSTOnTonnageTax]
      FROM (
           SELECT intTaxGroupId, strTaxGroup, intInvoiceDetailId, intInvoiceId
                , MIN(intEntityCustomerId) AS intEntityCustomerId
                , MIN(intCompanyLocationId) AS intCompanyLocationId
                , MIN(intItemId) AS intItemId
                , MIN(strItemDescription) AS strItemDescription
                , MIN(dblQtyShipped) AS dblQtyShipped
                , MIN(dblPrice) AS dblPrice
                , MIN(dblTotalTax) AS dblTotalTax
                , MIN(dblTotal) AS dblTotal
                , SUM(dblCheckoffTax) AS dblCheckoffTax
                , SUM(dblCitySalesTax) AS dblCitySalesTax
                , SUM(dblCityExciseTax) AS dblCityExciseTax
                , SUM(dblCountySalesTax) AS dblCountySalesTax
                , SUM(dblCountyExciseTax) AS dblCountyExciseTax
                , SUM(dblFederalExciseTax) AS dblFederalExciseTax
                , SUM(dblFederalLustTax) AS dblFederalLustTax
                , SUM(dblFederalOilSpillTax) AS dblFederalOilSpillTax
                , SUM(dblFederalOtherTax) AS dblFederalOtherTax
                , SUM(dblLocalOtherTax) AS dblLocalOtherTax
                , SUM(dblPrepaidSalesTax) AS dblPrepaidSalesTax
                , SUM(dblStateExciseTax) AS dblStateExciseTax
                , SUM(dblStateOtherTax) AS dblStateOtherTax
                , SUM(dblStateSalesTax) AS dblStateSalesTax
                , SUM(dblTonnageTax) AS dblTonnageTax
                , SUM(dblSSTOnCheckoffTax) AS dblSSTOnCheckoffTax
                , SUM(dblSSTOnCitySalesTax) AS dblSSTOnCitySalesTax
                , SUM(dblSSTOnCityExciseTax) AS dblSSTOnCityExciseTax
                , SUM(dblSSTOnCountySalesTax) AS dblSSTOnCountySalesTax
                , SUM(dblSSTOnCountyExciseTax) AS dblSSTOnCountyExciseTax
                , SUM(dblSSTOnFederalExciseTax) AS dblSSTOnFederalExciseTax
                , SUM(dblSSTOnFederalLustTax) AS dblSSTOnFederalLustTax
                , SUM(dblSSTOnFederalOilSpillTax) AS dblSSTOnFederalOilSpillTax
                , SUM(dblSSTOnFederalOtherTax) AS dblSSTOnFederalOtherTax
                , SUM(dblSSTOnLocalOtherTax) AS dblSSTOnLocalOtherTax
                , SUM(dblSSTOnPrepaidSalesTax) AS dblSSTOnPrepaidSalesTax
                , SUM(dblSSTOnStateExciseTax) AS dblSSTOnStateExciseTax
                , SUM(dblSSTOnStateOtherTax) AS dblSSTOnStateOtherTax
                , SUM(dblSSTOnTonnageTax) AS dblSSTOnTonnageTax
             FROM vyuAROutboundTaxReport WITH (NOLOCK)
            WHERE (@strState IS NULL OR strState LIKE '%'+ @strState +'%')
              AND (@strTaxGroup IS NULL OR strTaxGroup LIKE '%' + @strTaxGroup + '%')
              AND (
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
            GROUP BY intTaxGroupId, strTaxGroup, intInvoiceDetailId, intInvoiceId
           ) OT
             INNER JOIN @CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN @COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN @INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN @TYPES T
                        ON I.strType = T.strType
             INNER JOIN @ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN @CATEGORIES ICC
                        ON ICI.[intCategoryId] = ICC.[intCategoryId]
		 ORDER BY OT.strTaxGroup, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END

IF @strSubTotalBy = 'Customer'
BEGIN
    SELECT
           [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = C.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = C.[strCustomerNumber]
         , [strCustomerName]              = C.[strCustomerName]
         , [strAccountStatusCode]         = C.[strAccountStatusCode]
         , [strCompanyNumber]             = CL.[strCompanyNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = null --@EntityUserId
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ICI.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ICI.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ICI.[strItemNo] ELSE LTRIM(RTRIM(ICI.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ICC.[strCategoryCode]
         , [dblQtyShipped]                = OT.[dblQtyShipped]
         , [dblPrice]                     = OT.[dblPrice]
         , [dblTotalTax]                  = OT.[dblTotalTax]
         , [dblTotalTaxOnTax]             = OT.[dblSSTOnCheckoffTax] + OT.[dblSSTOnCitySalesTax] + OT.[dblSSTOnCityExciseTax] + OT.[dblSSTOnCountySalesTax] + OT.[dblSSTOnCountyExciseTax] + OT.[dblSSTOnFederalExciseTax] + OT.[dblSSTOnFederalLustTax]
                                            + OT.[dblSSTOnFederalOilSpillTax] + OT.[dblSSTOnFederalOtherTax] + OT.[dblSSTOnLocalOtherTax] + OT.[dblSSTOnPrepaidSalesTax] + OT.[dblSSTOnStateExciseTax] + OT.[dblSSTOnStateOtherTax] + OT.[dblSSTOnTonnageTax]
         , [dblTotal]                     = OT.[dblTotal]
         , [dblLineTotal]                 = OT.[dblTotal] + OT.[dblTotalTax]
         , [strTaxGroup]                  = OT.[strTaxGroup]
         , [strTaxCode]                   = '' --OT.[strTaxCode]
         , [strState]                     = '' --OT.[strState]
         , [strTaxClass]                  = '' --OT.[strTaxClass]
         , [strGrouping]                  = C.[strCustomerName]
         , [strGroupingLabel]             = 'Customer : '
         , [ysnInvoiceDetail]             = @ysnInvoiceDetail
         , [dblCheckoffTax]               = OT.[dblCheckoffTax]
         , [dblCitySalesTax]              = OT.[dblCitySalesTax]
         , [dblCityExciseTax]             = OT.[dblCityExciseTax]
         , [dblCountySalesTax]            = OT.[dblCountySalesTax]
         , [dblCountyExciseTax]           = OT.[dblCountyExciseTax]
         , [dblFederalExciseTax]          = OT.[dblFederalExciseTax]
         , [dblFederalLustTax]            = OT.[dblFederalLustTax]
         , [dblFederalOilSpillTax]        = OT.[dblFederalOilSpillTax]
         , [dblFederalOtherTax]           = OT.[dblFederalOtherTax]
         , [dblLocalOtherTax]             = OT.[dblLocalOtherTax]
         , [dblPrepaidSalesTax]           = OT.[dblPrepaidSalesTax]
         , [dblStateExciseTax]            = OT.[dblStateExciseTax]
         , [dblStateOtherTax]             = OT.[dblStateOtherTax]
         , [dblStateSalesTax]             = OT.[dblStateSalesTax]
         , [dblTonnageTax]                = OT.[dblTonnageTax]
         , [dblSSTOnCheckoffTax]          = OT.[dblSSTOnCheckoffTax]
         , [dblSSTOnCitySalesTax]         = OT.[dblSSTOnCitySalesTax]
         , [dblSSTOnCityExciseTax]        = OT.[dblSSTOnCityExciseTax]
         , [dblSSTOnCountySalesTax]       = OT.[dblSSTOnCountySalesTax]
         , [dblSSTOnCountyExciseTax]      = OT.[dblSSTOnCountyExciseTax]
         , [dblSSTOnFederalExciseTax]     = OT.[dblSSTOnFederalExciseTax]
         , [dblSSTOnFederalLustTax]       = OT.[dblSSTOnFederalLustTax]
         , [dblSSTOnFederalOilSpillTax]   = OT.[dblSSTOnFederalOilSpillTax]
         , [dblSSTOnFederalOtherTax]      = OT.[dblSSTOnFederalOtherTax]
         , [dblSSTOnLocalOtherTax]        = OT.[dblSSTOnLocalOtherTax]
         , [dblSSTOnPrepaidSalesTax]      = OT.[dblSSTOnPrepaidSalesTax]
         , [dblSSTOnStateExciseTax]       = OT.[dblSSTOnStateExciseTax]
         , [dblSSTOnStateOtherTax]        = OT.[dblSSTOnStateOtherTax]
         , [dblSSTOnTonnageTax]           = OT.[dblSSTOnTonnageTax]
      FROM (
           SELECT intEntityCustomerId, intInvoiceDetailId, intInvoiceId
                , MIN(intCompanyLocationId) AS intCompanyLocationId
                , MIN(intItemId) AS intItemId
                , MIN(strItemDescription) AS strItemDescription
                , MIN(dblQtyShipped) AS dblQtyShipped
                , MIN(dblPrice) AS dblPrice
                , MIN(dblTotalTax) AS dblTotalTax
                , MIN(dblTotal) AS dblTotal
                , MIN(intTaxGroupId) AS intTaxGroupId
                , MIN(strTaxGroup) AS strTaxGroup
                , SUM(dblCheckoffTax) AS dblCheckoffTax
                , SUM(dblCitySalesTax) AS dblCitySalesTax
                , SUM(dblCityExciseTax) AS dblCityExciseTax
                , SUM(dblCountySalesTax) AS dblCountySalesTax
                , SUM(dblCountyExciseTax) AS dblCountyExciseTax
                , SUM(dblFederalExciseTax) AS dblFederalExciseTax
                , SUM(dblFederalLustTax) AS dblFederalLustTax
                , SUM(dblFederalOilSpillTax) AS dblFederalOilSpillTax
                , SUM(dblFederalOtherTax) AS dblFederalOtherTax
                , SUM(dblLocalOtherTax) AS dblLocalOtherTax
                , SUM(dblPrepaidSalesTax) AS dblPrepaidSalesTax
                , SUM(dblStateExciseTax) AS dblStateExciseTax
                , SUM(dblStateOtherTax) AS dblStateOtherTax
                , SUM(dblStateSalesTax) AS dblStateSalesTax
                , SUM(dblTonnageTax) AS dblTonnageTax
                , SUM(dblSSTOnCheckoffTax) AS dblSSTOnCheckoffTax
                , SUM(dblSSTOnCitySalesTax) AS dblSSTOnCitySalesTax
                , SUM(dblSSTOnCityExciseTax) AS dblSSTOnCityExciseTax
                , SUM(dblSSTOnCountySalesTax) AS dblSSTOnCountySalesTax
                , SUM(dblSSTOnCountyExciseTax) AS dblSSTOnCountyExciseTax
                , SUM(dblSSTOnFederalExciseTax) AS dblSSTOnFederalExciseTax
                , SUM(dblSSTOnFederalLustTax) AS dblSSTOnFederalLustTax
                , SUM(dblSSTOnFederalOilSpillTax) AS dblSSTOnFederalOilSpillTax
                , SUM(dblSSTOnFederalOtherTax) AS dblSSTOnFederalOtherTax
                , SUM(dblSSTOnLocalOtherTax) AS dblSSTOnLocalOtherTax
                , SUM(dblSSTOnPrepaidSalesTax) AS dblSSTOnPrepaidSalesTax
                , SUM(dblSSTOnStateExciseTax) AS dblSSTOnStateExciseTax
                , SUM(dblSSTOnStateOtherTax) AS dblSSTOnStateOtherTax
                , SUM(dblSSTOnTonnageTax) AS dblSSTOnTonnageTax
             FROM vyuAROutboundTaxReport WITH (NOLOCK)
            WHERE (@strState IS NULL OR strState LIKE '%'+ @strState +'%')
              AND (@strTaxGroup IS NULL OR strTaxGroup LIKE '%' + @strTaxGroup + '%')
              AND (
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
            GROUP BY intEntityCustomerId, intInvoiceDetailId, intInvoiceId
           ) OT
             INNER JOIN @CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN @COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN @INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN @TYPES T
                        ON I.strType = T.strType
             INNER JOIN @ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN @CATEGORIES ICC
                        ON ICI.[intCategoryId] = ICC.[intCategoryId]
		 ORDER BY C.strCustomerName, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END

IF @strSubTotalBy = 'Tax Code'
BEGIN
    SELECT
           [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = C.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = C.[strCustomerNumber]
         , [strCustomerName]              = C.[strCustomerName]
         , [strAccountStatusCode]         = C.[strAccountStatusCode]
         , [strCompanyNumber]             = CL.[strCompanyNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = null --@EntityUserId
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ICI.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ICI.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ICI.[strItemNo] ELSE LTRIM(RTRIM(ICI.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ICC.[strCategoryCode]
         , [dblQtyShipped]                = OT.[dblQtyShipped]
         , [dblPrice]                     = OT.[dblPrice]
         , [dblTotalTax]                  = OT.[dblTotalTax]
         , [dblTotalTaxOnTax]             = OT.[dblSSTOnCheckoffTax] + OT.[dblSSTOnCitySalesTax] + OT.[dblSSTOnCityExciseTax] + OT.[dblSSTOnCountySalesTax] + OT.[dblSSTOnCountyExciseTax] + OT.[dblSSTOnFederalExciseTax] + OT.[dblSSTOnFederalLustTax]
                                            + OT.[dblSSTOnFederalOilSpillTax] + OT.[dblSSTOnFederalOtherTax] + OT.[dblSSTOnLocalOtherTax] + OT.[dblSSTOnPrepaidSalesTax] + OT.[dblSSTOnStateExciseTax] + OT.[dblSSTOnStateOtherTax] + OT.[dblSSTOnTonnageTax]
         , [dblTotal]                     = OT.[dblTotal]
         , [dblLineTotal]                 = OT.[dblTotal] + OT.[dblTotalTax]
         , [strTaxGroup]                  = OT.[strTaxGroup]
         , [strTaxCode]                   = OT.[strTaxCode]
         , [strState]                     = '' --OT.[strState]
         , [strTaxClass]                  = '' --OT.[strTaxClass]
         , [strGrouping]                  = OT.[strTaxCode]
         , [strGroupingLabel]             = 'Tax Code : '
         , [ysnInvoiceDetail]             = @ysnInvoiceDetail
         , [dblCheckoffTax]               = OT.[dblCheckoffTax]
         , [dblCitySalesTax]              = OT.[dblCitySalesTax]
         , [dblCityExciseTax]             = OT.[dblCityExciseTax]
         , [dblCountySalesTax]            = OT.[dblCountySalesTax]
         , [dblCountyExciseTax]           = OT.[dblCountyExciseTax]
         , [dblFederalExciseTax]          = OT.[dblFederalExciseTax]
         , [dblFederalLustTax]            = OT.[dblFederalLustTax]
         , [dblFederalOilSpillTax]        = OT.[dblFederalOilSpillTax]
         , [dblFederalOtherTax]           = OT.[dblFederalOtherTax]
         , [dblLocalOtherTax]             = OT.[dblLocalOtherTax]
         , [dblPrepaidSalesTax]           = OT.[dblPrepaidSalesTax]
         , [dblStateExciseTax]            = OT.[dblStateExciseTax]
         , [dblStateOtherTax]             = OT.[dblStateOtherTax]
         , [dblStateSalesTax]             = OT.[dblStateSalesTax]
         , [dblTonnageTax]                = OT.[dblTonnageTax]
         , [dblSSTOnCheckoffTax]          = OT.[dblSSTOnCheckoffTax]
         , [dblSSTOnCitySalesTax]         = OT.[dblSSTOnCitySalesTax]
         , [dblSSTOnCityExciseTax]        = OT.[dblSSTOnCityExciseTax]
         , [dblSSTOnCountySalesTax]       = OT.[dblSSTOnCountySalesTax]
         , [dblSSTOnCountyExciseTax]      = OT.[dblSSTOnCountyExciseTax]
         , [dblSSTOnFederalExciseTax]     = OT.[dblSSTOnFederalExciseTax]
         , [dblSSTOnFederalLustTax]       = OT.[dblSSTOnFederalLustTax]
         , [dblSSTOnFederalOilSpillTax]   = OT.[dblSSTOnFederalOilSpillTax]
         , [dblSSTOnFederalOtherTax]      = OT.[dblSSTOnFederalOtherTax]
         , [dblSSTOnLocalOtherTax]        = OT.[dblSSTOnLocalOtherTax]
         , [dblSSTOnPrepaidSalesTax]      = OT.[dblSSTOnPrepaidSalesTax]
         , [dblSSTOnStateExciseTax]       = OT.[dblSSTOnStateExciseTax]
         , [dblSSTOnStateOtherTax]        = OT.[dblSSTOnStateOtherTax]
         , [dblSSTOnTonnageTax]           = OT.[dblSSTOnTonnageTax]
      FROM (
           SELECT intTaxCodeId, strTaxCode, intInvoiceDetailId, intInvoiceId
                , MIN(intEntityCustomerId) AS intEntityCustomerId
                , MIN(intCompanyLocationId) AS intCompanyLocationId
                , MIN(intItemId) AS intItemId
                , MIN(strItemDescription) AS strItemDescription
                , MIN(dblQtyShipped) AS dblQtyShipped
                , MIN(dblPrice) AS dblPrice
                , MIN(dblTotalTax) AS dblTotalTax
                , MIN(dblTotal) AS dblTotal
                , MIN(intTaxGroupId) AS intTaxGroupId
                , MIN(strTaxGroup) AS strTaxGroup
                , SUM(dblCheckoffTax) AS dblCheckoffTax
                , SUM(dblCitySalesTax) AS dblCitySalesTax
                , SUM(dblCityExciseTax) AS dblCityExciseTax
                , SUM(dblCountySalesTax) AS dblCountySalesTax
                , SUM(dblCountyExciseTax) AS dblCountyExciseTax
                , SUM(dblFederalExciseTax) AS dblFederalExciseTax
                , SUM(dblFederalLustTax) AS dblFederalLustTax
                , SUM(dblFederalOilSpillTax) AS dblFederalOilSpillTax
                , SUM(dblFederalOtherTax) AS dblFederalOtherTax
                , SUM(dblLocalOtherTax) AS dblLocalOtherTax
                , SUM(dblPrepaidSalesTax) AS dblPrepaidSalesTax
                , SUM(dblStateExciseTax) AS dblStateExciseTax
                , SUM(dblStateOtherTax) AS dblStateOtherTax
                , SUM(dblStateSalesTax) AS dblStateSalesTax
                , SUM(dblTonnageTax) AS dblTonnageTax
                , SUM(dblSSTOnCheckoffTax) AS dblSSTOnCheckoffTax
                , SUM(dblSSTOnCitySalesTax) AS dblSSTOnCitySalesTax
                , SUM(dblSSTOnCityExciseTax) AS dblSSTOnCityExciseTax
                , SUM(dblSSTOnCountySalesTax) AS dblSSTOnCountySalesTax
                , SUM(dblSSTOnCountyExciseTax) AS dblSSTOnCountyExciseTax
                , SUM(dblSSTOnFederalExciseTax) AS dblSSTOnFederalExciseTax
                , SUM(dblSSTOnFederalLustTax) AS dblSSTOnFederalLustTax
                , SUM(dblSSTOnFederalOilSpillTax) AS dblSSTOnFederalOilSpillTax
                , SUM(dblSSTOnFederalOtherTax) AS dblSSTOnFederalOtherTax
                , SUM(dblSSTOnLocalOtherTax) AS dblSSTOnLocalOtherTax
                , SUM(dblSSTOnPrepaidSalesTax) AS dblSSTOnPrepaidSalesTax
                , SUM(dblSSTOnStateExciseTax) AS dblSSTOnStateExciseTax
                , SUM(dblSSTOnStateOtherTax) AS dblSSTOnStateOtherTax
                , SUM(dblSSTOnTonnageTax) AS dblSSTOnTonnageTax
             FROM vyuAROutboundTaxReport WITH (NOLOCK)
            WHERE (@strState IS NULL OR strState LIKE '%'+ @strState +'%')
              AND (@strTaxGroup IS NULL OR strTaxGroup LIKE '%' + @strTaxGroup + '%')
              AND (
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND (@strTaxCode IS NULL OR strTaxCode LIKE '%'+ @strTaxCode +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'
                        AND (@strTaxClass IS NULL OR strTaxClass LIKE '%'+ @strTaxClass +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND (@strTaxClassType IS NULL OR strType LIKE '%'+ @strTaxClassType +'%')
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
             --AND ysnTaxExempt = 1
            GROUP BY intTaxCodeId, strTaxCode, intInvoiceDetailId, intInvoiceId
           ) OT
             INNER JOIN @CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN @COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN @INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN @TYPES T
                        ON I.strType = T.strType
             INNER JOIN @ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN @CATEGORIES ICC
                        ON ICI.[intCategoryId] = ICC.[intCategoryId]
		 ORDER BY OT.strTaxCode, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END


