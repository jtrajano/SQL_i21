CREATE PROCEDURE [dbo].[uspAPRpt1099PATRTwoPart]
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
	SELECT *
	,NULL as strEmployerAddress2
	,NULL as strCompanyName2
	,NULL as strEIN2
	,NULL as strFederalTaxId2
	,NULL as strAddress2
	,NULL as strVendorCompanyName2
	,NULL as strPayeeName2
	,NULL as strVendorId2
	,NULL as strZip2
	,NULL as strCity2
	,NULL as strState2
	,NULL as strZipState2
	,0 as intYear2
	,0 as dblDividends2
	,0 as dblNonpatronage2
	,0 as dblPerUnit2
	,0 as dblFederalTax2
	,0 as dblRedemption2
	,0 as dblDomestic2
	,0 as dblInvestment2
	,0 as dblOpportunity2
	,0 as dblAMT2
	,0 as dblOther2
	,0 as intEntityVendorId2
	,0  dblTotalPayment2
	,NULL AS  strCorrected
	,NULL AS strCorrected2 
	FROM dbo.vyuAP1099PATR A WHERE A.intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
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

WITH PATR1099 (
	int1099PATRId
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
	,dblDividends
	,dblNonpatronage
	,dblPerUnit
	,dblFederalTax
	,dblRedemption
	,dblDomestic
	,dblInvestment
	,dblOpportunity
	,dblAMT
	,dblOther
	,intEntityVendorId
	,dblTotalPayment
	,strCorrected
)
AS 
(
	SELECT 
     int1099PATRId = ROW_NUMBER() OVER(ORDER BY (SELECT 1))
	,A.* 
	,(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected
	FROM vyuAP1099PATR A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 4
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
	 PATR1099Top.strEmployerAddress
	,PATR1099Top.strCompanyName
	,PATR1099Top.strEIN
	,PATR1099Top.strFederalTaxId
	,PATR1099Top.strAddress
	,PATR1099Top.strVendorCompanyName
	,PATR1099Top.strPayeeName
	,PATR1099Top.strVendorId
	,PATR1099Top.strZip
	,PATR1099Top.strCity
	,PATR1099Top.strState
	,PATR1099Top.strZipState
	,PATR1099Top.intYear
	,PATR1099Top.dblDividends
	,PATR1099Top.dblNonpatronage
	,PATR1099Top.dblPerUnit
	,PATR1099Top.dblFederalTax
	,PATR1099Top.dblRedemption
	,PATR1099Top.dblDomestic
	,PATR1099Top.dblInvestment
	,PATR1099Top.dblOpportunity
	,PATR1099Top.dblAMT
	,PATR1099Top.dblOther
	,PATR1099Top.intEntityVendorId
	,PATR1099Top.dblTotalPayment
	,PATR1099Top.strCorrected
	--,PATR1099Bottom.strEmployerAddress       AS strEmployerAddress2                     
	--,PATR1099Bottom.strCompanyName           AS strCompanyName2                        
	--,PATR1099Bottom.strEIN                   AS strEIN2                                
	--,PATR1099Bottom.strFederalTaxId          AS strFederalTaxId2                       
	--,PATR1099Bottom.strAddress               AS strAddress2                            
	--,PATR1099Bottom.strVendorCompanyName     AS strVendorCompanyName2                  
	--,PATR1099Bottom.strPayeeName             AS strPayeeName2                          
	--,PATR1099Bottom.strVendorId              AS strVendorId2                           
	--,PATR1099Bottom.strZip                   AS strZip2                                
	--,PATR1099Bottom.strCity                  AS strCity2                               
	--,PATR1099Bottom.strState                 AS strState2                              
	--,PATR1099Bottom.strZipState              AS strZipState2                           
	--,PATR1099Bottom.intYear                  AS intYear2                               
	--,PATR1099Bottom.dblDividends             AS dblDividends2                          
	--,PATR1099Bottom.dblNonpatronage          AS dblNonpatronage2                       
	--,PATR1099Bottom.dblPerUnit               AS dblPerUnit2                            
	--,PATR1099Bottom.dblFederalTax            AS dblFederalTax2                         
	--,PATR1099Bottom.dblRedemption            AS dblRedemption2                         
	--,PATR1099Bottom.dblDomestic              AS dblDomestic2                           
	--,PATR1099Bottom.dblInvestment            AS dblInvestment2                         
	--,PATR1099Bottom.dblOpportunity           AS dblOpportunity2                        
	--,PATR1099Bottom.dblAMT                   AS dblAMT2                                
	--,PATR1099Bottom.dblOther                 AS dblOther2                              
	--,PATR1099Bottom.intEntityVendorId        AS intEntityVendorId2      
	--,PATR1099Bottom.dblTotalPayment			 AS dblTotalPayment2               
	--,PATR1099Bottom.strCorrected             AS strCorrected2                          
FROM (
	SELECT
	*
	FROM PATR1099 A
	--WHERE A.int1099PATRId % 2 = 1
) PATR1099Top
--OUTER APPLY (
--	SELECT
--	*
--	FROM PATR1099 A
--	WHERE A.int1099PATRId % 2 = 0
--	AND A.int1099PATRId = (PATR1099Top.int1099PATRId + 1)
--) PATR1099Bottom