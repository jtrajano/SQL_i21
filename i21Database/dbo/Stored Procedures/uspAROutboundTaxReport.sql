CREATE PROCEDURE [dbo].[uspAROutboundTaxReport]
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
	END

-- Declare the variables.
DECLARE	@ZeroBit        BIT
       ,@OneBit         BIT
       ,@ZeroDecimal    DECIMAL(18,6)

SET @ZeroDecimal = CAST(0.000000 AS DECIMAL(18,6))
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

DECLARE 
	    @strTaxCode             NVARCHAR(100)
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


SET @strSubTotalBy = 'Tax Group'
SET @strIncludeExemptOnly = 'No'
SELECT TOP 1 
       @strCompanyName    = strCompanyName
     , @strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) COLLATE Latin1_General_CI_AS
 FROM dbo.tblSMCompanySetup WITH (NOLOCK)

		
-- Create a table variable to hold the XML data. 		
DECLARE @Parameters TABLE (
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
INSERT INTO @Parameters
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
SELECT TOP 1
       @strTaxCode = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strTaxCode'
 ORDER BY [id]

SELECT TOP 1
       @strState = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strState'
 ORDER BY [id]

SELECT TOP 1
       @strTaxClassType = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strTaxReportType'
 ORDER BY [id]

SELECT TOP 1
       @strTaxClass = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strTaxClass'
 ORDER BY [id]

SELECT TOP 1
       @strTaxGroup = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strTaxGroup'
 ORDER BY [id]

SELECT TOP 1
       @strSubTotalBy = REPLACE(ISNULL([from], 'Tax Group'), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strSubTotalBy'
 ORDER BY [id]

SELECT TOP 1
       @strIncludeExemptOnly = REPLACE(ISNULL([from], 'No'), '''''', '''')
  FROM @Parameters
 WHERE [fieldname] = 'strIncludeExemptOnly'
 ORDER BY [id]

SELECT TOP 1
       @ysnInvoiceDetail = [from] 
  FROM @Parameters
 WHERE [fieldname] = 'ysnInvoiceDetail'
 ORDER BY [id]


DECLARE @Query AS NVARCHAR(MAX)
      , @Id    AS INT
      , @MinId AS INT
      , @MaxId AS INT

DECLARE @TempParameters TABLE (
        [id]         INT
      , [fieldname]  NVARCHAR(50)
      , [condition]  NVARCHAR(20)
      , [from]       NVARCHAR(100)
      , [to]         NVARCHAR(100)
      , [join]       NVARCHAR(10)
      , [begingroup] NVARCHAR(50)
      , [endgroup]   NVARCHAR(50)
      , [datatype]   NVARCHAR(50)
)

SET FMTONLY OFF
IF OBJECT_ID('tempdb..#STATUSCODES') IS NOT NULL DROP TABLE #STATUSCODES
CREATE TABLE #STATUSCODES([intAccountStatusId] INT, [strAccountStatusCode] CHAR(1) COLLATE Latin1_General_CI_AS, [intEntityCustomerId] INT)
DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strAccountStatusCode'
 ORDER BY [id]

DECLARE @strAccountStatusCodeFilter AS NVARCHAR(MAX)
      , @AccountStatusFiltered      AS BIT
SET @AccountStatusFiltered = @ZeroBit
SET @strAccountStatusCodeFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id                         = [id]
             , @strAccountStatusCodeFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strAccountStatusCodeFilter END) + [dbo].[fnARParseReportParameter]('[strAccountStatusCode]', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strAccountStatusCodeFilter = '(' + @strAccountStatusCodeFilter + ')'
IF LTRIM(RTRIM(ISNULL(@strAccountStatusCodeFilter, ''))) <> '' SET @AccountStatusFiltered = @OneBit
SET @Query = '
        INSERT INTO #STATUSCODES([intAccountStatusId], [strAccountStatusCode], [intEntityCustomerId])
        SELECT S.[intAccountStatusId], S.[strAccountStatusCode], CAS.intEntityCustomerId
          FROM dbo.tblARAccountStatus S WITH (NOLOCK)
               INNER JOIN (
                           SELECT MIN(intAccountStatusId) intAccountStatusId, intEntityCustomerId
						     FROM tblARCustomerAccountStatus WITH (NOLOCK)
                            GROUP BY intEntityCustomerId
                          ) CAS 
                               ON S.intAccountStatusId = CAS.intAccountStatusId 
'
+
ISNULL(('WHERE ' + @strAccountStatusCodeFilter), '')

EXECUTE(@Query);

IF OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL DROP TABLE #CUSTOMERS
CREATE TABLE #CUSTOMERS(
    [intEntityCustomerId]   INT PRIMARY KEY,
    [strCustomerNumber]     NVARCHAR(15)  COLLATE Latin1_General_CI_AS,
    [strCustomerName]       NVARCHAR(150) COLLATE Latin1_General_CI_AS,
    [strAccountStatusCode]  CHAR(1) COLLATE Latin1_General_CI_AS)

DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strCustomerName'
 ORDER BY [id]

DECLARE @strCustomerNameFilter AS NVARCHAR(MAX)
SET @strCustomerNameFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id                    = [id]
             , @strCustomerNameFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strCustomerNameFilter END) + [dbo].[fnARParseReportParameter]('strName', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strCustomerNameFilter = '(' + @strCustomerNameFilter + ')'
SET @Query = '
        INSERT INTO #CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK) 
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)'
+
ISNULL(('                  WHERE ' + @strCustomerNameFilter), '')
+
'                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN #STATUSCODES SC
                               ON SC.[intEntityCustomerId] = C.intEntityId
         WHERE (' + (CASE WHEN @AccountStatusFiltered = @OneBit THEN '1' ELSE '0' END) + ' = 1 AND SC.[intAccountStatusId] IS NOT NULL)
            OR ' + (CASE WHEN @AccountStatusFiltered = @OneBit THEN '1' ELSE '0' END) + ' = 0
'

EXECUTE(@Query);


IF OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL DROP TABLE #COMPANYLOCATIONS
CREATE TABLE #COMPANYLOCATIONS ([intCompanyLocationId] INT PRIMARY KEY, [strCompanyNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS)
DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strLocationNumber'
 ORDER BY [id]

DECLARE @strLocationNumberFilter AS NVARCHAR(MAX)
SET @strLocationNumberFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id                      = [id]
             , @strLocationNumberFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strLocationNumberFilter END) + [dbo].[fnARParseReportParameter]('strLocationNumber', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strLocationNumberFilter = '(' + @strLocationNumberFilter + ')'
SET @Query = '
        INSERT INTO #COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
'
+
ISNULL(('       WHERE ' + @strLocationNumberFilter), '')

EXECUTE(@Query);


IF OBJECT_ID('tempdb..#TYPES') IS NOT NULL DROP TABLE #TYPES
CREATE TABLE #TYPES ([strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS PRIMARY KEY)
DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strType'
 ORDER BY [id]

DECLARE @strTypeFilter AS NVARCHAR(MAX)
SET @strTypeFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id            = [id]
             , @strTypeFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strTypeFilter END) + [dbo].[fnARParseReportParameter]('[strInvoiceSource]', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strTypeFilter = '(' + @strTypeFilter + ')'
SET @Query = '
        INSERT INTO #TYPES([strType])
        SELECT [strInvoiceSource]
          FROM [dbo].[fnARGetInvoiceSourceList]()
'
+
ISNULL(('       WHERE ' + @strTypeFilter), '')

EXECUTE(@Query);


IF OBJECT_ID('tempdb..#ITEMS') IS NOT NULL DROP TABLE #ITEMS
CREATE TABLE #ITEMS ([intItemId] INT PRIMARY KEY, [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS, [intCategoryId] INT)
DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strItemNo'
 ORDER BY [id]

DECLARE @strItemNoFilter AS NVARCHAR(MAX)
SET @strItemNoFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id              = [id]
             , @strItemNoFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strItemNoFilter END) + [dbo].[fnARParseReportParameter]('[strItemNo]', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strItemNoFilter = '(' + @strItemNoFilter + ')'
SET @Query = '
        INSERT INTO #ITEMS([intItemId], [strItemNo], [intCategoryId])
        SELECT [intItemId], [strItemNo], [intCategoryId]
          FROM dbo.tblICItem WITH (NOLOCK)
'
+
ISNULL(('WHERE ' + @strItemNoFilter), '')

EXECUTE(@Query);


IF OBJECT_ID('tempdb..#CATEGORIES') IS NOT NULL DROP TABLE #CATEGORIES
CREATE TABLE #CATEGORIES([intCategoryId] INT PRIMARY KEY, [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strCategoryCode'
 ORDER BY [id]

DECLARE @strCategoryCodeFilter AS NVARCHAR(MAX)
SET @strCategoryCodeFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id                    = [id]
             , @strCategoryCodeFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strCategoryCodeFilter END) + [dbo].[fnARParseReportParameter]('[strCategoryCode]', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strCategoryCodeFilter = '(' + @strCategoryCodeFilter + ')'
SET @Query = '
        INSERT INTO #CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
'
+
ISNULL(('WHERE ' + @strCategoryCodeFilter), '')

EXECUTE(@Query);


DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'dtmDate'
 ORDER BY [id]

DECLARE @dtmDateFilter AS NVARCHAR(MAX)
SET @dtmDateFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id            = [id]
             , @dtmDateFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @dtmDateFilter END) + [dbo].[fnARParseReportParameter]('I.dtmDate', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END
SET @dtmDateFilter = '(' + @dtmDateFilter + ')'

DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strSalespersonName'
 ORDER BY [id]

DECLARE @strSalespersonNameFilter AS NVARCHAR(MAX)
SET @strSalespersonNameFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id            = [id]
             , @strSalespersonNameFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strSalespersonNameFilter END) + [dbo].[fnARParseReportParameter]('S.strName', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END
SET @strSalespersonNameFilter = '(' + @strSalespersonNameFilter + ')'

--CREATE TABLE #INVOICES
IF OBJECT_ID('tempdb..#INVOICES') IS NOT NULL DROP TABLE #INVOICES
CREATE TABLE #INVOICES
    ([intInvoiceId]         INT PRIMARY KEY,
    [strInvoiceNumber]      NVARCHAR(25)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]               NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strSalespersonName]    NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]               DATETIME                                   NULL)

DELETE FROM @TempParameters
INSERT INTO @TempParameters
SELECT *
  FROM @Parameters
 WHERE [fieldname] = 'strInvoiceNumber'
 ORDER BY [id]

DECLARE @strInvoiceNumberFilter AS NVARCHAR(MAX)
SET @strInvoiceNumberFilter = NULL
SET @Id = NULL
SELECT @MinId = MIN([id]), @MaxId = MAX([id]) FROM @TempParameters
WHILE EXISTS(SELECT NULL FROM @TempParameters)
    BEGIN
        SELECT TOP 1
               @Id                     = [id]
             , @strInvoiceNumberFilter = (CASE WHEN [id] = @MinId THEN '' ELSE @strInvoiceNumberFilter END) + [dbo].[fnARParseReportParameter]('I.strInvoiceNumber', [condition], [from], [to], (CASE WHEN [id] = @MaxId THEN '' ELSE [join] END), [datatype])
          FROM @TempParameters
         ORDER BY [id]

		DELETE FROM @TempParameters WHERE [id] = @Id
    END

SET @strInvoiceNumberFilter = '(' + @strInvoiceNumberFilter + ')'
SET @Query = '
        INSERT INTO #INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName], [dtmDate])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName, I.dtmDate
          FROM dbo.tblARInvoice I WITH (NOLOCK)
               LEFT OUTER JOIN (
                               SELECT SP.intEntityId, E.strName
                                 FROM tblARSalesperson SP WITH (NOLOCK)
                                      INNER JOIN tblEMEntity E
                                                 ON SP.intEntityId = E.intEntityId
                               ) S ON I.intEntitySalespersonId = S.intEntityId
'
+
ISNULL(('WHERE ' + @strInvoiceNumberFilter), '')
+
ISNULL(('  AND ' + @dtmDateFilter), '')
+
ISNULL(('  AND ' + @strSalespersonNameFilter), '')

EXECUTE(@Query);

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
         , [intUserId]                    = null
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
                        AND dblTotalTax <> @ZeroDecimal
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
             INNER JOIN #CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN #COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN #INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN #TYPES T
                        ON I.strType = T.strType
             INNER JOIN #ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN #CATEGORIES ICC
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
         , [intUserId]                    = null
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
                        AND dblTotalTax <> @ZeroDecimal
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
             INNER JOIN #CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN #COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN #INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN #TYPES T
                        ON I.strType = T.strType
             INNER JOIN #ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN #CATEGORIES ICC
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
         , [intUserId]                    = null
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
                        AND dblTotalTax <> @ZeroDecimal
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
            GROUP BY intTaxCodeId, strTaxCode, intInvoiceDetailId, intInvoiceId
           ) OT
             INNER JOIN #CUSTOMERS C 
                        ON OT.intEntityCustomerId = C.intEntityCustomerId
             INNER JOIN #COMPANYLOCATIONS CL
                        ON OT.intCompanyLocationId = CL.intCompanyLocationId
             INNER JOIN #INVOICES I
                        ON OT.intInvoiceId = I.intInvoiceId
             INNER JOIN #TYPES T
                        ON I.strType = T.strType
             INNER JOIN #ITEMS ICI
                        ON OT.[intItemId] = ICI.[intItemId]
             INNER JOIN #CATEGORIES ICC
                        ON ICI.[intCategoryId] = ICC.[intCategoryId]
		 ORDER BY OT.strTaxCode, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END