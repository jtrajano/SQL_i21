CREATE PROCEDURE [dbo].[uspAPRptOpenClearingSummary]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX), 
	    @innerQuery NVARCHAR(MAX), 
		@filter NVARCHAR(MAX) = '';
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @total NUMERIC(18,6), 
		@amountDue NUMERIC(18,6), 
		@amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)

	-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 
		NULL AS dtmDate,
		NULL AS dtmDueDate,
		NULL AS strVendorId,
		0 AS intEntityVendorId,
		0 AS intBillId,
		NULL AS strBillId,
		NULL AS strCompanyName,
		NULL AS strVendorIdName,
		NULL AS strAge,
		0 AS dblTotal,
		0 AS dblAmountPaid,
		0 AS dblAmountDue,
		0 AS dblCurrent,
		0 AS dbl1,
		0 AS dbl30,
		0 AS dbl60,
		0 AS dbl90,
		0 AS intAging
END

DECLARE @xmlDocumentId AS INT;
-- Create a table variable to hold the XML data. 		
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
-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
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

--select * from @temp_xml_table
--CREATE date filter
SELECT @dateFrom = [from], @dateTo = [to] FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SET @innerQuery = 
		'SELECT 
			intInventoryReceiptId
			,intBillId
			,strVendorIdName
			,dblTotal
			,dblAmountDue
			,dblAmountPaid
			,dblDiscount
			,dblInterest
			,dtmDate
			,dtmDueDate
		FROM dbo.vyuAPClearables'

IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END
ELSE
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE();
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'

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

----CREATE vendor filter
--SELECT @vendorId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intEntityVendorId';
--IF @vendorId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @from, @to, @join, @datatype)
--END

--SELECT @accountId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intAccountId';
--IF @accountId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@accountId, @from, @to, @join, @datatype)
--END

--SELECT @billId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intBillId';
--IF @billId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@billId, @from, @to, @join, @datatype)
--END

SET @query = '
	SELECT * FROM (
	SELECT 
		intEntityVendorId
		,strVendorId
		,strVendorIdName
		,(SELECT TOP 1strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
		,SUM(dblCurrent) dblCurrent
		,SUM(dbl1) dbl1
		,SUM(dbl30) dbl30
		,SUM(dbl60) dbl60
		,SUM(dbl90) dbl90
		,SUM(dblTotal) dblTotal
		,SUM(dblAmountPaid) dblAmountPaid
		,SUM(dblAmountDue) dblAmountDue
	FROM (
		SELECT
		 tmpAgingSummaryTotal.dtmDate
		,B.strVendorId
		,B.[intEntityVendorId]
		,A.intBillId
		,A.strBillId
		,ISNULL(B.strVendorId,'''') + '' - '' + isnull(C.strName,'''') as strVendorIdName 
		,tmpAgingSummaryTotal.dblTotal
		,ISNULL(tmpAgingSummaryTotal.dblAmountPaid, 0) as dblAmountPaid
		,tmpAgingSummaryTotal.dblAmountDue
		,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 
			THEN 0 
			ELSE tmpAgingSummaryTotal.dblAmountDue 
		 END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
			THEN 0
			ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) 
		 END AS intAging
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
			THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 
		 END AS dblCurrent,
		 CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
		 	THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 
		 END AS dbl1, 
		 CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
		 	THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 
		 END AS dbl30, 
		 CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
		 	THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 
		 END AS dbl60,
		 CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 
		 END AS dbl90
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN ''Current''
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 THEN ''01 - 30 Days''
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60 THEN ''31 - 60 Days''
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 THEN ''61 - 90 Days''
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90 THEN ''Over 90'' 
				ELSE ''Current'' END AS strAge
		FROM  
		(
			SELECT 
		     tmpAPClearables.intInventoryReceiptId
			,tmpAPClearables.intBillId
			,tmpAPClearables.dtmDate
			,SUM(tmpAPClearables.dblTotal) AS dblTotal
			,SUM(tmpAPClearables.dblAmountPaid) AS dblAmountPaid
			,(SUM(tmpAPClearables.dblTotal) + SUM(tmpAPClearables.dblInterest) - SUM(tmpAPClearables.dblAmountPaid) - SUM(tmpAPClearables.dblDiscount)) AS dblAmountDue
			FROM (' 
					+ @innerQuery +
				') tmpAPClearables
			GROUP BY intInventoryReceiptId, intBillId, dtmDate
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
			ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityVendorId] = C.intEntityId)
			ON B.[intEntityVendorId] = A.[intEntityVendorId]
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
) SubQuery
	GROUP BY 
		intEntityVendorId
		,strVendorId
		,strVendorIdName
	) MainQuery
'

SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query