CREATE PROCEDURE [dbo].[uspAPRpt1099NEC]
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
IF LTRIM(RTRIM(@xmlParam)) = '' OR @xmlParam IS NULL
BEGIN
--SET @xmlParam = NULL 
	SELECT *, NULL AS strCorrected, NULL AS strYear FROM vyuAP1099NEC WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
	RETURN;
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

SELECT 
A.* ,
(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected,
(SELECT RIGHT(@yearParam,2)) AS strYear
FROM vyuAP1099NEC A
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



