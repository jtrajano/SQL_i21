﻿CREATE PROCEDURE [dbo].[uspAROutboundTaxReport]
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

IF OBJECT_ID('tempdb..#STATUSCODES') IS NOT NULL DROP TABLE #STATUSCODES
IF OBJECT_ID('tempdb..#INVOICES') IS NOT NULL DROP TABLE #INVOICES
IF OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL DROP TABLE #CUSTOMERS
IF OBJECT_ID('tempdb..#ITEMS') IS NOT NULL DROP TABLE #ITEMS
IF OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL DROP TABLE #COMPANYLOCATIONS
IF OBJECT_ID('tempdb..#TYPES') IS NOT NULL DROP TABLE #TYPES

-- Declare the variables.
DECLARE @strTaxCode             NVARCHAR(100)
	  , @strState               NVARCHAR(100)
	  , @strTaxClass            NVARCHAR(100)
	  , @strTaxClassType        NVARCHAR(100)
	  , @strTaxGroup            NVARCHAR(100)
	  , @strSubTotalBy          NVARCHAR(100)	= 'Tax Group'
	  , @strIncludeExemptOnly   NVARCHAR(100)	= 'No'
	  , @ysnInvoiceDetail       BIT
	  , @xmlDocumentId          INT	  
      , @UserName               NVARCHAR(150)
	  , @strCompanyName         NVARCHAR(100)
	  , @strCompanyAddress      NVARCHAR(500)
	  , @strAccountStatusCode	NVARCHAR(500)
	  , @strCustomerName		NVARCHAR(100)
	  , @strLocationNumber		NVARCHAR(100)
	  , @strType				NVARCHAR(100)
	  , @strItemNo				NVARCHAR(100)
	  , @strCategoryCode		NVARCHAR(100)
	  , @strSalespersonName		NVARCHAR(100)
	  , @strInvoiceNumber		NVARCHAR(100)		
	  , @ZeroBit				BIT				= CAST(0 AS BIT)
	  , @OneBit					BIT				= CAST(1 AS BIT)
	  , @ZeroDecimal			DECIMAL(18, 6)	= CAST(0 AS DECIMAL(18,6))
	  , @dtmDateFrom			DATETIME
	  , @dtmDateTo				DATETIME
	  , @strCategoryCodeCondition	NVARCHAR(100)
      , @fieldname				NVARCHAR(50)
	  , @condition				NVARCHAR(20)
	  , @id						INT 
	  , @from					NVARCHAR(100)
	  , @to						NVARCHAR(100)

SELECT TOP 1 @strCompanyName    = strCompanyName
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
SELECT TOP 1 @strSubTotalBy = REPLACE(ISNULL([from], 'Tax Group'), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strSubTotalBy'

SELECT TOP 1 @strIncludeExemptOnly = REPLACE(ISNULL([from], 'No'), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strIncludeExemptOnly'

SELECT TOP 1 @ysnInvoiceDetail = [from] 
FROM @temp_xml_table
WHERE [fieldname] = 'ysnInvoiceDetail'

SELECT TOP 1 @strAccountStatusCode = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strAccountStatusCode'

SELECT TOP 1 @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerName'

SELECT TOP 1 @strLocationNumber = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strLocationNumber'

SELECT TOP 1 @strType = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strType'

SELECT TOP 1 @strItemNo = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strItemNo'

SELECT TOP 1 @strSalespersonName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strSalespersonName'

SELECT TOP 1 @strInvoiceNumber = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strInvoiceNumber'

SELECT @dtmDateFrom		= CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	 , @dtmDateTo		= CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)     
FROM @temp_xml_table 
WHERE [fieldname] = 'dtmDate'

IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)

--TEMP TABLES
IF(OBJECT_ID('tempdb..#TAXCODES') IS NOT NULL)
BEGIN
    DROP TABLE #TAXCODES
END
CREATE TABLE #TAXCODES (
      [intTaxCodeId]	INT             NOT NULL
    , [strTaxCode]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

IF(OBJECT_ID('tempdb..#TAXCLASS') IS NOT NULL)
BEGIN
    DROP TABLE #TAXCLASS
END
CREATE TABLE #TAXCLASS (
      [intTaxClassId]	INT             NOT NULL
    , [strTaxClass]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

IF(OBJECT_ID('tempdb..#TAXGROUP') IS NOT NULL)
BEGIN
    DROP TABLE #TAXGROUP
