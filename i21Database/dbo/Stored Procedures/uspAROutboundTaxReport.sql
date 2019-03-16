CREATE PROCEDURE [dbo].[uspAROutboundTaxReport]
    @xmlParam      NVARCHAR(MAX) = NULL
    ,@EntityUserId INT           = NULL
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
        SELECT * FROM tblAROutboundTaxStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateFrom            DATETIME
	  , @dtmDateTo              DATETIME
	  , @conditionDate          NVARCHAR(20)
	  , @strInvoiceNumberFrom   NVARCHAR(100)
	  , @strInvoiceNumberTo     NVARCHAR(100)
	  , @conditionInvoice       NVARCHAR(20)
	  , @strCustomerNameFrom    NVARCHAR(100)
	  , @strCustomerNameTo      NVARCHAR(100)
	  , @conditionCustomer      NVARCHAR(20)
	  , @strLocationNameFrom    NVARCHAR(100)
	  , @strLocationNameTo      NVARCHAR(100)
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
	  , @strTaxReportType       NVARCHAR(100)
	  , @ysnTaxExemptOnly       BIT
	  , @xmlDocumentId          INT
	  , @fieldname              NVARCHAR(50)
      , @UserName               NVARCHAR(150)


SET @AccountStatusFiltered = CAST(0 AS BIT)
SELECT @UserName = [strName] FROM tblEMEntity WHERE[intEntityId] = @EntityUserId

		
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
 WHERE [fieldname] = 'strTaxClassType'

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

