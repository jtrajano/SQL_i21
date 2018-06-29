CREATE PROCEDURE [dbo].[uspAPRpt1099DIVTwoPart]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @vendorFromParam NVARCHAR(100) = NULL;
DECLARE @vendorToParam NVARCHAR(100) = NULL;
DECLARE @yearParam INT = YEAR(GETDATE());
DECLARE @correctedParam BIT = 0;
DECLARE @reprint BIT = 0;
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT *, NULL AS strCorrected 
			,NULL AS strYear 
			,NULL AS strEmployerAddress2
			,NULL AS strCompanyName2
			,NULL AS strEIN2
			,NULL AS strFederalTaxId2
			,NULL AS strAddress2
			,NULL AS strVendorCompanyName2
			,NULL AS strVendorId2
			,NULL AS strZip2
			,NULL AS strCity2
			,NULL AS strState2
			,NULL AS strZipState2
			,0 AS intYear2
			,0 AS dblOrdinaryDividends2
			,0 AS dblQualified2
			,0 AS dblCapitalGain2
			,0 AS dblUnrecapGain2
			,0 AS dblSection12022
			,0 AS dblCollectibles2
			,0 AS dblNonDividends2
			,0 AS dblFITW2
			,0 AS dblInvestment2
			,0 AS dblForeignTax2
			,0 AS dblForeignCountry2
			,0 AS dblCash2
			,0 AS dblNonCash2
			,0 AS dblExempt2
			,0 AS dblPrivate2
			,0 AS dblState2
			,0 AS intEntityVendorId2
			,0 AS dblTotalPayment2
			,NULL AS strCorrected2
			,0 AS dblTotalPayment2
	FROM vyuAP1099DIV WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(200)
	, [to] nvarchar(200)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@vendorFromParam = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'vendorFrom'

	SELECT 
		@vendorToParam = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'vendorTo'

	SELECT 
		@yearParam = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'year'

	SELECT 
		@reprint = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'reprint'

	SELECT 
		@correctedParam = CAST([from] AS BIT)
	FROM @temp_xml_table WHERE [fieldname] = 'corrected'
END;

--SET @vendorFromParam = @vendorFrom;
--SET @vendorToParam = @vendorTo;
--SET @yearParam = @year;
--SET @correctedParam = @corrected;

WITH DIV1099 (
	int1099DIVId
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,intYear
	,dblOrdinaryDividends
	,dblQualified
	,dblCapitalGain
	,dblUnrecapGain
	,dblSection1202
	,dblCollectibles
	,dblNonDividends
	,dblFITW
	,dblInvestment
	,dblForeignTax
	,dblForeignCountry
	,dblCash
	,dblNonCash
	,dblExempt
	,dblPrivate
	,dblState
	,intEntityVendorId
	,dblTotalPayment
	,strCorrected
	,strYear
)
AS 
(
	SELECT 
     int1099DIVId = ROW_NUMBER() OVER(ORDER BY (SELECT 1))
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,A.strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,A.intYear
	,dblOrdinaryDividends
	,dblQualified
	,dblCapitalGain
	,dblUnrecapGain
	,dblSection1202
	,dblCollectibles
	,dblNonDividends
	,dblFITW
	,dblInvestment
	,dblForeignTax
	,dblForeignCountry
	,dblCash
	,dblNonCash
	,dblExempt
	,dblPrivate
	,dblState
	,A.intEntityVendorId
	,dblTotalPayment
	,(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected
	,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM vyuAP1099DIV A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 5
		AND B.intEntityVendorId = A.intEntityVendorId
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
			CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
					ELSE 
						(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
							WHEN History.ysnPrinted IS NULL THEN 1
							WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
						ELSE 0 END)
			END)
)

