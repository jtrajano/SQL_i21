CREATE PROCEDURE [dbo].[uspAPRpt1099MISCTwoPart]
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
			,0 AS dblBoatsProceeds2
			,0 AS dblCropInsurance2
			,0 AS dblFederalIncome2
			,0 AS dblGrossProceedsAtty2
			,0 AS dblMedicalPayments2
			,0 AS dblNonemployeeCompensation2
			,0 AS dblOtherIncome2
			,0 AS dblParachutePayments2
			,0 AS dblRents2
			,0 AS dblRoyalties2
			,0 AS dblSubstitutePayments2
			,0 AS dblDirectSales2
			,NULL AS strDirectSales2
			,0 ASintEntityVendorId2
			,NULL AS strCorrected2
			,0 AS dblTotalPayment2
	FROM vyuAP1099MISC WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
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

WITH MISC1099 (
	int1099MISCId
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
	,dblBoatsProceeds
	,dblCropInsurance
	,dblFederalIncome
	,dblGrossProceedsAtty
	,dblMedicalPayments
	,dblNonemployeeCompensation
	,dblOtherIncome
	,dblParachutePayments
	,dblRents
	,dblRoyalties
	,dblSubstitutePayments
	,dblDirectSales
	,strDirectSales
	,intEntityVendorId
	,dblTotalPayment
	,strCorrected
	,strYear
)
AS 
(
	SELECT 
     int1099MISCId = ROW_NUMBER() OVER(ORDER BY (SELECT 1))
	,A.* 
	,(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected
	,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM vyuAP1099MISC A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 1
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
	MISC1099Top.strEmployerAddress
	,MISC1099Top.strCompanyName
	,MISC1099Top.strEIN
	,MISC1099Top.strFederalTaxId
	,MISC1099Top.strAddress
	,MISC1099Top.strVendorCompanyName
	,MISC1099Top.strVendorId
	,MISC1099Top.strZip
	,MISC1099Top.strCity
	,MISC1099Top.strState
	,MISC1099Top.strZipState
	,MISC1099Top.intYear
	,MISC1099Top.dblBoatsProceeds
	,MISC1099Top.dblCropInsurance
	,MISC1099Top.dblFederalIncome
	,MISC1099Top.dblGrossProceedsAtty
	,MISC1099Top.dblMedicalPayments
	,MISC1099Top.dblNonemployeeCompensation
	,MISC1099Top.dblOtherIncome
	,MISC1099Top.dblParachutePayments
	,MISC1099Top.dblRents
	,MISC1099Top.dblRoyalties
	,MISC1099Top.dblSubstitutePayments
	,MISC1099Top.dblDirectSales
	,MISC1099Top.strDirectSales
	,MISC1099Top.intEntityVendorId
	,MISC1099Top.strCorrected
	,MISC1099Top.dblTotalPayment
	,MISC1099Top.strYear
	,MISC1099Bottom.strEmployerAddress			AS strEmployerAddress2
	,MISC1099Bottom.strCompanyName				AS strCompanyName2
	,MISC1099Bottom.strEIN						AS strEIN2
	,MISC1099Bottom.strFederalTaxId				AS strFederalTaxId2
	,MISC1099Bottom.strAddress					AS strAddress2
	,MISC1099Bottom.strVendorCompanyName		AS strVendorCompanyName2
	,MISC1099Bottom.strVendorId					AS strVendorId2
	,MISC1099Bottom.strZip						AS strZip2
	,MISC1099Bottom.strCity						AS strCity2
	,MISC1099Bottom.strState					AS strState2
	,MISC1099Bottom.strZipState					AS strZipState2
	,MISC1099Bottom.intYear						AS intYear2
	,MISC1099Bottom.dblBoatsProceeds			AS dblBoatsProceeds2
	,MISC1099Bottom.dblCropInsurance			AS dblCropInsurance2
	,MISC1099Bottom.dblFederalIncome			AS dblFederalIncome2
	,MISC1099Bottom.dblGrossProceedsAtty		AS dblGrossProceedsAtty2
	,MISC1099Bottom.dblMedicalPayments			AS dblMedicalPayments2
	,MISC1099Bottom.dblNonemployeeCompensation	AS dblNonemployeeCompensation2
	,MISC1099Bottom.dblOtherIncome				AS dblOtherIncome2
	,MISC1099Bottom.dblParachutePayments		AS dblParachutePayments2
	,MISC1099Bottom.dblRents					AS dblRents2
	,MISC1099Bottom.dblRoyalties				AS dblRoyalties2
	,MISC1099Bottom.dblSubstitutePayments		AS dblSubstitutePayments2
	,MISC1099Bottom.dblDirectSales				AS dblDirectSales2
	,MISC1099Bottom.strDirectSales				AS strDirectSales2
	,MISC1099Bottom.intEntityVendorId			AS intEntityVendorId2
	,MISC1099Bottom.strCorrected				AS strCorrected2
	,MISC1099Bottom.dblTotalPayment				AS dblTotalPayment2
	,MISC1099Bottom.strYear						AS strYear2
FROM (
	SELECT
	*
	FROM MISC1099 A
	WHERE A.int1099MISCId % 2 = 1
) MISC1099Top
OUTER APPLY (
	SELECT
	*
	FROM MISC1099 A
	WHERE A.int1099MISCId % 2 = 0
	AND A.int1099MISCId = (MISC1099Top.int1099MISCId + 1)
) MISC1099Bottom