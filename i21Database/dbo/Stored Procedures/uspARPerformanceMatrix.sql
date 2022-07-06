CREATE PROCEDURE dbo.uspARPerformanceMatrix
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @dtmAsOfDate	DATETIME = NULL
	  , @xmlDocumentId	INT= NULL

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL
		
		SELECT dblDSO				= CAST(0 AS NUMERIC(18, 6))
			 , dblBPDSO				= CAST(0 AS NUMERIC(18, 6))
			 , dblADD				= CAST(0 AS NUMERIC(18, 6))
			 , dblCEI				= CAST(0 AS NUMERIC(18, 6))
			 , dblART				= CAST(0 AS NUMERIC(18, 6))
			 , strCompanyName		= '' COLLATE Latin1_General_CI_AS
			 , strCompanyAddress	= '' COLLATE Latin1_General_CI_AS
			 , dtmAsOfDate			= CAST(GETDATE() AS DATE)
	END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[condition]	NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[from]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[to]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
	,[begingroup]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
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

SELECT @dtmAsOfDate = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATE)
FROM @temp_xml_table 
WHERE UPPER(fieldname) = UPPER('dtmAsOfDate')

SET @dtmAsOfDate	= CAST(ISNULL(@dtmAsOfDate, GETDATE()) AS DATE)

SELECT dblDSO			= dbo.fnRoundBanker((ENDINGRECEIVABLES.dblTotalAR / (NULLIF(ANNUALSALES.dblAnnualSales, 0) / 365)), 2)
     , dblBPDSO			= dbo.fnRoundBanker(((ENDINGRECEIVABLES.dblCurrent * 365) / NULLIF(CREDITSALES.dblCreditSales, 0)), 2)
	 , dblADD			= dbo.fnRoundBanker((ENDINGRECEIVABLES.dblTotalAR / (NULLIF(ANNUALSALES.dblAnnualSales, 0) / 365)), 2) - dbo.fnRoundBanker(((ENDINGRECEIVABLES.dblCurrent * 365) / (NULLIF(CREDITSALES.dblCreditSales, 0) / 365)), 2)
	 , dblCEI			= dbo.fnRoundBanker(((BEGINNINGRECEIVABLES.dblTotalAR + MONTHLYCREDITSALES.dblCreditSales - ENDINGRECEIVABLES.dblTotalAR) / NULLIF((BEGINNINGRECEIVABLES.dblTotalAR + MONTHLYCREDITSALES.dblCreditSales - ENDINGRECEIVABLES.dblCurrent), 0)), 2)
	 , dblART			= dbo.fnRoundBanker(CREDITSALES.dblCreditSales / (NULLIF((LASTYEARRECEIVABLES.dblTotalAR + ENDINGRECEIVABLES.dblTotalAR), 0) / 2), 2)
	 , strCompanyName	= COMPANY.strCompanyName COLLATE Latin1_General_CI_AS
	 , strCompanyAddress	= COMPANY.strCompanyAddress COLLATE Latin1_General_CI_AS
	 , dtmAsOfDate		= @dtmAsOfDate
FROM (
	SELECT dblCreditSales = ISNULL(SUM(I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1 ELSE 1 END), 0)
	FROM tblARInvoice I
	WHERE I.ysnPosted = 1
	  AND I.ysnCancelled = 0
	  AND I.strTransactionType IN ('Invoice', 'Credit Memo')
	  AND CAST(I.dtmPostDate AS DATE) BETWEEN CAST(DATEADD(YY, - 1, @dtmAsOfDate) AS DATE) AND CAST(@dtmAsOfDate AS DATE)	  
	  AND ((I.strType = 'Service Charge' AND (CAST(@dtmAsOfDate AS DATE) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmForgiveDate))))) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
) CREDITSALES
inner join (
	SELECT dblCreditSales = ISNULL(SUM(I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1 ELSE 1 END), 0)
	FROM tblARInvoice I
	WHERE I.ysnPosted = 1
	  AND I.ysnCancelled = 0
	  AND CAST(I.dtmPostDate AS DATE) BETWEEN DATEADD(MM, DATEDIFF(MM, 0, @dtmAsOfDate), 0) AND DATEADD(DD, - 1, DATEADD(MM, DATEDIFF(MM, 0, @dtmAsOfDate) + 1, 0))
)  MONTHLYCREDITSALES on 1=1
inner join 
(
	SELECT dblAnnualSales = ISNULL(SUM(I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1 ELSE 1 END), 0) 
	FROM tblARInvoice I
	WHERE I.ysnPosted = 1
	  AND I.ysnCancelled = 0
	  AND CAST(I.dtmPostDate AS DATE) BETWEEN CAST(DATEADD(YY, - 1, @dtmAsOfDate) AS DATE) AND CAST(@dtmAsOfDate AS DATE)
) ANNUALSALES on 1=1
inner join (
	SELECT dblTotalAR = ISNULL(SUM(dblTotalAR), 0) 
	FROM dbo.fnARCustomerAgingReport(CAST(DATEADD(DAY, -(DAY(@dtmAsOfDate)), @dtmAsOfDate) AS DATE), 0)
) BEGINNINGRECEIVABLES on 1=1
inner join (
	SELECT dblTotalAR = ISNULL(SUM(dblTotalAR), 0) 
		 , dblCurrent = ISNULL(SUM(dbl0Days), 0) 
	FROM dbo.fnARCustomerAgingReport(CAST(@dtmAsOfDate AS DATE), 1)
) ENDINGRECEIVABLES on 1=1
inner join (
	SELECT dblTotalAR = ISNULL(SUM(dblTotalAR), 0) 
	FROM dbo.fnARCustomerAgingReport(CAST(DATEADD(YY, - 1, @dtmAsOfDate) AS DATE), 0)
) LASTYEARRECEIVABLES on 1=1
inner join (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY on 1=1
