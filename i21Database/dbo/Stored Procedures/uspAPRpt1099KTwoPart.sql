CREATE PROCEDURE [dbo].[uspAPRpt1099KTwoPart]
	@xmlParam NVARCHAR(MAX) = NULL
	--@vendorFrom NVARCHAR(100) = NULL,
	--@vendorTo NVARCHAR(100) = NULL,
	--@year INT,
	--@corrected BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sample XML string structure:
--DECLARE @xmlParam NVARCHAR(MAX)
--SET @xmlParam = '
--<xmlparam>
--	<filters>
--		<filter>
--			<fieldname>vendorFrom</fieldname>
--			<condition>Equal To</condition>
--			<from></from>
--			<to></to>
--			<join>And</join>
--			<datatype>Int</datatype>
--		</filter>
--		<filter>
--			<fieldname>vendorTo</fieldname>
--			<condition>Equal To</condition>
--			<from></from>
--			<to />
--			<join>And</join>
--			<datatype>Int</datatype>
--		</filter>
--		<filter>
--			<fieldname>year</fieldname>
--			<condition>Equal To</condition>
--			<from>2015</from>
--			<to />
--			<join>And</join>
--			<datatype>Int</datatype>
--		</filter>
--		<filter>
--			<fieldname>corrected</fieldname>
--			<condition>Equal To</condition>
--			<from>0</from>
--			<to />
--			<join>And</join>
--			<datatype>Boolean</datatype>
--		</filter>
--		<filter>
--			<fieldname>reprint</fieldname>
--			<condition>Equal To</condition>
--			<from>0</from>
--			<to />
--			<join>And</join>
--			<datatype>Boolean</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

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
	SELECT *, NULL AS strCorrected, NULL AS strYear 
		,NULL AS strEmployerAddress2
		,NULL AS strCompanyName2
		,NULL AS strEIN2
		,NULL AS strFederalTaxId2
		,NULL AS strAddress2
		,NULL AS strVendorCompanyName2
		,NULL AS strPayeeName2
		,NULL AS strVendorId2
		,NULL AS strZip2
		,NULL AS strCity2
		,NULL AS strState2
		,NULL AS strZipState2
		,0 AS intYear2
		,0 AS intEntityVendorId
		,NULL AS strFilerType2
		,NULL AS strTransactionType2
		,NULL AS strMerchantCode2
		,0 AS dblCardNotPresent2
		,0 AS dblGrossThirdParty2
		,0 AS dblFederalIncomeTax2
		,0 AS dblJanuary2
		,0 AS dblFebruary2
		,0 AS dblMarch2
		,0 AS dblApril2
		,0 AS dblMay2
		,0 AS dblJune2
		,0 AS dblJuly2
		,0 AS dblAugust2
		,0 AS dblSeptember2
		,0 AS dblOctober2
		,0 AS dblNovember2
		,0 AS dblDecember2
		,0 AS dblTotalPayment2
	FROM vyuAP1099K WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
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
END

--SET @vendorFromParam = @vendorFrom;
--SET @vendorToParam = @vendorTo;
--SET @yearParam = @year;
--SET @correctedParam = @corrected;

;WITH K1099 (
	int1099KId
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
	,intEntityVendorId
	,strFilerType
	,strTransactionType
	,strMerchantCode
	,dblCardNotPresent
	,dblGrossThirdParty
	,dblFederalIncomeTax
	,dblJanuary
	,dblFebruary
	,dblMarch
	,dblApril
	,dblMay
	,dblJune
	,dblJuly
	,dblAugust
	,dblSeptember
	,dblOctober
	,dblNovember
	,dblDecember
	,dblTotalPayment
	,strCorrected
	,strYear
) AS (
SELECT 
	int1099KId = ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
	A.* ,
	(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected,
	(SELECT RIGHT(@yearParam,2)) AS strYear
FROM vyuAP1099K A
OUTER APPLY 
(
	SELECT TOP 1 * FROM tblAP1099History B
	WHERE A.intYear = B.intYear AND B.int1099Form = 6
	AND B.intEntityVendorId = A.intEntityVendorId
	ORDER BY B.dtmDatePrinted DESC
) History
WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
				(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
			ELSE 1 END)
AND A.intYear = @yearParam
-- AND 1 = (
-- 		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
-- 				ELSE 
-- 					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
-- 						WHEN History.ysnPrinted IS NULL THEN 1
-- 						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
-- 					ELSE 0 END)
-- 		END)
)

