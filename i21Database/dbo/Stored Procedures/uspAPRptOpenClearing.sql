CREATE PROCEDURE [dbo].[uspAPRptOpenClearing]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX) = ''
DECLARE @filter NVARCHAR(MAX) = ''
DECLARE @filterPerItem NVARCHAR(MAX) = ''

DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)

DECLARE @dateFrom DATETIME
DECLARE @dateTo DATETIME
DECLARE @dateCondition NVARCHAR(50)
DECLARE @filterCount INT = 0

--SANITIZE AND CHECK IF @xmlParam IS EMPTY 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
  	--ADD THIS TO INITIALIZE XtraReports FIELD
    SELECT   
		0 AS intTransactionType,  
        NULL AS strVendorIdName,
        NULL AS strTransactionId,  
        NULL AS dtmDate,  
        NULL AS strLocationName,  
        NULL AS strReferenceNumber,  
        0 AS dblQuantity,  
        0 AS dblAmount,  
        0 AS dblOffsetQuantity,  
        0 AS dblOffsetAmount,  
        0 AS dblClearingQuantity,  
        0 AS dblClearingAmount,  
        0 AS intAging,
		NULL as dtmCurrentDate,
		NULL AS strCompanyAddress,
		NULL AS strCompanyName,
		NULL AS dtmStartDate,
		NULL AS dtmEndDate
END

DECLARE @xmlDocumentId AS INT
--CREATE TABLE TO HOLD XML DATA FILTERS
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)

--PREPARE XML
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam
	
--INSERT XML TO THE TABLE
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, condition nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [begingroup] nvarchar(50)
	, [endgroup] nvarchar(50)
	, [datatype] nvarchar(50)
)

--CHECK IF DATE IS THE ONLY FILTER (FOR GL SUMMARY PURPOSE)
SELECT @filterCount = COUNT(*) FROM @temp_xml_table WHERE [fieldname] != 'dtmDate' AND [condition] != 'Dummy';
SELECT @dateFrom = [from], @dateTo = [to], @dateCondition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
IF @dateFrom IS NULL
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE()
END

--DELETE DUMMY FILTERS
DELETE FROM @temp_xml_table WHERE [condition] = 'Dummy'

--CREATE PER ITEM FILTERS
WHILE EXISTS(SELECT 1 FROM @temp_xml_table WHERE [fieldname] IN ('dblClearingQuantity', 'dblClearingAmount'))
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] IN ('dblClearingQuantity', 'dblClearingAmount')
	SET @filterPerItem = @filterPerItem + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	DELETE FROM @temp_xml_table WHERE id = @id
	IF EXISTS(SELECT 1 FROM @temp_xml_table WHERE [fieldname] IN ('dblClearingQuantity', 'dblClearingAmount'))
	BEGIN
		SET @filterPerItem = @filterPerItem + ' AND '
	END
END

IF NULLIF(@filterPerItem, '') IS NOT NULL
BEGIN
	SET @filterPerItem = ' WHERE ' + @filterPerItem
END

--CREATE FILTERS
WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	DELETE FROM @temp_xml_table WHERE id = @id
	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END

--RAW QUERY
SET @query = '
	SELECT * FROM (
		SELECT
			C.intTransactionType,
			C.intTransactionDetailId,
			C.intItemId,
			dbo.fnTrim(ISNULL(V.strVendorId, E.strEntityNo) + '' - '' + ISNULL(E.strName, '''')) AS strVendorIdName,
			C.strTransactionId,
			C.dtmDate,
			CL.strLocationName,
			C.strReferenceNumber,
			CASE WHEN C.intOffsetId > 0 THEN 0 ELSE C.dblQuantity END AS dblQuantity,
			CASE WHEN C.intOffsetId > 0 THEN 0 ELSE ROUND(C.dblAmount, 2) END AS dblAmount,
			CASE WHEN C.intOffsetId > 0 THEN C.dblQuantity * -1 ELSE 0 END AS dblOffsetQuantity,
			CASE WHEN C.intOffsetId > 0 THEN ROUND(C.dblAmount * -1, 2) ELSE 0 END AS dblOffsetAmount,
			A.strAccountId,
			FP.strPeriod
		FROM tblAPClearing C
		INNER JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON V.intEntityId = E.intEntityId) ON C.intEntityVendorId = V.intEntityId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = C.intLocationId
		INNER JOIN tblGLAccount A ON A.intAccountId = C.intAccountId
		LEFT JOIN tblGLFiscalYearPeriod FP ON C.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR C.dtmDate = FP.dtmStartDate OR C.dtmDate = FP.dtmEndDate
	) rawClearing
'

--CONCATENATE FILTER TO THE RAW QUERY
IF NULLIF(@filter, '') IS NOT NULL
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PER ITEM CLEARING AND CONCATENATE ITEM FILTER
SET @query = '
	SELECT 
		detailedClearing.*
	FROM (
		SELECT
			intTransactionType,
			strVendorIdName,
			strTransactionId,
			MIN(dtmDate) dtmDate,
			MAX(strLocationName) strLocationName,
			MAX(strReferenceNumber) strReferenceNumber,
			SUM(dblQuantity) AS dblQuantity,
			SUM(dblAmount) AS dblAmount,
			SUM(dblOffsetQuantity) AS dblOffsetQuantity,
			SUM(dblOffsetAmount) AS dblOffsetAmount,
			SUM(dblQuantity - dblOffsetQuantity) AS dblClearingQuantity,
			SUM(dblAmount - dblOffsetAmount) AS dblClearingAmount
		FROM (
			'+ @query +'
		) filteredClearing
		'+ @filterPerItem +'
		GROUP BY intTransactionType, intTransactionDetailId, intItemId, strVendorIdName, strTransactionId
	) detailedClearing
	WHERE detailedClearing.dblClearingAmount <> 0 AND detailedClearing.dblClearingQuantity <> 0
'

--FINALIZE AND ADD HEADER INFORMATIONS
SET @query = '
	SELECT
		finalClearing.*,
		CASE WHEN DATEDIFF(dayofyear, finalClearing.dtmDate, GETDATE()) <= 0 THEN 0 ELSE ISNULL(DATEDIFF(dayofyear, finalClearing.dtmDate, GETDATE()), 0) END AS intAging,
		GETDATE() AS dtmCurrentDate,
		dbo.fnAPFormatAddress(NULL, NULL, NULL, CS.strAddress, CS.strCity, CS.strState, CS.strZip, CS.strCountry, NULL) AS strCompanyAddress,
		CS.strCompanyName,
		dtmStartDate = '''+ CASE WHEN @filterCount > 0 THEN '0' ELSE CONVERT(NVARCHAR(10), ISNULL(@dateFrom, '1/1/1900'), 101) END +''',
		dtmEndDate = '''+ CASE WHEN @filterCount > 0 THEN '0' ELSE CONVERT(NVARCHAR(10), CASE WHEN @dateCondition = 'Equal To' THEN @dateFrom ELSE ISNULL(@dateTo, GETDATE()) END, 101) END +'''
	FROM (
		'+ @query +'
	) finalClearing
	CROSS APPLY tblSMCompanySetup CS
	ORDER BY finalClearing.strVendorIdName
'

--EXECUTE QUERY
EXEC sp_executesql @query