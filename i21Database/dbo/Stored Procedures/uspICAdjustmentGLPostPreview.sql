CREATE PROCEDURE dbo.uspICAdjustmentGLPostPreview @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intInventoryAdjustmentId INT 
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

--Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL
SELECT
	  0 AS 'intInventoryAdjustmentId'
	, '' AS 'strAdjustmentNo'
	, '' AS 'strDescription'
	, '' AS 'strUser'
	, CAST(NULL AS DATETIME) AS 'dtmTransactionDate'
	, '' AS 'strAccountingPeriod'
	RETURN
END

--Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(40)      
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
	, [condition] nvarchar(40)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @strAdjustmentNo NVARCHAR(100)
SELECT @strAdjustmentNo = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strAdjustmentNo'


IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@intInventoryAdjustmentId = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'intInventoryAdjustmentId'
END

SELECT
	  a.intInventoryAdjustmentId
	, a.strAdjustmentNo
	, a.strDescription
	, e.strName AS strUser
	, dtmTransactionDate = a.dtmAdjustmentDate
	, strAccountingPeriod = ap.strFiscalPeriod
FROM tblICInventoryAdjustment a
	LEFT JOIN tblEMEntity e ON e.intEntityId = a.intCreatedByUserId
	OUTER APPLY (
		SELECT strFiscalPeriod = CAST(DATEPART(YEAR, cf.dtmBeginDate) AS NVARCHAR(50)) + 
			CASE WHEN LEN(CAST(DATEPART(MONTH, cf.dtmBeginDate) AS NVARCHAR(50))) = 1 THEN '0' ELSE '' END +
				CAST(DATEPART(MONTH, cf.dtmBeginDate) AS NVARCHAR(50))
		FROM tblGLCurrentFiscalYear cf
	) ap
WHERE a.strAdjustmentNo = @strAdjustmentNo

