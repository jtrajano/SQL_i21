CREATE PROCEDURE [dbo].[uspAPRptPurchaseOrder]
	@xmlParam NVARCHAR(MAX) = NULL
	--@intPurchaseId INT
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
--			<fieldname>intPurchaseId</fieldname>
--			<condition>Equal To</condition>
--			<from></from>
--			<to></to>
--			<join>And</join>
--			<datatype>Int</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

DECLARE @intPurchaseId INT 
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT *, NULL AS strCorrected, NULL AS strLogoType, NULL AS imgLogo, NULL AS imgFooter FROM [vyuAPRptPurchase] WHERE intPurchaseId = 0 --RETURN NOTHING TO RETURN SCHEMA
END

DECLARE @imgLogo VARBINARY(MAX);

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
		@intPurchaseId = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'intPurchaseId'
END

--Invalid Image Logo
DECLARE @invalidImgLogo VARBINARY = 0x

-- GET LOGO
SELECT @imgLogo = dbo.fnSMGetCompanyLogo('Header')

SELECT 
	A.*,
	NULL strCorrected,
	CASE WHEN LP.imgLogo IS NOT NULL AND LP.imgLogo != @invalidImgLogo  THEN 'Logo' ELSE 'Attachment' END strLogoType,  
 	CASE WHEN LP.imgLogo IS NOT NULL AND LP.imgLogo != @invalidImgLogo THEN LP.imgLogo ELSE @imgLogo END imgLogo,
	LPF.imgLogo imgFooter
FROM [vyuAPRptPurchase] A
LEFT JOIN tblSMLogoPreference LP ON LP.intCompanyLocationId = A.intShipToId AND LP.ysnDefault = 1
LEFT JOIN tblSMLogoPreferenceFooter LPF ON LPF.intCompanyLocationId = A.intShipToId AND LPF.ysnDefault = 1
WHERE intPurchaseId = (CASE WHEN @intPurchaseId IS NOT NULL THEN @intPurchaseId ELSE 0 END)