END
CREATE TABLE #TAXGROUP (
      [intTaxGroupId]	INT             NOT NULL
    , [strTaxGroup]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

IF(OBJECT_ID('tempdb..#TAXREPORTTYPE') IS NOT NULL)
BEGIN
    DROP TABLE #TAXREPORTTYPE
END
CREATE TABLE #TAXREPORTTYPE (
      [intTaxReportTypeId]	INT             NOT NULL
    , [strType]		        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

IF(OBJECT_ID('tempdb..#TAXSTATE') IS NOT NULL)
BEGIN
    DROP TABLE #TAXSTATE
END
CREATE TABLE #TAXSTATE (
      [strState]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

IF(OBJECT_ID('tempdb..#CATEGORIES') IS NOT NULL)
BEGIN
    DROP TABLE #CATEGORIES
END
CREATE TABLE #CATEGORIES (
       [intCategoryId]		INT
	 , [strCategoryCode]  NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL 
	 , [strDescription]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL 
)

WHILE EXISTS (SELECT TOP 1 NULL FROM @temp_xml_table WHERE [fieldname] IN ('strTaxCode', 'strState', 'strTaxReportType', 'strTaxClass', 'strTaxGroup', 'strCategoryCode'))
    BEGIN
        SELECT TOP 1 @condition = [condition]
				   , @from		= REPLACE(ISNULL([from], ''), '''''', '''')
				   , @to		= REPLACE(ISNULL([to], ''), '''''', '''')
				   , @fieldname = [fieldname]
				   , @id		= [id]
		FROM @temp_xml_table 
		WHERE [fieldname] IN ('strTaxCode', 'strState', 'strTaxReportType', 'strTaxClass', 'strTaxGroup', 'strCategoryCode')

        IF UPPER(@condition) = UPPER('Equal To')
			BEGIN
                IF @fieldname = 'strTaxCode'
					BEGIN
                        INSERT INTO #TAXCODES
						SELECT intTaxCodeId
                             , strTaxCode
                        FROM tblSMTaxCode TC
                        WHERE TC.strTaxCode = @from
					END
                ELSE IF @fieldname = 'strState'
                    BEGIN
                        INSERT INTO #TAXSTATE
						SELECT DISTINCT strState
                        FROM tblSMTaxCode TC
                        WHERE TC.strState = @from
					END
                ELSE IF @fieldname = 'strTaxReportType'
                    BEGIN
                        INSERT INTO #TAXREPORTTYPE
						SELECT intTaxReportTypeId
                             , strType
                        FROM tblSMTaxReportType TRT
                        WHERE TRT.strType = @from
					END
                ELSE IF @fieldname = 'strTaxClass'
                    BEGIN
                        INSERT INTO #TAXCLASS
                        SELECT intTaxClassId
                             , strTaxClass
                        FROM tblSMTaxClass TC
                        WHERE TC.strTaxClass = @from
                    END
                ELSE IF @fieldname = 'strTaxGroup'
                    BEGIN
                        INSERT INTO #TAXGROUP
                        SELECT intTaxGroupId
                             , strTaxGroup
                        FROM tblSMTaxGroup TG
                        WHERE TG.strTaxGroup = @from
                    END
                ELSE IF @fieldname = 'strCategoryCode'
                    BEGIN
                        INSERT INTO #CATEGORIES
						SELECT	intCategoryId
							, strCategoryCode
							, strDescription
						FROM tblICCategory IC
					   WHERE IC.strCategoryCode = @from
                    END
            END
        ELSE IF UPPER(@condition) = UPPER('Not Equal To')
			BEGIN
                IF @fieldname = 'strTaxCode'
					BEGIN
                        INSERT INTO #TAXCODES
						SELECT intTaxCodeId
                             , strTaxCode
                        FROM tblSMTaxCode TC
                        WHERE TC.strTaxCode <> @from
					END
                ELSE IF @fieldname = 'strState'
                    BEGIN
                        INSERT INTO #TAXSTATE
						SELECT DISTINCT strState
                        FROM tblSMTaxCode TC
                        WHERE TC.strState <> @from
					END
                ELSE IF @fieldname = 'strTaxReportType'
                    BEGIN
                        INSERT INTO #TAXREPORTTYPE
						SELECT intTaxReportTypeId
                             , strType
                        FROM tblSMTaxReportType TRT
                        WHERE TRT.strType <> @from
					END
                ELSE IF @fieldname = 'strTaxClass'
                    BEGIN
                        INSERT INTO #TAXCLASS
                        SELECT intTaxClassId
                             , strTaxClass
                        FROM tblSMTaxClass TC
                        WHERE TC.strTaxClass <> @from
                    END
                ELSE IF @fieldname = 'strTaxGroup'
                    BEGIN
                        INSERT INTO #TAXGROUP
                        SELECT intTaxGroupId
                             , strTaxGroup
                        FROM tblSMTaxGroup TG
                        WHERE TG.strTaxGroup <> @from
                    END
                ELSE IF @fieldname = 'strCategoryCode'
                    BEGIN
                        INSERT INTO #CATEGORIES
						SELECT	intCategoryId
							, strCategoryCode
							, strDescription
						FROM tblICCategory IC
					   WHERE IC.strCategoryCode <> @from
                    END
            END

        DELETE FROM @temp_xml_table WHERE [id] = @id
		SET @condition = NULL
		SET @from = NULL
		SET @to = NULL
		SET @fieldname = NULL
		SET @id =  NULL
    END

-- IF TEMP TABLE DOES NOT HAVE VALUE
IF NOT EXISTS (SELECT TOP 1 NULL FROM #CATEGORIES)
BEGIN 
INSERT INTO #CATEGORIES
SELECT DISTINCT intCategoryId, strCategoryCode, strDescription
FROM tblICCategory TC
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM #TAXSTATE)
BEGIN
INSERT INTO #TAXSTATE
SELECT DISTINCT strState
FROM tblSMTaxCode TC
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM #TAXREPORTTYPE)
BEGIN
INSERT INTO #TAXREPORTTYPE
SELECT intTaxReportTypeId
     , strType
FROM tblSMTaxReportType TRT
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM #TAXGROUP)
BEGIN
INSERT INTO #TAXGROUP
SELECT intTaxGroupId
     , strTaxGroup
FROM tblSMTaxGroup TG
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM #TAXCLASS)
BEGIN
INSERT INTO #TAXCLASS
SELECT intTaxClassId
     , strTaxClass
FROM tblSMTaxClass TC
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM #TAXCODES)
BEGIN
INSERT INTO #TAXCODES
SELECT intTaxCodeId
     , strTaxCode
FROM tblSMTaxCode TC
END

--#CUSTOMERS
SELECT intEntityCustomerId  	= C.intEntityId 
	 , strCustomerNumber		= C.strCustomerNumber
	 , strCustomerName      	= EC.strName
INTO #CUSTOMERS
FROM dbo.tblARCustomer C WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
			, strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
	WHERE (@strCustomerName IS NULL OR strName = @strCustomerName)
) EC ON C.intEntityId = EC.intEntityId

--#ACCOUNTSTATUS
IF @strAccountStatusCode IS NOT NULL
    BEGIN
        DELETE FROM #CUSTOMERS
        WHERE intEntityCustomerId NOT IN (
            SELECT DISTINCT intEntityCustomerId
            FROM dbo.tblARCustomerAccountStatus CAS WITH (NOLOCK)
            INNER JOIN tblARAccountStatus AAS WITH (NOLOCK) ON CAS.intAccountStatusId = AAS.intAccountStatusId
            WHERE AAS.strAccountStatusCode = @strAccountStatusCode
        )
    END

--#LOCATIONS
SELECT intCompanyLocationId
	 , strLocationName
	 , strLocationNumber
INTO #LOCATIONS
FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
WHERE (@strLocationNumber IS NULL OR strLocationNumber = @strLocationNumber)

--#ITEMS
SELECT I.intItemId
	 , I.strItemNo
	 , C.*
INTO #ITEMS
FROM dbo.tblICItem I WITH (NOLOCK)
INNER JOIN #CATEGORIES C ON I.intCategoryId = C.intCategoryId
WHERE (@strItemNo IS NULL OR strItemNo = @strItemNo)

--#TYPES
SELECT strInvoiceSource
INTO #TYPES
FROM dbo.fnARGetInvoiceSourceList()
WHERE (@strType IS NULL OR strInvoiceSource = @strType)

--#INVOICES
SELECT intInvoiceId				= I.intInvoiceId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strType					= I.strType
	 , dtmDate					= I.dtmDate
	 , intEntityCustomerId		= C.intEntityCustomerId
	 , strCustomerNumber		= C.strCustomerNumber
	 , strCustomerName			= C.strCustomerName
	 , intCompanyLocationId		= L.intCompanyLocationId
	 , strLocationNumber		= L.strLocationNumber
	 , intEntitySalespersonId	= SP.intEntityId
	 , strSalespersonName		= SP.strName
INTO #INVOICES
FROM dbo.tblARInvoice I
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #LOCATIONS L ON I.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN #TYPES T ON I.strType = T.strInvoiceSource
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity
	WHERE (@strSalespersonName IS NULL OR strName = @strSalespersonName)
) SP ON I.intEntitySalespersonId = SP.intEntityId
WHERE CAST(I.dtmDate AS DATE) BETWEEN @dtmDateFrom AND @dtmDateTo
  AND (@strInvoiceNumber IS NULL OR strInvoiceNumber = @strInvoiceNumber)