SELECT
	K1099Top.strEmployerAddress
	,K1099Top.strCompanyName
	,K1099Top.strEIN
	,K1099Top.strFederalTaxId
	,K1099Top.strAddress
	,K1099Top.strVendorCompanyName
	,K1099Top.strPayeeName
	,K1099Top.strVendorId
	,K1099Top.strZip
	,K1099Top.strCity
	,K1099Top.strState
	,K1099Top.strZipState
	,K1099Top.intYear
	,K1099Top.strYear
	,K1099Top.strCorrected
	,K1099Top.intEntityVendorId
	,K1099Top.strFilerType
	,K1099Top.strTransactionType
	,K1099Top.strMerchantCode
	,K1099Top.dblCardNotPresent
	,K1099Top.dblGrossThirdParty
	,K1099Top.dblFederalIncomeTax
	,K1099Top.dblJanuary
	,K1099Top.dblFebruary
	,K1099Top.dblMarch
	,K1099Top.dblApril
	,K1099Top.dblMay
	,K1099Top.dblJune
	,K1099Top.dblJuly
	,K1099Top.dblAugust
	,K1099Top.dblSeptember
	,K1099Top.dblOctober
	,K1099Top.dblNovember
	,K1099Top.dblDecember
	,K1099Top.dblTotalPayment
	,K1099Bottom.strEmployerAddress AS strEmployerAddress2
	,K1099Bottom.strCompanyName AS strCompanyName2
	,K1099Bottom.strEIN AS strEIN2
	,K1099Bottom.strFederalTaxId AS strFederalTaxId2
	,K1099Bottom.strAddress AS strAddress2
	,K1099Bottom.strVendorCompanyName AS strVendorCompanyName2
	,K1099Bottom.strPayeeName AS strPayeeName2
	,K1099Bottom.strVendorId AS strVendorId2
	,K1099Bottom.strZip AS strZip2
	,K1099Bottom.strCity AS strCity2
	,K1099Bottom.strState AS strState2
	,K1099Bottom.strZipState AS strZipState2
	,K1099Bottom.intYear AS intYear2
	,K1099Bottom.intEntityVendorId AS intEntityVendorId2
	,K1099Bottom.dblCardNotPresent AS dblCardNotPresent2
	,K1099Bottom.dblGrossThirdParty AS dblGrossThirdParty2
	,K1099Bottom.dblFederalIncomeTax AS dblFederalIncomeTax2
	,K1099Bottom.dblJanuary AS dblJanuary2
	,K1099Bottom.dblFebruary AS dblFebruary2
	,K1099Bottom.dblMarch AS dblMarch2
	,K1099Bottom.dblApril AS dblApril2
	,K1099Bottom.dblMay AS dblMay2
	,K1099Bottom.dblJune AS dblJune2
	,K1099Bottom.dblJuly AS dblJuly2
	,K1099Bottom.dblAugust AS dblAugust2
	,K1099Bottom.dblSeptember AS dblSeptember2
	,K1099Bottom.dblOctober AS dblOctober2
	,K1099Bottom.dblNovember AS dblNovember2
	,K1099Bottom.dblDecember AS dblDecember2
	,K1099Bottom.dblTotalPayment AS dblTotalPayment2
FROM (
	SELECT
	*
	FROM K1099 A
	WHERE A.int1099KId % 2 = 1
) K1099Top
OUTER APPLY (
	SELECT
	*
	FROM K1099 A
	WHERE A.int1099KId % 2 = 0
	AND A.int1099KId = (K1099Top.int1099KId + 1)
) K1099Bottom