SELECT
	 DIV1099Top.strEmployerAddress
	,DIV1099Top.strCompanyName
	,DIV1099Top.strEIN
	,DIV1099Top.strFederalTaxId
	,DIV1099Top.strAddress
	,DIV1099Top.strVendorCompanyName
	,DIV1099Top.strVendorId
	,DIV1099Top.strZip
	,DIV1099Top.strCity
	,DIV1099Top.strState
	,DIV1099Top.strZipState
	,DIV1099Top.intYear
	,DIV1099Top.dblOrdinaryDividends	
	,DIV1099Top.dblQualified			
	,DIV1099Top.dblCapitalGain			
	,DIV1099Top.dblUnrecapGain			
	,DIV1099Top.dblSection1202			
	,DIV1099Top.dblCollectibles			
	,DIV1099Top.dblNonDividends			
	,DIV1099Top.dblFITW					
	,DIV1099Top.dblInvestment			
	,DIV1099Top.dblForeignTax			
	,DIV1099Top.dblForeignCountry		
	,DIV1099Top.dblCash					
	,DIV1099Top.dblNonCash				
	,DIV1099Top.dblExempt				
	,DIV1099Top.dblPrivate				
	,DIV1099Top.dblState				
	,DIV1099Top.intEntityVendorId
	,DIV1099Top.dblTotalPayment
	,DIV1099Top.strCorrected
	,DIV1099Top.strYear
	,DIV1099Bottom.strEmployerAddress			AS strEmployerAddress2
	,DIV1099Bottom.strCompanyName				AS strCompanyName2
	,DIV1099Bottom.strEIN						AS strEIN2
	,DIV1099Bottom.strFederalTaxId				AS strFederalTaxId2
	,DIV1099Bottom.strAddress					AS strAddress2
	,DIV1099Bottom.strVendorCompanyName			AS strVendorCompanyName2
	,DIV1099Bottom.strVendorId					AS strVendorId2
	,DIV1099Bottom.strZip						AS strZip2
	,DIV1099Bottom.strCity						AS strCity2
	,DIV1099Bottom.strState						AS strState2
	,DIV1099Bottom.strZipState					AS strZipState2
	,DIV1099Bottom.intYear						AS intYear2
	,DIV1099Bottom.dblOrdinaryDividends			AS dblOrdinaryDividends2
	,DIV1099Bottom.dblQualified					AS dblQualified2
	,DIV1099Bottom.dblCapitalGain				AS dblCapitalGain2
	,DIV1099Bottom.dblUnrecapGain				AS dblUnrecapGain2
	,DIV1099Bottom.dblSection1202				AS dblSection12022
	,DIV1099Bottom.dblCollectibles				AS dblCollectibles2
	,DIV1099Bottom.dblNonDividends				AS dblNonDividends2
	,DIV1099Bottom.dblFITW						AS dblFITW2
	,DIV1099Bottom.dblInvestment				AS dblInvestment2
	,DIV1099Bottom.dblForeignTax				AS dblForeignTax2
	,DIV1099Bottom.dblForeignCountry			AS dblForeignCountry2
	,DIV1099Bottom.dblCash						AS dblCash2
	,DIV1099Bottom.dblNonCash					AS dblNonCash2
	,DIV1099Bottom.dblExempt					AS dblExempt2
	,DIV1099Bottom.dblPrivate					AS dblPrivate2
	,DIV1099Bottom.dblState						AS dblState2
	,DIV1099Bottom.intEntityVendorId			AS intEntityVendorId2
	,DIV1099Bottom.dblTotalPayment				AS dblTotalPayment2
	,DIV1099Bottom.strCorrected					AS strCorrected2
	,DIV1099Bottom.strYear						AS strYear2
FROM (
	SELECT
	*
	FROM DIV1099 A
	WHERE A.int1099DIVId % 2 = 1
) DIV1099Top
OUTER APPLY (
	SELECT
	*
	FROM DIV1099 A
	WHERE A.int1099DIVId % 2 = 0
	AND A.int1099DIVId = (DIV1099Top.int1099DIVId + 1)
) DIV1099Bottom