IF @strSubTotalBy = 'Tax Group'
BEGIN
    SELECT [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = I.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = I.[strCustomerNumber]
         , [strCustomerName]              = I.[strCustomerName]
         , [strAccountStatusCode]         = ''--C.[strAccountStatusCode]
         , [strCompanyNumber]             = I.[strLocationNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = NULL
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ITEM.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ITEM.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ITEM.[strItemNo] ELSE LTRIM(RTRIM(ITEM.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ITEM.[strCategoryCode]
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
           SELECT OTR.intTaxGroupId AS intTaxGroupId
			    , OTR.strTaxGroup AS strTaxGroup
				, intInvoiceDetailId
				, intInvoiceId
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
            FROM vyuAROutboundTaxReport OTR WITH (NOLOCK) 
            INNER JOIN #TAXCODES TC ON OTR.strTaxCode = TC.strTaxCode
            INNER JOIN #TAXSTATE TS ON OTR.strState = TS.strState
            INNER JOIN #TAXGROUP TG ON OTR.strTaxGroup = TG.strTaxGroup
            INNER JOIN #TAXCLASS TCC ON OTR.strTaxClass = TCC.strTaxClass
            INNER JOIN #TAXREPORTTYPE TRT ON OTR.strType = TRT.strType
            WHERE (
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'                        
                        AND dblTotalTax <> @ZeroDecimal
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'                        
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
            GROUP BY OTR.intTaxGroupId, OTR.strTaxGroup, intInvoiceDetailId, intInvoiceId
           ) OT
        INNER JOIN #INVOICES I ON OT.intInvoiceId = I.intInvoiceId
        INNER JOIN #ITEMS ITEM ON OT.[intItemId] = ITEM.[intItemId]
		ORDER BY OT.strTaxGroup, OT.intInvoiceId, OT.intInvoiceDetailId

    RETURN 1;
END

IF @strSubTotalBy = 'Customer'
BEGIN
    SELECT [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = I.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = I.[strCustomerNumber]
         , [strCustomerName]              = I.[strCustomerName]
         , [strAccountStatusCode]         = ''--I.[strAccountStatusCode]
         , [strCompanyNumber]             = I.[strLocationNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = NULL
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ITEM.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ITEM.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ITEM.[strItemNo] ELSE LTRIM(RTRIM(ITEM.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ITEM.[strCategoryCode]
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
         , [strGrouping]                  = I.[strCustomerName]
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
           SELECT intEntityCustomerId
			    , intInvoiceDetailId
				, intInvoiceId
                , MIN(intCompanyLocationId) AS intCompanyLocationId
                , MIN(intItemId) AS intItemId
                , MIN(strItemDescription) AS strItemDescription
                , MIN(dblQtyShipped) AS dblQtyShipped
                , MIN(dblPrice) AS dblPrice
                , MIN(dblTotalTax) AS dblTotalTax
                , MIN(dblTotal) AS dblTotal
                , MIN(TG.intTaxGroupId) AS intTaxGroupId
                , MIN(TG.strTaxGroup) AS strTaxGroup
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
            FROM vyuAROutboundTaxReport OTR WITH (NOLOCK) 
            INNER JOIN #TAXCODES TC ON OTR.strTaxCode = TC.strTaxCode
            INNER JOIN #TAXSTATE TS ON OTR.strState = TS.strState
            INNER JOIN #TAXGROUP TG ON OTR.strTaxGroup = TG.strTaxGroup
            INNER JOIN #TAXCLASS TCC ON OTR.strTaxClass = TCC.strTaxClass
            INNER JOIN #TAXREPORTTYPE TRT ON OTR.strType = TRT.strType
            WHERE (
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'
                        AND dblTotalTax <> @ZeroDecimal
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
				GROUP BY intEntityCustomerId, intInvoiceDetailId, intInvoiceId
			) OT
            INNER JOIN #INVOICES I ON OT.intInvoiceId = I.intInvoiceId
            INNER JOIN #ITEMS ITEM ON OT.[intItemId] = ITEM.[intItemId]
		 ORDER BY I.strCustomerName, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END

IF @strSubTotalBy = 'Tax Code'
BEGIN
    SELECT [strInvoiceNumber]             = I.[strInvoiceNumber]
         , [intInvoiceId]                 = I.[intInvoiceId]
         , [intInvoiceDetailId]           = OT.[intInvoiceDetailId]
         , [intEntityCustomerId]          = I.[intEntityCustomerId]
         , [strType]                      = I.[strType]
         , [strCustomerNumber]            = I.[strCustomerNumber]
         , [strCustomerName]              = I.[strCustomerName]
         , [strAccountStatusCode]         = NULL--I.[strAccountStatusCode]
         , [strCompanyNumber]             = I.[strLocationNumber]
         , [strCompanyName]               = @strCompanyName
         , [strCompanyAddress]            = @strCompanyAddress
         , [strSalespersonName]           = I.[strSalespersonName]
         , [dtmDate]                      = I.[dtmDate]
         , [intUserId]                    = NULL
         , [strUserName]                  = @UserName
         , [strItemNo]                    = ITEM.[strItemNo]
         , [strItemDescription]           = (CASE WHEN UPPER(LTRIM(RTRIM(ITEM.[strItemNo]))) = UPPER(LTRIM(RTRIM(OT.[strItemDescription]))) THEN ITEM.[strItemNo] ELSE LTRIM(RTRIM(ITEM.[strItemNo])) + ' (' + LTRIM(RTRIM(OT.[strItemDescription])) + ')' END)
         , [strCategoryCode]              = ITEM.[strCategoryCode]
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
           SELECT OTR.intTaxCodeId AS intTaxCodeId
				, OTR.strTaxCode AS strTaxCode
				, intInvoiceDetailId
				, intInvoiceId
                , MIN(intEntityCustomerId) AS intEntityCustomerId
                , MIN(intCompanyLocationId) AS intCompanyLocationId
                , MIN(intItemId) AS intItemId
                , MIN(strItemDescription) AS strItemDescription
                , MIN(dblQtyShipped) AS dblQtyShipped
                , MIN(dblPrice) AS dblPrice
                , MIN(dblTotalTax) AS dblTotalTax
                , MIN(dblTotal) AS dblTotal
                , MIN(TG.intTaxGroupId) AS intTaxGroupId
                , MIN(TG.strTaxGroup) AS strTaxGroup
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
            FROM vyuAROutboundTaxReport OTR WITH (NOLOCK) 
            INNER JOIN #TAXCODES TC ON OTR.strTaxCode = TC.strTaxCode
            INNER JOIN #TAXSTATE TS ON OTR.strState = TS.strState
            INNER JOIN #TAXGROUP TG ON OTR.strTaxGroup = TG.strTaxGroup
            INNER JOIN #TAXCLASS TCC ON OTR.strTaxClass = TCC.strTaxClass
            INNER JOIN #TAXREPORTTYPE TRT ON OTR.strType = TRT.strType
            WHERE ( 
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'No'
                        AND dblTotalTax <> @ZeroDecimal
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Code'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Class'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  OR
                       (
			            ISNULL(@strIncludeExemptOnly, 'No') = 'By Tax Report Type'
                        AND ((ysnInvalidSetup = @ZeroBit AND ysnTaxExempt = @OneBit) OR ysnManualTaxExempt = @OneBit)
					   )
                  )
				GROUP BY OTR.intTaxCodeId, OTR.strTaxCode, intInvoiceDetailId, intInvoiceId
			) OT
            INNER JOIN #INVOICES I ON OT.intInvoiceId = I.intInvoiceId
            INNER JOIN #ITEMS ITEM ON OT.[intItemId] = ITEM.[intItemId]
		 ORDER BY OT.strTaxCode, OT.intInvoiceId, OT.intInvoiceDetailId
    RETURN 1;
END