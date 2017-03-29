CREATE PROCEDURE [dbo].[uspAPRpt1099INTTwoPart]
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
--	</filters>
--	<options />
--</xmlparam>'

DECLARE @vendorFromParam NVARCHAR(100) = NULL;
DECLARE @vendorToParam NVARCHAR(100) = NULL;
DECLARE @yearParam INT = YEAR(GETDATE());
DECLARE @correctedParam BIT = 0;
DECLARE @reprintParam BIT = 0;
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT *, NULL AS strCorrected
	,NULL AS	strEmployerAddress2
	,NULL AS	strCompanyName2
	,NULL AS	strEIN2
	,NULL AS	strAddress2
	,NULL AS	strVendorCompanyName2
	,NULL AS	strVendorId2
	,NULL AS	strZip2
	,NULL AS	strZipState2
	,NULL AS	strFederalTaxId2
	,0	AS	intYear2
	,0	AS	dbl1099INT2
	,0	AS	intEntityVendorId2
	,NULL AS	strCorrected2
	FROM vyuAP1099INT WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
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
	, [from] nvarchar(50)
	, [to] nvarchar(50)
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
		@reprintParam = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'reprint'

	SELECT 
		@correctedParam = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'corrected'
END;

--SET @vendorFromParam = @vendorFrom;
--SET @vendorToParam = @vendorTo;
--SET @yearParam = @year;
--SET @correctedParam = @corrected;

WITH INT1099 (
	int1099INTId
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strCity
	,strState
	,strZip
	,strZipState
	,strFederalTaxId
	,intYear
	,dbl1099INT
	,intEntityVendorId
	,strCorrected
)
AS
(
	SELECT 
	int1099INTId = ROW_NUMBER() OVER(ORDER BY (SELECT 1))
	,A.* 
	,(CASE WHEN @correctedParam = 0 THEN NULL ELSE 'X' END) AS strCorrected
	FROM vyuAP1099INT A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 1
		AND B.intEntityVendorId = A.[intEntityId]
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
				ELSE 
					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprintParam = 1 THEN 1 
						WHEN History.ysnPrinted IS NULL THEN 1
						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
					ELSE 0 END)
		END)
)

SELECT
	INT1099Top.strEmployerAddress
	,INT1099Top.strCompanyName
	,INT1099Top.strEIN
	,INT1099Top.strAddress
	,INT1099Top.strVendorCompanyName
	,INT1099Top.strVendorId
	,INT1099Top.strZip
	,INT1099Top.strZipState
	,INT1099Top.strFederalTaxId
	,INT1099Top.intYear
	,INT1099Top.dbl1099INT
	,INT1099Top.intEntityVendorId
	,INT1099Top.strCorrected
	,INT1099Bottom.strEmployerAddress		AS	strEmployerAddress2
	,INT1099Bottom.strCompanyName			AS	strCompanyName2
	,INT1099Bottom.strEIN					AS	strEIN2
	,INT1099Bottom.strAddress				AS	strAddress2
	,INT1099Bottom.strVendorCompanyName	AS	strVendorCompanyName2
	,INT1099Bottom.strVendorId			AS	strVendorId2
	,INT1099Bottom.strZip					AS	strZip2
	,INT1099Bottom.strZipState			AS	strZipState2
	,INT1099Bottom.strFederalTaxId		AS	strFederalTaxId2
	,INT1099Bottom.intYear				AS	intYear2
	,INT1099Bottom.dbl1099INT				AS	dbl1099INT2
	,INT1099Bottom.intEntityVendorId		AS	intEntityVendorId2
	,INT1099Bottom.strCorrected			AS	strCorrected2
FROM (
	SELECT
	*
	FROM INT1099 A
	WHERE A.int1099INTId % 2 = 1
) INT1099Top
OUTER APPLY (
	SELECT
	*
	FROM INT1099 A
	WHERE A.int1099INTId % 2 = 0
	AND A.int1099INTId = (INT1099Top.int1099INTId + 1)
) INT1099Bottom