CREATE PROCEDURE [dbo].[uspAPRpt1099Summary]
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

DECLARE @vendorFromParam NVARCHAR(100) = NULL;
DECLARE @vendorToParam NVARCHAR(100) = NULL;
DECLARE @yearParam INT = YEAR(GETDATE());
DECLARE @formType INT = 0;
DECLARE @correctedParam BIT = 0;
DECLARE @reprint BIT = 0;
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT NULL AS strYear, NULL AS strForm, * FROM [vyuAP1099Summary] WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
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

	SELECT 
		@formType = CAST([from] AS INT)
	FROM @temp_xml_table WHERE [fieldname] = 'formType'
	
END;

WITH SUMARRY1099 (
	 strCompanyName
	,strCompanyAddress
	,strFederalTaxId
	,strVendorCompanyName
	,strPayeeName
	,dbl1099Amount
	,dbl1099AmountPaid
	,dblDifference
	,strVendorId
	,intYear
	,strYear
	,strForm
)
AS 
(
	SELECT 
		 A.strCompanyName
		,A.strCompanyAddress
		,strFederalTaxId
		,strVendorCompanyName
		,strPayeeName
		,CASE WHEN SUM(dbl1099Amount)	!= 0 THEN  SUM(dbl1099Amount) ELSE 0 END  AS dbl1099Amount 
		,CASE WHEN SUM(dbl1099AmountPaid)	!= 0 THEN  SUM(dbl1099AmountPaid) ELSE 0 END  AS dbl1099Amount 
		,CASE WHEN SUM(dblDifference)	!= 0 THEN  SUM(dblDifference) ELSE 0 END  AS dbl1099Amount 
		,A.strVendorId
		,A.intYear 
		,@yearParam AS strYear
		,(CASE WHEN @formType = 1 THEN '1099 MISC' 
			  WHEN @formType = 2 THEN '1099 INT'
			  WHEN @formType = 3 THEN '1099 B'	
			  WHEN @formType = 4 THEN '1099 PATR'
			  WHEN @formType = 5 THEN '1099 DIV' 
			  ELSE '' END) AS strForm
	FROM vyuAP1099Summary A
	CROSS JOIN tblSMCompanySetup B
	WHERE A.intYear = @yearParam AND A.int1099Form = @formType
	GROUP BY 
	  A.strCompanyName
	, A.strCompanyAddress
	, A.strAddress
	, A.strVendorCompanyName
	, A.strPayeeName
	, A.strVendorId
	, A.strZip
	, A.strFederalTaxId
	, A.strCity
	, A.strState
	, A.strZipState
	, A.intYear 
)
SELECT
     strCompanyName
	,strCompanyAddress
	,SUMARRY1099.strFederalTaxId
	,SUMARRY1099.strVendorCompanyName
	,SUMARRY1099.strPayeeName
	,dbl1099Amount
	,dbl1099AmountPaid
	,dblDifference
	,SUMARRY1099.strVendorId
	,SUMARRY1099.intYear  
	,SUMARRY1099.strYear
	,SUMARRY1099.strForm
FROM (
	SELECT
	*
	FROM SUMARRY1099 A
) SUMARRY1099