SELECT @strLocationNameFrom = REPLACE(ISNULL([from], ''), '''''', '''')
     , @strLocationNameTo   = REPLACE(ISNULL([to], ''), '''''', '''')
     , @conditionLocation   = [condition]
  FROM @temp_xml_table
 WHERE [fieldname] = 'strLocationName'

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

SELECT @strTaxReportType = REPLACE(ISNULL([from], ''), '''''', '''')
  FROM @temp_xml_table
 WHERE [fieldname] = 'strTaxReportType'

SELECT @ysnTaxExemptOnly = [from] 
  FROM @temp_xml_table
 WHERE [fieldname] = 'ysnTaxExemptOnly'

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

IF(OBJECT_ID('tempdb..#STATUSCODES') IS NOT NULL)
BEGIN
    DROP TABLE #STATUSCODES
END

CREATE TABLE #STATUSCODES ([intAccountStatusId] INT PRIMARY KEY, [strAccountStatusCode] CHAR(1) COLLATE Latin1_General_CI_AS)

IF (@conditionAccountStatus IS NOT NULL AND UPPER(@conditionAccountStatus) = 'BETWEEN' AND ISNULL(@strAccountStatusFrom, '') <> '')
    BEGIN
        SET @AccountStatusFiltered = CAST(1 AS BIT)
        INSERT INTO #STATUSCODES([intAccountStatusId], [strAccountStatusCode])
        SELECT [intAccountStatusId], [strAccountStatusCode]
          FROM dbo.tblARAccountStatus WITH (NOLOCK)
         WHERE [strAccountStatusCode] BETWEEN @strAccountStatusFrom AND @strAccountStatusTo
    END
ELSE IF (@conditionAccountStatus IS NOT NULL AND ISNULL(@strAccountStatusFrom, '') <> '')
    BEGIN
        SET @AccountStatusFiltered = CAST(1 AS BIT)
        INSERT INTO #STATUSCODES([intAccountStatusId], [strAccountStatusCode])
        SELECT [intAccountStatusId], [strAccountStatusCode]
          FROM dbo.tblARAccountStatus WITH (NOLOCK)
         WHERE [strAccountStatusCode] = @strAccountStatusFrom
    END
ELSE
    BEGIN
        SET @AccountStatusFiltered = CAST(0 AS BIT)
        INSERT INTO #STATUSCODES([intAccountStatusId], [strAccountStatusCode])
        SELECT [intAccountStatusId], [strAccountStatusCode]
          FROM dbo.tblARAccountStatus WITH (NOLOCK)
    END

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

CREATE TABLE #CUSTOMERS(
    [intEntityCustomerId]   INT PRIMARY KEY,
    [strCustomerNumber]     NVARCHAR(15)  COLLATE Latin1_General_CI_AS,
    [strCustomerName]       NVARCHAR(150) COLLATE Latin1_General_CI_AS,
    [strAccountStatusCode]  CHAR(1) COLLATE Latin1_General_CI_AS) 

IF (@conditionCustomer IS NOT NULL AND UPPER(@conditionCustomer) = 'BETWEEN' AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
        INSERT INTO #CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK) 
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                           WHERE strName BETWEEN @strCustomerNameFrom AND @strCustomerNameTo
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN #STATUSCODES SC
                               ON C.[intAccountStatusId] = SC.[intAccountStatusId]
         WHERE (@AccountStatusFiltered = CAST(1 AS BIT) AND SC.[intAccountStatusId] IS NOT NULL)
            OR @AccountStatusFiltered = CAST(0 AS BIT)
	END
ELSE IF (@conditionCustomer IS NOT NULL AND ISNULL(@strCustomerNameFrom, '') <> '')
	BEGIN
        INSERT INTO #CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK) 
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                           WHERE strName = @strCustomerNameFrom
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN #STATUSCODES SC
                               ON C.[intAccountStatusId] = SC.[intAccountStatusId]
         WHERE (@AccountStatusFiltered = CAST(1 AS BIT) AND SC.[intAccountStatusId] IS NOT NULL)
            OR @AccountStatusFiltered = CAST(0 AS BIT)
	END
ELSE
	BEGIN
        INSERT INTO #CUSTOMERS([intEntityCustomerId], [strCustomerNumber], [strCustomerName], [strAccountStatusCode])
        SELECT C.intEntityId, C.strCustomerNumber, E.strName, SC.[strAccountStatusCode]
          FROM tblARCustomer C WITH (NOLOCK)
               INNER JOIN (
                          SELECT intEntityId, strName
                            FROM dbo.tblEMEntity WITH (NOLOCK)
                          ) E ON C.intEntityId = E.intEntityId
               LEFT OUTER JOIN #STATUSCODES SC
                               ON C.[intAccountStatusId] = SC.[intAccountStatusId]

	END

IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
BEGIN
    DROP TABLE #COMPANYLOCATIONS
END

CREATE TABLE #COMPANYLOCATIONS ([intCompanyLocationId] INT PRIMARY KEY, [strCompanyNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS)

IF (@conditionLocation IS NOT NULL AND UPPER(@conditionLocation) = 'BETWEEN' AND ISNULL(@strLocationNameFrom, '') <> '')
    BEGIN
        INSERT INTO #COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
         WHERE strLocationName BETWEEN @strLocationNameFrom AND @strLocationNameTo
    END
ELSE IF (@conditionLocation IS NOT NULL AND ISNULL(@strLocationNameFrom, '') <> '')
    BEGIN
        INSERT INTO #COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE strLocationName = @strLocationNameFrom
    END
ELSE
    BEGIN
        INSERT INTO #COMPANYLOCATIONS([intCompanyLocationId], [strCompanyNumber])
        SELECT intCompanyLocationId, strLocationNumber
          FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
    END

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICES
END

CREATE TABLE #INVOICES
    ([intInvoiceId]         INT PRIMARY KEY,
    [strInvoiceNumber]      NVARCHAR(25)  COLLATE Latin1_General_CI_AS,
	[strType]               NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    [strSalespersonName]    NVARCHAR(150) COLLATE Latin1_General_CI_AS)

IF (@conditionInvoice IS NOT NULL AND UPPER(@conditionInvoice) = 'BETWEEN' AND ISNULL(@strInvoiceNumberFrom, '') <> '')
    BEGIN
        INSERT INTO #INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName
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
    END
ELSE IF (@conditionInvoice IS NOT NULL AND ISNULL(@strInvoiceNumberFrom, '') <> '')
    BEGIN
        INSERT INTO #INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName
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
    END
ELSE
    BEGIN
        INSERT INTO #INVOICES([intInvoiceId], [strInvoiceNumber], [strType], [strSalespersonName])
        SELECT I.intInvoiceId, I.strInvoiceNumber, I.strType, S.strName
          FROM dbo.tblARInvoice I WITH (NOLOCK)
               LEFT OUTER JOIN (
                               SELECT SP.intEntityId, E.strName
                                 FROM tblARSalesperson SP WITH (NOLOCK)
                                      INNER JOIN tblEMEntity E
                                                 ON SP.intEntityId = E.intEntityId
                               ) S ON I.intEntitySalespersonId = S.intEntityId
         WHERE I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
           AND (@strSalespersonName IS NULL OR S.strName LIKE '%' + @strSalespersonName + '%')
    END

IF(OBJECT_ID('tempdb..#TAXGROUPS') IS NOT NULL)
BEGIN
    DROP TABLE #TAXGROUPS
END

CREATE TABLE #TAXGROUPS ([intTaxGroupId] INT PRIMARY KEY, [strTaxGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS)

INSERT INTO #TAXGROUPS([intTaxGroupId], [strTaxGroup])
SELECT [intTaxGroupId], [strTaxGroup]
  FROM dbo.tblSMTaxGroup WITH (NOLOCK)
 WHERE (@strTaxGroup IS NULL OR [strTaxGroup] LIKE '%' + @strTaxGroup + '%')

IF(OBJECT_ID('tempdb..#ITEMS') IS NOT NULL)
BEGIN
    DROP TABLE #ITEMS
END

CREATE TABLE #ITEMS ([intItemId] INT PRIMARY KEY, [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS, [intCategoryId] INT)

INSERT INTO #ITEMS([intItemId], [strItemNo], [intCategoryId])
SELECT [intItemId], [strItemNo], [intCategoryId]
  FROM dbo.tblICItem WITH (NOLOCK)
 WHERE (@strItemNo IS NULL OR [strItemNo] LIKE '%' + @strItemNo + '%')

IF(OBJECT_ID('tempdb..#CATEGORIES') IS NOT NULL)
BEGIN
    DROP TABLE #CATEGORIES
END

CREATE TABLE #CATEGORIES ([intCategoryId] INT PRIMARY KEY, [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS)

IF (@conditionCategory IS NOT NULL AND UPPER(@conditionCategory) = 'BETWEEN' AND ISNULL(@strCategoryFrom, '') <> '')
    BEGIN
        INSERT INTO #CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
         WHERE [strCategoryCode] BETWEEN @strCategoryFrom AND @strCategoryTo
    END
ELSE IF (@conditionCategory IS NOT NULL AND ISNULL(@strCategoryFrom, '') <> '')
    BEGIN
        INSERT INTO #CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
         WHERE [strCategoryCode] = @strCategoryFrom
    END
ELSE
    BEGIN
        INSERT INTO #CATEGORIES([intCategoryId], [strCategoryCode])
        SELECT [intCategoryId], [strCategoryCode]
          FROM dbo.tblICCategory WITH (NOLOCK)
    END


DELETE FROM tblAROutboundTaxStagingTable
INSERT INTO tblAROutboundTaxStagingTable (
     [strInvoiceNumber]
    ,[strType]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[strAccountStatusCode]
    ,[strCompanyNumber]
    ,[strSalespersonName]
    ,[dtmDate]
    ,[intUserId]
    ,[strUserName]
    ,[strItemNo]
    ,[strItemDescription]
    ,[strCategoryCode]
    ,[dblQtyShipped]
    ,[dblPrice]
    ,[dblTotalTax]
    ,[dblTotal]
    ,[strTaxGroup]
    ,[strTaxCode]
    ,[strState]
    ,[strTaxClass]
    ,[dblCheckoffTax]
    ,[dblCitySalesTax]
    ,[dblCityExciseTax]
    ,[dblCountySalesTax]
    ,[dblCountyExciseTax]
    ,[dblFederalExciseTax]
    ,[dblFederalLustTax]
    ,[dblFederalOilSpillTax]
    ,[dblFederalOtherTax]
    ,[dblLocalOtherTax]
    ,[dblPrepaidSalesTax]
    ,[dblStateExciseTax]
    ,[dblStateOtherTax]
    ,[dblStateSalesTax]
    ,[dblTonnageTax]
    ,[dblSSTOnCheckoffTax]
    ,[dblSSTOnCitySalesTax]
    ,[dblSSTOnCityExciseTax]
    ,[dblSSTOnCountySalesTax]
    ,[dblSSTOnCountyExciseTax]
    ,[dblSSTOnFederalExciseTax]
    ,[dblSSTOnFederalLustTax]
    ,[dblSSTOnFederalOilSpillTax]
    ,[dblSSTOnFederalOtherTax]
    ,[dblSSTOnLocalOtherTax]
    ,[dblSSTOnPrepaidSalesTax]
    ,[dblSSTOnStateExciseTax]
    ,[dblSSTOnStateOtherTax]
    ,[dblSSTOnTonnageTax]
)
SELECT
       [strInvoiceNumber]             = I.[strInvoiceNumber]
     , [strType]                      = I.[strType]
     , [strCustomerNumber]            = C.[strCustomerNumber]
     , [strCustomerName]              = C.[strCustomerName]
     , [strAccountStatusCode]         = C.[strAccountStatusCode]
     , [strCompanyNumber]             = CL.[strCompanyNumber]
     , [strSalespersonName]           = I.[strSalespersonName]
     , [dtmDate]                      = OT.[dtmDate]
     , [intUserId]                    = @EntityUserId
     , [strUserName]                  = @UserName
     , [strItemNo]                    = ICI.[strItemNo]
     , [strItemDescription]           = OT.[strItemDescription]
     , [strCategoryCode]              = ICC.[strCategoryCode]
     , [dblQtyShipped]                = OT.[dblQtyShipped]
     , [dblPrice]                     = OT.[dblPrice]
     , [dblTotalTax]                  = OT.[dblTotalTax]
     , [dblTotal]                     = OT.[dblTotal]
     , [strTaxGroup]                  = TG.[strTaxGroup]
     , [strTaxCode]                   = '' --OT.[strTaxCode]
     , [strState]                     = '' --OT.[strState]
     , [strTaxClass]                  = '' --OT.[strTaxClass]
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
  FROM --dbo.vyuAROutboundTaxReport OT WITH (NOLOCK)
       (
       SELECT
              TD.intInvoiceId
            , TD.strInvoiceNumber
            , TD.intEntityCustomerId
            , TD.intCompanyLocationId
            , TD.intEntitySalespersonId
            , TD.dtmDate
            , TD.intInvoiceDetailId
            , TD.intItemId
            , TD.strItemDescription
            , TD.dblQtyShipped
            , TD.dblPrice
            , TD.dblTotalTax
            , TD.dblTotal
            , ISNULL(TD.intTaxGroupId, RT.intTaxGroupId) intTaxGroupId
            , RT.intTaxReportTypeId
            , RT.strType
            , RT.dblCheckoffTax
            , RT.dblCitySalesTax
            , RT.dblCityExciseTax
            , RT.dblCountySalesTax
            , RT.dblCountyExciseTax
            , RT.dblFederalExciseTax
            , RT.dblFederalLustTax
            , RT.dblFederalOilSpillTax
            , RT.dblFederalOtherTax
            , RT.dblLocalOtherTax
            , RT.dblPrepaidSalesTax
            , RT.dblStateExciseTax
            , RT.dblStateOtherTax
            , RT.dblStateSalesTax
            , RT.dblTonnageTax
            , RT.dblSSTOnCheckoffTax
            , RT.dblSSTOnCitySalesTax
            , RT.dblSSTOnCityExciseTax
            , RT.dblSSTOnCountySalesTax
            , RT.dblSSTOnCountyExciseTax
            , RT.dblSSTOnFederalExciseTax
            , RT.dblSSTOnFederalLustTax
            , RT.dblSSTOnFederalOilSpillTax
            , RT.dblSSTOnFederalOtherTax
            , RT.dblSSTOnLocalOtherTax
            , RT.dblSSTOnPrepaidSalesTax
            , RT.dblSSTOnStateExciseTax
            , RT.dblSSTOnStateOtherTax
            , RT.dblSSTOnTonnageTax
         FROM (
              SELECT
                     ARI.intInvoiceId
                   , ARI.strInvoiceNumber
                   , ARI.intEntityCustomerId
                   , ARI.intCompanyLocationId
                   , ARI.intEntitySalespersonId
                   , ARI.dtmDate
                   , ARID.intInvoiceDetailId
                   , ARID.intItemId
                   , ARID.strItemDescription
                   , ARID.dblQtyShipped
                   , ARID.dblPrice
                   , ARID.dblTotalTax
                   , ARID.dblTotal
                   , ARID.intTaxGroupId
                FROM tblARInvoiceDetail ARID WITH (NOLOCK)
                     INNER JOIN tblARInvoice ARI WITH (NOLOCK)
                                ON ARID.intInvoiceId = ARI.intInvoiceId
						       AND ARI.ysnPosted = CAST(1 AS BIT)       
               ) TD
                 INNER JOIN (
                            SELECT
                                   ARIDT.intInvoiceDetailId
                                 , ARIDT.intTaxGroupId
                                 , SMTRT.intTaxReportTypeId
                                 , SMTRT.strType
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCheckoffTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCitySalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCityExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCountySalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCountyExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalLustTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalOilSpillTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblLocalOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblPrepaidSalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 14 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateSalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblTonnageTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCheckoffTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCitySalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCityExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCountySalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCountyExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalLustTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalOilSpillTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnLocalOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnPrepaidSalesTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnStateExciseTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnStateOtherTax
                                 , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnTonnageTax
                              FROM tblARInvoiceDetailTax ARIDT WITH (NOLOCK)
                                   INNER JOIN tblSMTaxCode SMTCode WITH (NOLOCK)
                                              ON ARIDT.intTaxCodeId = SMTCode.intTaxCodeId
                                   INNER JOIN tblSMTaxClass SMTC WITH (NOLOCK)
                                              ON ARIDT.intTaxClassId = SMTC.intTaxClassId
                                   INNER JOIN tblSMTaxReportType SMTRT WITH (NOLOCK)
                                              ON SMTC.intTaxReportTypeId = SMTRT.intTaxReportTypeId
                                   LEFT OUTER JOIN tblSMTaxGroup SMTG
                                                   ON ARIDT.intTaxGroupId = SMTG.intTaxGroupId
                             WHERE (@strTaxClass IS NULL OR SMTC.strTaxClass LIKE '%'+ @strTaxClass +'%')
                               AND (@strTaxCode IS NULL OR SMTCode.strTaxCode LIKE '%'+ @strTaxCode +'%')
                               AND (@strState IS NULL OR SMTCode.strState LIKE '%'+ @strState +'%')
                               --AND ARIDT.ysnTaxExempt = 1
                             GROUP BY
                                   ARIDT.intInvoiceDetailId
                                 , ARIDT.intTaxGroupId
                                 , SMTRT.intTaxReportTypeId
                                 , SMTRT.strType
                            ) RT
	                        ON TD.intInvoiceDetailId = RT.intInvoiceDetailId
       ) OT
         INNER JOIN #CUSTOMERS C 
                    ON OT.intEntityCustomerId = C.intEntityCustomerId
         INNER JOIN #COMPANYLOCATIONS CL
                    ON OT.intCompanyLocationId = CL.intCompanyLocationId
         INNER JOIN #INVOICES I
                    ON OT.intInvoiceId = I.intInvoiceId
         INNER JOIN #TAXGROUPS TG
                    ON OT.intTaxGroupId = TG.intTaxGroupId
         INNER JOIN #ITEMS ICI
                    ON OT.[intItemId] = ICI.[intItemId]
         INNER JOIN #CATEGORIES ICC
                    ON ICI.[intCategoryId] = ICC.[intCategoryId]




SELECT strTaxReportType = ISNULL(@strTaxReportType, 'Tax Detail')
